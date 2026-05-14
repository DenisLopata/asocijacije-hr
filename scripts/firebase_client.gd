extends Node

const API_KEY    := "AIzaSyAILvI4UH7mpAYhXbZb-2UdRwf-qO4TsAw"
const PROJECT_ID := "asocijacije-hr"

const _AUTH_URL    := "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=" + API_KEY
const _REFRESH_URL := "https://securetoken.googleapis.com/v1/token?key=" + API_KEY
const _FS_BASE     := "https://firestore.googleapis.com/v1/projects/" + PROJECT_ID + "/databases/(default)/documents"

var _id_token: String = ""
var _uid: String = ""

# ── Low-level HTTP ─────────────────────────────────────────────────────────
func _http(method: int, url: String, body: String, content_type: String, token: String = "") -> Variant:
	var http := HTTPRequest.new()
	add_child(http)
	var headers := PackedStringArray(["Content-Type: " + content_type])
	if token != "":
		headers.append("Authorization: Bearer " + token)
	if http.request(url, headers, method, body) != OK:
		http.queue_free()
		return null
	var data = await http.request_completed
	http.queue_free()
	var code: int = data[1]
	var text: String = (data[3] as PackedByteArray).get_string_from_utf8()
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
		push_warning("FirebaseClient: anonymous sign-in failed")
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

# ── Leaderboard write ──────────────────────────────────────────────────────
func submit_score(player_name: String, score: int, time_sec: float,
		mode: String, date_str: String, seed: int) -> bool:
	if not await ensure_authed():
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
	return resp != null

# ── Leaderboard read ───────────────────────────────────────────────────────
func fetch_leaderboard(mode: String, date_str: String, limit: int = 20) -> Array:
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
			"score": int(_str(fields, "score")),
			"time":  float(_num(fields, "time")),
			"uid":   _str(fields, "uid"),
		})
	return entries

# ── Firestore field helpers ────────────────────────────────────────────────
func _str(fields: Dictionary, key: String) -> String:
	return fields.get(key, {}).get("stringValue", fields.get(key, {}).get("integerValue", ""))

func _num(fields: Dictionary, key: String) -> float:
	var f: Dictionary = fields.get(key, {})
	if f.has("doubleValue"):
		return float(f["doubleValue"])
	if f.has("integerValue"):
		return float(f["integerValue"])
	return 0.0
