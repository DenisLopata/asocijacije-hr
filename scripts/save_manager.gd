class_name SaveManager

const SAVE_PATH  := "user://save.cfg"
const PREFS_PATH := "user://prefs.cfg"

# ── Session save/load ──────────────────────────────────────────────────────
static func save_session(puzzles: Array, current_index: int, state: GameState,
		puzzle_times: Array = [], puzzle_scores: Array = [], puzzle_start_time: float = 0.0) -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("session", "current_index", current_index)
	cfg.set_value("session", "puzzle_count", puzzles.size())

	for i in puzzles.size():
		var puzzle: PuzzleData.Puzzle = puzzles[i]
		for j in puzzle.categories.size():
			var cat: PuzzleData.Category = puzzle.categories[j]
			cfg.set_value("puzzle_%d" % i, "cat_%d_name"  % j, cat.name)
			cfg.set_value("puzzle_%d" % i, "cat_%d_words" % j, Array(cat.words))
			cfg.set_value("puzzle_%d" % i, "cat_%d_diff"  % j, int(cat.difficulty))
			cfg.set_value("puzzle_%d" % i, "cat_%d_extra" % j, cat.extra)
			cfg.set_value("puzzle_%d" % i, "cat_%d_rank"  % j, cat.rank)

	var solved_names: Array = []
	for cat in state.solved_categories:
		solved_names.append(cat.name)
	cfg.set_value("state", "solved_names",       solved_names)
	cfg.set_value("state", "mistakes_remaining", state.mistakes_remaining)
	cfg.set_value("state", "hints_remaining",    state.hints_remaining)
	cfg.set_value("state", "hints_used",         state.hints_used)
	cfg.set_value("state", "hint_multiplier",    state.hint_multiplier)
	cfg.set_value("state", "score",              state.score)

	cfg.set_value("progress", "puzzle_times",      puzzle_times)
	cfg.set_value("progress", "puzzle_scores",     puzzle_scores)
	cfg.set_value("progress", "puzzle_start_time", puzzle_start_time)
	cfg.save(SAVE_PATH)

static func load_session() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return {}

	var puzzle_count: int = cfg.get_value("session", "puzzle_count", 0)
	if puzzle_count == 0:
		return {}

	var puzzles: Array = []
	for i in puzzle_count:
		var cats: Array = []
		for j in 4:
			var name: String = cfg.get_value("puzzle_%d" % i, "cat_%d_name" % j, "")
			if name.is_empty():
				break
			var words_raw: Array = cfg.get_value("puzzle_%d" % i, "cat_%d_words" % j, [])
			var diff: int        = cfg.get_value("puzzle_%d" % i, "cat_%d_diff"  % j, 0)
			var extra: String    = cfg.get_value("puzzle_%d" % i, "cat_%d_extra" % j, "")
			var typed_words: Array[String] = []
			typed_words.assign(words_raw)
			var rank: int = cfg.get_value("puzzle_%d" % i, "cat_%d_rank" % j, 2)
			var cat := PuzzleData.Category.new(name, typed_words, diff as PuzzleData.Difficulty)
			cat.extra = extra
			cat.rank  = rank
			cats.append(cat)
		if cats.size() == 4:
			puzzles.append(PuzzleData.Puzzle.new("Slagalica #%d" % (i + 1), cats))

	if puzzles.size() != puzzle_count:
		return {}

	return {
		"puzzles":       puzzles,
		"current_index": cfg.get_value("session", "current_index", 0),
		"state": {
			"solved_names":       cfg.get_value("state", "solved_names",       []),
			"mistakes_remaining": cfg.get_value("state", "mistakes_remaining", GameState.MAX_MISTAKES),
			"hints_remaining":    cfg.get_value("state", "hints_remaining",    GameState.MAX_HINTS),
			"hints_used":         cfg.get_value("state", "hints_used",         0),
			"hint_multiplier":    cfg.get_value("state", "hint_multiplier",    1.0),
			"score":              cfg.get_value("state", "score",              0),
		},
		"puzzle_times":       cfg.get_value("progress", "puzzle_times",      []),
		"puzzle_scores":      cfg.get_value("progress", "puzzle_scores",     []),
		"puzzle_start_time":  cfg.get_value("progress", "puzzle_start_time", 0.0),
	}

static func clear_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# ── Preferences (persist across sessions) ─────────────────────────────────
static func _cfg_load(cfg: ConfigFile, path: String) -> void:
	var err := cfg.load(path)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		push_warning("SaveManager: unexpected load error %d for %s" % [err, path])

static func save_prefs(tile_font_size: int, best_score: int = -1) -> void:
	var cfg := ConfigFile.new()
	_cfg_load(cfg, PREFS_PATH)
	cfg.set_value("display", "tile_font_size", tile_font_size)
	if best_score >= 0:
		cfg.set_value("stats", "best_score", best_score)
	cfg.save(PREFS_PATH)

static func save_best_score(score: int) -> void:
	var cfg := ConfigFile.new()
	_cfg_load(cfg, PREFS_PATH)
	var current: int = cfg.get_value("stats", "best_score", 0)
	if score > current:
		cfg.set_value("stats", "best_score", score)
		cfg.save(PREFS_PATH)

static func save_puzzle_start(timestamp: float) -> void:
	var cfg := ConfigFile.new()
	_cfg_load(cfg, SAVE_PATH)
	cfg.set_value("progress", "puzzle_start_time", timestamp)
	cfg.save(SAVE_PATH)

static func load_puzzle_start() -> float:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return 0.0
	return cfg.get_value("progress", "puzzle_start_time", 0.0)

static func save_daily_result(date_str: String, score: int, time_sec: float) -> void:
	_write_result("daily_single", date_str, score, time_sec)

static func load_daily_result(date_str: String) -> Dictionary:
	return _read_result("daily_single", date_str)

static func save_five_result(date_str: String, score: int, time_sec: float) -> void:
	_write_result("daily_five", date_str, score, time_sec)

static func load_five_result(date_str: String) -> Dictionary:
	return _read_result("daily_five", date_str)

static func _write_result(section: String, date_str: String, score: int, time_sec: float) -> void:
	var cfg := ConfigFile.new()
	_cfg_load(cfg, PREFS_PATH)
	cfg.set_value(section, date_str + "_score", score)
	cfg.set_value(section, date_str + "_time",  time_sec)
	cfg.save(PREFS_PATH)

static func _read_result(section: String, date_str: String) -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(PREFS_PATH) != OK:
		return {}
	var score: int = cfg.get_value(section, date_str + "_score", -1)
	if score < 0:
		return {}
	return {
		"score": score,
		"time":  cfg.get_value(section, date_str + "_time", 0.0),
	}

static func get_today() -> Dictionary:
	var d := Time.get_date_dict_from_system()
	var daily_seed: int = d["year"] * 10000 + d["month"] * 100 + d["day"]
	return {
		"date_str":   "%d-%02d-%02d" % [d["year"], d["month"], d["day"]],
		"date_label": "%d.%02d.%d."  % [d["day"], d["month"], d["year"]],
		"daily_seed": daily_seed,
		"five_seed":  daily_seed + 1,
	}

static func update_streak(date_str: String, mode: String = "daily") -> void:
	var section := "streak_" + mode
	var cfg := ConfigFile.new()
	_cfg_load(cfg, PREFS_PATH)
	var last: String = cfg.get_value(section, "last_date", "")
	var count: int   = cfg.get_value(section, "count", 0)
	if last == date_str:
		return  # already counted today
	var yesterday := _yesterday(date_str)
	count = count + 1 if last == yesterday else 1
	cfg.set_value(section, "last_date", date_str)
	cfg.set_value(section, "count", count)
	cfg.save(PREFS_PATH)

static func load_streak(mode: String = "daily") -> int:
	var section := "streak_" + mode
	var cfg := ConfigFile.new()
	if cfg.load(PREFS_PATH) != OK:
		return 0
	var last: String = cfg.get_value(section, "last_date", "")
	if last.is_empty():
		return 0
	var today: String = get_today()["date_str"]
	var yesterday := _yesterday(today)
	if last != today and last != yesterday:
		return 0  # streak expired
	return cfg.get_value(section, "count", 0)

static func _yesterday(date_str: String) -> String:
	var parts := date_str.split("-")
	var unix := Time.get_unix_time_from_datetime_dict({
		"year": int(parts[0]), "month": int(parts[1]), "day": int(parts[2]),
		"hour": 12, "minute": 0, "second": 0
	})
	var d := Time.get_date_dict_from_unix_time(unix - 86400)
	return "%d-%02d-%02d" % [d["year"], d["month"], d["day"]]

static func load_prefs() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(PREFS_PATH) != OK:
		return {"tile_font_size": 17, "best_score": 0}
	return {
		"tile_font_size": cfg.get_value("display", "tile_font_size", 17),
		"best_score":     cfg.get_value("stats",   "best_score",     0),
	}
