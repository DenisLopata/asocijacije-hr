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

# ── Web: JavaScriptBridge → Firebase JS SDK ────────────────────────────────
# One stable dispatcher registered once; avoids per-call callback GC issues.
signal _js_response(ok: int, result: String)
var _js_dispatcher: JavaScriptObject  # held to prevent GC

func _ready() -> void:
	if OS.get_name() != "Web":
		return
	_js_dispatcher = JavaScriptBridge.create_callback(func(args):
		_js_response.emit(int(args[0]), str(args[1]))
	)
	JavaScriptBridge.get_interface("window")["__gfb_cb"] = _js_dispatcher

# Calls window[fn](arg0, arg1, ..., __gfb_cb).
# String args are stored as window.__ga_N to avoid any JS escaping.
func _js_call(fn: String, args: Array) -> Array:
	var w := JavaScriptBridge.get_interface("window")
	for i in args.size():
		w["__ga_%d" % i] = args[i]
	var arg_list := ",".join(
		Array(range(args.size())).map(func(i): return "window.__ga_%d" % i)
	)
	JavaScriptBridge.eval("window.%s(%s,window.__gfb_cb)" % [fn, arg_list], true)
	var r = await _js_response
	return r  # [ok_int, result_string]

# ── Non-web: raw HTTP via HTTPRequest ──────────────────────────────────────
func _http(method: int, url: String, body: String, content_type: String, token: String = "") -> Variant:
	var http := HTTPRequest.new()
	http.timeout = 10.0
	add_child(http)
	var headers := PackedStringArray(["Content-Type: " + content_type])
	if token != "":
		headers.append("Authorization: Bearer " + token)
	var req_err := http.request(url, headers, method, body)
	if req_err != OK:
		print("FirebaseClient: request() failed err=%d url=%s" % [req_err, url.left(60)])
		http.queue_free()
		return null
	var data = await http.request_completed
	http.queue_free()
	var code: int    = data[1]
	var text: String = (data[3] as PackedByteArray).get_string_from_utf8()
	if code < 200 or code >= 300:
		print("FirebaseClient HTTP %d: %s" % [code, text.left(300)])
		return null
	return JSON.parse_string(text)

func _post_json(url: String, body: Dictionary, token: String = "") -> Variant:
	return await _http(HTTPClient.METHOD_POST, url, JSON.stringify(body), "application/json", token)

func _post_form(url: String, body: String) -> Variant:
	return await _http(HTTPClient.METHOD_POST, url, body, "application/x-www-form-urlencoded")

# ── Auth (non-web only; JS SDK handles auth on web) ────────────────────────
func ensure_authed() -> bool:
	if OS.get_name() == "Web":
		return true  # Firebase JS SDK signs in automatically on first request
	if _id_token != "":
		return true

	var cfg := ConfigFile.new()
	if cfg.load(SaveManager.PREFS_PATH) == OK:
		var refresh_token: String = cfg.get_value("firebase", "refresh_token", "")
		_uid = cfg.get_value("firebase", "uid", "")
		if refresh_token != "":
			var refresh_resp = await _post_form(_REFRESH_URL,
				"grant_type=refresh_token&refresh_token=" + refresh_token)
			if refresh_resp != null and refresh_resp.has("id_token"):
				_id_token = refresh_resp["id_token"]
				return true

	var resp = await _post_json(_AUTH_URL, {"returnSecureToken": true})
	if resp == null or not resp.has("idToken"):
		print("FirebaseClient: anonymous sign-in failed — resp: %s" % str(resp))
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
	if OS.get_name() == "Web":
		return str(JavaScriptBridge.eval("window._fb_get_uid()", true))
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
		mode: String, date_str: String, puzzle_seed: int) -> bool:
	_last_error = ""

	if OS.get_name() == "Web":
		var r = await _js_call("_fb_submit",
			[player_name, score, time_sec, mode, date_str, puzzle_seed])
		if r[0] != 1:
			_last_error = r[1] if r[1] != "" else "network_error"
			print("FirebaseClient: submit_score failed — %s" % _last_error)
			return false
		_uid = r[1]  # JS returns uid on success
		_cache.erase(mode + "_" + date_str)
		mark_submitted(mode, date_str)
		return true

	# Non-web path
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
			"seed":  {"integerValue": str(puzzle_seed)},
		}
	}
	var resp = await _post_json(_FS_BASE + "/leaderboard", body, _id_token)
	if resp == null:
		_id_token = ""
		if not await ensure_authed():
			_last_error = "auth_failed"
			return false
		resp = await _post_json(_FS_BASE + "/leaderboard", body, _id_token)
	if resp == null:
		_last_error = "network_error"
		print("FirebaseClient: submit_score failed after retry")
		return false
	_cache.erase(mode + "_" + date_str)
	mark_submitted(mode, date_str)
	return true

# ── Leaderboard read ───────────────────────────────────────────────────────
func fetch_leaderboard(mode: String, date_str: String, limit: int = 20) -> Array:
	var cache_key := mode + "_" + date_str
	if _cache.has(cache_key):
		return _cache[cache_key]

	if OS.get_name() == "Web":
		var r = await _js_call("_fb_fetch_leaderboard", [mode, date_str, limit])
		if r[0] != 1:
			return []
		var raw = JSON.parse_string(r[1])
		if not raw is Array:
			return []
		var web_entries: Array = []
		for item in raw:
			if not item is Dictionary:
				continue
			web_entries.append({
				"name":  str(item.get("name", "")),
				"score": int(item.get("score", 0)),
				"time":  float(item.get("time", 0.0)),
				"uid":   str(item.get("uid", "")),
			})
		_cache[cache_key] = web_entries
		return web_entries

	# Non-web path
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

# ── Player rank ────────────────────────────────────────────────────────────
func fetch_player_rank(mode: String, date_str: String, score: int) -> int:
	if OS.get_name() == "Web":
		var r = await _js_call("_fb_fetch_rank", [mode, date_str, score])
		if r[0] != 1:
			return -1
		return int(r[1])

	# Non-web path
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

# ── Firestore field helpers (non-web path only) ────────────────────────────
func _str(fields: Dictionary, key: String) -> String:
	return fields.get(key, {}).get("stringValue", "")

func _num(fields: Dictionary, key: String) -> float:
	var f: Dictionary = fields.get(key, {})
	if f.has("doubleValue"):
		return float(f["doubleValue"])
	if f.has("integerValue"):
		return float(f["integerValue"])
	return 0.0
