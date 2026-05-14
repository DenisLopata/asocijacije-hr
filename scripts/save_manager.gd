class_name SaveManager

const SAVE_PATH  := "user://save.cfg"
const PREFS_PATH := "user://prefs.cfg"

# ── Session save/load ──────────────────────────────────────────────────────
static func save_session(puzzles: Array, current_index: int, state: GameState) -> void:
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
		}
	}

static func clear_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_PATH)

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

# ── Preferences (persist across sessions) ─────────────────────────────────
static func save_prefs(tile_font_size: int, best_score: int = -1) -> void:
	var cfg := ConfigFile.new()
	cfg.load(PREFS_PATH)  # load existing so we don't wipe unrelated keys
	cfg.set_value("display", "tile_font_size", tile_font_size)
	if best_score >= 0:
		cfg.set_value("stats", "best_score", best_score)
	cfg.save(PREFS_PATH)

static func save_best_score(score: int) -> void:
	var cfg := ConfigFile.new()
	cfg.load(PREFS_PATH)
	var current: int = cfg.get_value("stats", "best_score", 0)
	if score > current:
		cfg.set_value("stats", "best_score", score)
		cfg.save(PREFS_PATH)

static func load_prefs() -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(PREFS_PATH) != OK:
		return {"tile_font_size": 17, "best_score": 0}
	return {
		"tile_font_size": cfg.get_value("display", "tile_font_size", 17),
		"best_score":     cfg.get_value("stats",   "best_score",     0),
	}
