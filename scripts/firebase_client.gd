extends Node

const API_KEY    := "AIzaSyAILvI4UH7mpAYhXbZb-2UdRwf-qO4TsAw"
const PROJECT_ID := "asocijacije-hr"

const _AUTH_URL    := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + API_KEY
const _REFRESH_URL := "https://securetoken.googleapis.com/v1/token?key=" + API_KEY
const _FS_BASE     := "https://firestore.googleapis.com/v1/projects/" + PROJECT_ID + "/databases/(default)/documents"

var _id_token: String = ""
var _uid: String = ""
var _cache: Dictionary = {}
var _last_error: String = ""

# ── Low-level HTTP ─────────────────────────────────────────────────────────

# Web path: browser fetch() via JavaScriptBridge — browser handles Content-Encoding
# transparently so Godot never sees gzip bytes.
signal _fetch_done
var _fetch_code: int = 0
var _fetch_body: String = ""
var _js_cb  # JavaScriptObject — kept alive to prevent GC

func _http_web(method_str: String, url: String, body: String, content_type: String, token: String = "") -> Variant:
	var window = JavaScriptBridge.get_interface("window")
	# Pass request data via window properties to avoid JS string-escaping issues
	window["__gfb_method"] = method_str
	window["__gfb_url"]    = url
	window["__gfb_body"]   = body
	window["__gfb_ct"]     = content_type
	window["__gfb_token"]  = token

	_js_cb = JavaScriptBridge.create_callback(func(args):
		_fetch_code = int(args[0])
		_fetch_body = str(args[1])
		_fetch_done.emit()
	)
	window["__gfb_cb"] = _js_cb

	JavaScriptBridge.eval("""
(function() {
	var hdr = { 'Content-Type': window.__gfb_ct };
	if (window.__gfb_token) hdr['Authorization'] = 'Bearer ' + window.__gfb_token;
	var opts = { method: window.__gfb_method, headers: hdr };
	if (window.__gfb_body) opts.body = window.__gfb_body;
	fetch(window.__gfb_url, opts)
		.then(function(r) { var s = r.status; return r.text().then(function(t) { return [s, t]; }); })
		.then(function(a) { window.__gfb_cb(a[0], a[1]); })
		.catch(function(e) { console.error('FirebaseClient fetch error:', e); window.__gfb_cb(0, ''); });
})();
""", true)

	await _fetch_done
	var code := _fetch_code
	var text := _fetch_body
	print("FirebaseClient(web): http=%d url=%s" % [code, url.left(60)])
	if code < 200 or code >= 300:
		push_warning("FirebaseClient HTTP %d: %s" % [code, text.left(300)])
		return null
	return JSON.parse_string(text)

func _http(method: int, url: String, body: String, content_type: String, token: String = "") -> Variant:
	if OS.get_name() == "Web":
		var method_str := "POST" if method == HTTPClient.METHOD_POST else "GET"
		return await _http_web(method_str, url, body, content_type, token)

	var http := HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	var headers := PackedStringArray([
		"Content-Type: " + content_type,
	])
	if token != "":
		headers.append("Authorization: Bearer " + token)
	var req_err := http.request(url, headers, method, body)
	if req_err != OK:
		print("FirebaseClient: request() failed err=%d url=%s" % [req_err, url.left(60)])
		http.queue_free()
		return null
	var data = await http.request_completed
	http.queue_free()
	var result_code: int = data[0]
	var code: int = data[1]
	var text: String = (data[3] as PackedByteArray).get_string_from_utf8()
	print("FirebaseClient: result=%d http=%d url=%s" % [result_code, code, url.left(60)])
	if code < 200 or code >= 300:
		push_warning("FirebaseClient HTTP %d: %s" % [code, text.left(300)])
		return null
	return JSON.parse_string(text)

func _post_json(url: String, body: Dictionary, token: String = "") -> Variant:
	return await _http(HTTPClient.METHOD_POST, url, JSON.stringify(body), "application/json", token)

func _post_form(url: String, body: String) -> Variant:
	return await _http(HTTPClient.METHOD_POST, url, body, "application/x-www-form-urlencoded")

# ── Auth ───────────────────────────────────────────────────────────────────
func ensure_authed() -> bool:
	if _id_token != "":
		return true

	var cfg := ConfigFile.new()
	if cfg.load(SaveManager.PREFS_PATH) == OK:
		var refresh_token: String = cfg.get_value("firebase", "refresh_token", "")
		_uid = cfg.get_value("firebase", "uid", "")
		if refresh_token != "":
			var resp = await _post_form(_REFRESH_URL,
				"grant_type=refresh_token&refresh_token=" + refresh_token)
			if resp != null and resp.has("id_token"):
				_id_token = resp["id_token"]
				return true

	# No stored token — create new anonymous user
	var resp = await _post_json(_AUTH_URL, {"returnSecureToken": true})
	if resp == null or not resp.has("idToken"):
		push_warning("FirebaseClient: anonymous sign-in failed — resp: %s" % str(resp))
		return false

	_id_token = resp["idToken"]
	_uid      = resp["localId"]

	var save_cfg := ConfigFile.new()
	save_cfg.load(SaveManager.PREFS_PATH)
	save_cfg.set_value("firebase", "uid",           _uid)
	save_cfg.set_value("firebase", "refresh_token", resp["refreshToken"])
	save_cfg.save(SaveManager.PREFS_PATH)
	return true

func get_uid() -> String:
	return _uid

func get_last_error() -> String:
	return _last_error

# ── Submission dedup guard ─────────────────────────────────────────────────
func was_submitted(mode: String, date_str: String) -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SaveManager.PREFS_PATH) != OK:
		return false
	return cfg.get_value("submitted", mode + "_" + date_str, false)

func mark_submitted(mode: String, date_str: String) -> void:
	var cfg := ConfigFile.new()
	cfg.load(SaveManager.PREFS_PATH)
	cfg.set_value("submitted", mode + "_" + date_str, true)
	cfg.save(SaveManager.PREFS_PATH)

# ── Leaderboard write ──────────────────────────────────────────────────────
func submit_score(player_name: String, score: int, time_sec: float,
		mode: String, date_str: String, seed: int) -> bool:
	_last_error = ""
	if not await ensure_authed():
		_last_error = "auth_failed"
		return false
	var body := {
		"fields": {
			"name":  {"stringValue": player_name},
			"score": {"integerValue": str(score)},
			"time":  {"doubleValue": time_sec},
			"mode":  {"stringValue": mode},
			"date":  {"stringValue": date_str},
			"uid":   {"stringValue": _uid},
			"seed":  {"integerValue": str(seed)},
		}
	}
	var resp = await _post_json(_FS_BASE + "/leaderboard", body, _id_token)
	if resp == null:
		# Token may be expired — force re-auth and retry once
		_id_token = ""
		if not await ensure_authed():
			_last_error = "auth_failed"
			return false
		resp = await _post_json(_FS_BASE + "/leaderboard", body, _id_token)
	if resp == null:
		_last_error = "network_error"
		push_warning("FirebaseClient: submit_score failed after retry")
		return false
	mark_submitted(mode, date_str)
	return true

# ── Leaderboard read ───────────────────────────────────────────────────────
func fetch_leaderboard(mode: String, date_str: String, limit: int = 20) -> Array:
	var cache_key := mode + "_" + date_str
	if _cache.has(cache_key):
		return _cache[cache_key]
	var body := {
		"structuredQuery": {
			"from": [{"collectionId": "leaderboard"}],
			"where": {
				"compositeFilter": {
					"op": "AND",
					"filters": [
						{"fieldFilter": {
							"field": {"fieldPath": "mode"},
							"op": "EQUAL",
							"value": {"stringValue": mode}
						}},
						{"fieldFilter": {
							"field": {"fieldPath": "date"},
							"op": "EQUAL",
							"value": {"stringValue": date_str}
						}}
					]
				}
			},
			"orderBy": [
				{"field": {"fieldPath": "score"}, "direction": "DESCENDING"},
				{"field": {"fieldPath": "time"},  "direction": "ASCENDING"}
			],
			"limit": limit
		}
	}
	var resp = await _post_json(_FS_BASE + ":runQuery", body)
	if not resp is Array:
		return []
	var entries: Array = []
	for item in resp:
		if not (item is Dictionary) or not item.has("document"):
			continue
		var fields: Dictionary = item["document"]["fields"]
		entries.append({
			"name":  _str(fields, "name"),
			"score": int(_num(fields, "score")),
			"time":  float(_num(fields, "time")),
			"uid":   _str(fields, "uid"),
		})
	_cache[cache_key] = entries
	return entries

# ── Player rank (count players with higher score) ──────────────────────────
func fetch_player_rank(mode: String, date_str: String, score: int) -> int:
	var body := {
		"structuredAggregationQuery": {
			"structuredQuery": {
				"from": [{"collectionId": "leaderboard"}],
				"where": {
					"compositeFilter": {
						"op": "AND",
						"filters": [
							{"fieldFilter": {
								"field": {"fieldPath": "mode"},
								"op": "EQUAL",
								"value": {"stringValue": mode}
							}},
							{"fieldFilter": {
								"field": {"fieldPath": "date"},
								"op": "EQUAL",
								"value": {"stringValue": date_str}
							}},
							{"fieldFilter": {
								"field": {"fieldPath": "score"},
								"op": "GREATER_THAN",
								"value": {"integerValue": str(score)}
							}}
						]
					}
				}
			},
			"aggregations": [{"count": {}, "alias": "count"}]
		}
	}
	var resp = await _post_json(_FS_BASE + ":runAggregationQuery", body)
	if not resp is Array or resp.is_empty():
		return -1
	var agg: Dictionary = resp[0].get("result", {}).get("aggregateFields", {})
	var count_val = agg.get("count", {}).get("integerValue", "-1")
	var count: int = int(str(count_val))
	if count < 0:
		return -1
	return count + 1

# ── Firestore field helpers ────────────────────────────────────────────────
func _str(fields: Dictionary, key: String) -> String:
	return fields.get(key, {}).get("stringValue", "")

func _num(fields: Dictionary, key: String) -> float:
	var f: Dictionary = fields.get(key, {})
	if f.has("doubleValue"):
		return float(f["doubleValue"])
	if f.has("integerValue"):
		return float(f["integerValue"])
	return 0.0
