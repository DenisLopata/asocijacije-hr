extends Control

# ── Animation timings (seconds) ────────────────────────────────────────────
const ANIM_SWEEP        := 0.14
const ANIM_FLASH        := 0.10
const ANIM_SETTLE       := 0.10
const ANIM_TILE_FADE    := 0.18
const ANIM_TILE_STAGGER := 0.06
const ANIM_SHAKE        := 0.35
const ANIM_DOT_POP      := 0.08
const ANIM_DOT_SHRINK   := 0.12
const ANIM_DOT_STAGGER  := 0.05
const ANIM_OVERLAY_IN   := 0.22
const ANIM_FEEDBACK_POP := 0.20
const ANIM_SOLVED_ROW   := 0.30
const ANIM_PRESS_DIP    := 0.07
const ANIM_PRESS_RISE   := 0.13
const ANIM_SCORE           := 0.45
const ANIM_FADE_OUT        := 0.35
const ANIM_FEEDBACK_SLIDE  := 0.28
const FEEDBACK_AUTO_HIDE     := 10.0
const FEEDBACK_ONE_AWAY_HIDE := 10.0
const FEEDBACK_MAX_SLOTS     := 2

enum FeedbackType { CORRECT, WRONG, ONE_AWAY, HINT, END }

# ── Palette ────────────────────────────────────────────────────────────────
const C_BG          := Color(0.07, 0.08, 0.11)
const C_SURFACE     := Color(0.13, 0.14, 0.18)
const C_TILE_NORMAL := Color(0.17, 0.19, 0.25)
const C_TILE_HOVER  := Color(0.22, 0.24, 0.32)
const C_TILE_SEL    := Color(0.22, 0.24, 0.35)
const C_SEL_BORDER  := Color(0.55, 0.75, 1.00)
const C_TEXT        := Color(0.96, 0.96, 0.98)
const C_TEXT_DIM    := Color(0.55, 0.56, 0.62)
const C_ACCENT      := Color(0.45, 0.55, 1.00)
const C_SUBMIT_OFF  := Color(0.22, 0.23, 0.30)
const C_SUBMIT_ON   := Color(0.28, 0.60, 0.42)
const C_MISTAKE_ON  := Color(0.95, 0.78, 0.25)
const C_MISTAKE_OFF := Color(0.22, 0.23, 0.28)
const C_WIN         := Color(0.30, 0.85, 0.55)
const C_LOSE        := Color(0.90, 0.35, 0.35)
const C_ONE_AWAY    := Color(0.95, 0.65, 0.20)

const TILE_H      : int = 96
const TILE_FONT   : int = 22
const BTN_FONT    : int = 18
const RADIUS_TILE : int = 14
const RADIUS_BTN  : int = 22
const BORDER_SEL  : int = 3

const FONT_PATH      := "res://assets/fonts/Outfit-VariableFont_wght.ttf"
const ICON_FONT_PATH := "res://assets/fonts/MaterialSymbolsOutlined.ttf"

# Material Symbols Outlined codepoints -- use char() to avoid source encoding issues
func _icon(icon_name: String) -> String:
	const CP := {
		"settings":  0xE8B8,
		"shuffle":   0xE043,
		"close":     0xE5CD,
		"done":      0xE876,
		"lightbulb": 0xE90F,
		"back":      0xE5C4,
		"prev":      0xE5CB,
		"next":      0xE5CC,
		"refresh":   0xE5D5,
		"menu":      0xE5D2,
		"star":      0xF09A,
		"cancel":    0xE888,
		"undo":      0xE166,
	}
	return char(CP.get(icon_name, 0x3F))

const SPARKLE_INTENSITY: Dictionary = {
	PuzzleData.Difficulty.YELLOW: 0.0,
	PuzzleData.Difficulty.GREEN:  0.04,
	PuzzleData.Difficulty.BLUE:   0.08,
	PuzzleData.Difficulty.PURPLE: 0.14,
}

const SHIMMER_SHADER := "
shader_type canvas_item;

uniform float spawn_time        = 0.0;
uniform float sparkle_intensity = 0.0;

void fragment() {
	float age = TIME - spawn_time;

	// One-shot diagonal sweep (first 1.0s)
	float diag       = UV.x * 0.65 + UV.y * 0.35;
	float sweep_dist = diag - age / 1.0;
	float sweep      = exp(-sweep_dist * sweep_dist * 28.0)
	                 * smoothstep(1.0, 0.3, age) * 0.18;

	// Slow breathing (permanent)
	float glow = (sin(TIME * 0.7 + 1.2) * 0.5 + 0.5) * 0.022;

	// Star twinkles — tight gaussian + fast sharp flicker
	float sparks = 0.0;
	if (sparkle_intensity > 0.001) {
		for (int i = 0; i < 8; i++) {
			float fi    = float(i);
			float speed = 1.2 + fi * 0.4;
			float px    = fract(sin(fi * 127.1 + 43.2) * 4375.5);
			float py    = fract(sin(fi * 311.7 + 12.8) * 5765.1);
			float life  = sin(fract(TIME * speed + fi * 0.618) * 3.14159);
			float dx    = UV.x - px;
			float dy    = UV.y - py;
			sparks += exp(-(dx*dx + dy*dy) * 4500.0) * life * life * life;
		}
		sparks *= sparkle_intensity * 0.35;
	}

	// Add brightness on top of the existing stylebox color
	COLOR.rgb += sweep + glow + sparks;
}
"

const VIGNETTE_SHADER := "
shader_type canvas_item;
void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float v = dot(uv, uv);
	float alpha = smoothstep(0.4, 1.6, v) * 0.50;
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
"

const BG_SHADER := "
shader_type canvas_item;
void fragment() {
	vec2 uv = UV;
	float t = TIME * 0.05;

	vec3 base = mix(vec3(0.08, 0.09, 0.14), vec3(0.04, 0.04, 0.08), uv.y);

	vec2 p1 = vec2(0.20 + sin(t * 0.71) * 0.10, 0.18 + cos(t * 0.53) * 0.08);
	vec2 p2 = vec2(0.78 + cos(t * 0.67) * 0.09, 0.52 + sin(t * 0.41) * 0.13);
	vec2 p3 = vec2(0.48 + sin(t * 0.37) * 0.07, 0.82 + cos(t * 0.29) * 0.05);

	float b1 = smoothstep(0.50, 0.0, length(uv - p1));
	float b2 = smoothstep(0.45, 0.0, length(uv - p2));
	float b3 = smoothstep(0.38, 0.0, length(uv - p3));

	vec3 col = base;
	col += vec3(0.10, 0.05, 0.25) * b1 * 0.20;
	col += vec3(0.03, 0.10, 0.24) * b2 * 0.16;
	col += vec3(0.15, 0.04, 0.18) * b3 * 0.14;

	COLOR = vec4(col, 1.0);
}
"

# ── State ──────────────────────────────────────────────────────────────────
var _state: GameState
var _state_generation: int = 0
var _puzzles: Array
var _current_puzzle_index: int = 0
var _session_scores: Array[int] = []
var _session_best: int = 0
var _tile_font_override: int = 0
var _is_daily: bool = false
var _is_five_daily: bool = false

var _grid: GridContainer
var _mistake_dots: Array[Panel] = []
var _submit_btn: Button
var _deselect_btn: Button
var _shuffle_btn: Button
var _hint_btn: Button
var _solved_container: VBoxContainer
var _feedback_container: VBoxContainer
var _active_feedbacks: Array[Control] = []
var _mistakes_row_node: Control
var _action_row_node: Control
var _summary_action_row: HBoxContainer
var _summary_container: VBoxContainer
var _timer_label: Label
var _timer_running: bool = false
var _puzzle_stars: Label
var _session_label: Label
var _tile_buttons: Dictionary = {}
var _score_label: Label
var _score_display: int = 0

var _puzzle_times: Array[float] = []
var _puzzle_scores: Array[int] = []
var _puzzle_start_time: float = 0.0

var _overlay: Control = null
var _overlay_tag: String = ""
var _fade_rect: ColorRect


# ── Boot ───────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_D and event.ctrl_pressed and not event.shift_pressed:
			_debug_skip_to_leaderboard()
		elif event.keycode == KEY_D and event.ctrl_pressed and event.shift_pressed:
			_debug_clear_daily()

func _debug_clear_daily() -> void:
	var date_str: String = SaveManager.get_today()["date_str"]
	var cfg := ConfigFile.new()
	cfg.load(SaveManager.PREFS_PATH)
	cfg.erase_section_key("daily_single", date_str + "_score")
	cfg.erase_section_key("daily_single", date_str + "_time")
	cfg.erase_section_key("daily_five",   date_str + "_score")
	cfg.erase_section_key("daily_five",   date_str + "_time")
	cfg.save(SaveManager.PREFS_PATH)
	print("[DEBUG] Cleared daily results for ", date_str)

func _debug_skip_to_leaderboard() -> void:
	if _is_daily:
		_puzzle_scores = [980]
		_puzzle_times  = [42.3]
	else:
		_puzzle_scores = [980, 750, 600, 880, 1100]
		_puzzle_times  = [42.3, 67.8, 95.1, 38.6, 51.2]
	_show_name_picker()

func _ready() -> void:
	_register_theme_variations()

	var prefs := SaveManager.load_prefs()
	_tile_font_override = prefs.get("tile_font_size", 0)
	_session_best = prefs.get("best_score", 0)

	if get_tree().has_meta("daily_seed"):
		_is_daily = true
		var daily_seed: int = get_tree().get_meta("daily_seed")
		get_tree().remove_meta("daily_seed")
		seed(daily_seed)
		_puzzles = [PuzzleData.get_single_puzzle()]
		_build_ui()
		_load_puzzle(_current_puzzle_index)
	elif get_tree().has_meta("five_seed"):
		_is_five_daily = true
		var five_seed: int = get_tree().get_meta("five_seed")
		get_tree().remove_meta("five_seed")
		seed(five_seed)
		_puzzles = PuzzleData.get_puzzles()
		_build_ui()
		_load_puzzle(_current_puzzle_index)
	else:
		var saved := SaveManager.load_session()
		if saved.size() > 0:
			_puzzles = saved["puzzles"]
			_current_puzzle_index = saved["current_index"]
			_build_ui()
			_load_puzzle(_current_puzzle_index)
			_restore_state(saved["state"])
		else:
			_puzzles = PuzzleData.get_puzzles()
			_build_ui()
			_load_puzzle(_current_puzzle_index)

func _restore_state(data: Dictionary) -> void:
	_state.mistakes_remaining = data["mistakes_remaining"]
	_state.hints_remaining    = data["hints_remaining"]
	_state.hints_used         = data["hints_used"]
	_state.hint_multiplier    = data.get("hint_multiplier", 1.0)
	_state.score              = data["score"]

	for cat in _state.puzzle.categories:
		if cat.name in data["solved_names"]:
			_state.solved_categories.append(cat)
			_add_solved_row(cat)

	var used: int = GameState.MAX_MISTAKES - _state.mistakes_remaining
	for i in GameState.MAX_MISTAKES:
		_set_dot_active(_mistake_dots[i], i >= used)

	_score_display = _state.score
	_score_label.text = "Bodovi: %d" % _state.score
	_update_hint_btn()
	_rebuild_grid()
	# Restore visual selection state after grid is rebuilt (#3)
	_on_selection_changed(_state.selected_words)

func _register_theme_variations() -> void:
	if not theme:
		return
	theme.set_type_variation("TileButton",          &"Button")
	theme.set_type_variation("GhostButton",         &"Button")
	theme.set_type_variation("HintButton",          &"Button")
	theme.set_type_variation("FeedbackPanel",       &"PanelContainer")
	theme.set_type_variation("TitleLabel",          &"Label")
	theme.set_type_variation("SubtitleLabel",       &"Label")
	theme.set_type_variation("MetaLabel",           &"Label")
	theme.set_type_variation("ScoreLabel",          &"Label")
	theme.set_type_variation("FeedbackLabel",       &"Label")
	theme.set_type_variation("SolvedCategoryLabel", &"Label")
	theme.set_type_variation("SolvedWordsLabel",    &"Label")

# ── UI construction ────────────────────────────────────────────────────────
func _build_ui() -> void:
	_add_bg()

	var margin: MarginContainer = MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   28)
	margin.add_theme_constant_override("margin_right",  28)
	margin.add_theme_constant_override("margin_top",    20)
	margin.add_theme_constant_override("margin_bottom", 20)
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)

	# Outer VBox: header (fixed) + scroll area (expand) + buttons (fixed)
	var outer_vbox: VBoxContainer = VBoxContainer.new()
	outer_vbox.add_theme_constant_override("separation", 16)
	margin.add_child(outer_vbox)

	_build_header(outer_vbox)

	# Scrollable middle section (#12)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer_vbox.add_child(scroll)

	var inner_vbox: VBoxContainer = VBoxContainer.new()
	inner_vbox.add_theme_constant_override("separation", 16)
	inner_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(inner_vbox)

	_build_solved_area(inner_vbox)
	_build_grid_area(inner_vbox)
	_build_feedback_area(inner_vbox)
	_build_mistakes_row(inner_vbox)

	var summary_margin: MarginContainer = MarginContainer.new()
	summary_margin.add_theme_constant_override("margin_top",    16)
	summary_margin.add_theme_constant_override("margin_bottom", 16)
	summary_margin.visible = false
	inner_vbox.add_child(summary_margin)

	_summary_container = VBoxContainer.new()
	_summary_container.add_theme_constant_override("separation", 14)
	summary_margin.add_child(_summary_container)

	_summary_action_row = HBoxContainer.new()
	_summary_action_row.alignment = BoxContainer.ALIGNMENT_CENTER
	_summary_action_row.add_theme_constant_override("separation", 10)
	_summary_action_row.visible = false
	outer_vbox.add_child(_summary_action_row)

	_build_action_buttons(outer_vbox)
	_build_nav_row(outer_vbox)

	# Fade overlay — always topmost
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 1)
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)
	# Fade in from black on scene load
	var fade_in: Tween = create_tween()
	fade_in.tween_property(_fade_rect, "modulate:a", 0.0, 0.30)

func _add_bg() -> void:
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg_mat := ShaderMaterial.new()
	var bg_shader := Shader.new()
	bg_shader.code = BG_SHADER
	bg_mat.shader = bg_shader
	bg.material = bg_mat
	add_child(bg)

	# Subtle vignette overlay (#20)
	var vignette: ColorRect = ColorRect.new()
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = VIGNETTE_SHADER
	mat.shader = shader
	vignette.material = mat
	add_child(vignette)

func _build_header(parent: VBoxContainer) -> void:
	var meta_row: HBoxContainer = HBoxContainer.new()
	meta_row.alignment = BoxContainer.ALIGNMENT_CENTER
	meta_row.add_theme_constant_override("separation", 24)
	parent.add_child(meta_row)

	_timer_label = Label.new()
	_timer_label.theme_type_variation = "MetaLabel"
	_timer_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_timer_label.text = "0s"
	meta_row.add_child(_timer_label)

	_puzzle_stars = Label.new()
	_puzzle_stars.theme_type_variation = "MetaLabel"
	_puzzle_stars.add_theme_font_override("font", _icon_font())
	_puzzle_stars.add_theme_font_size_override("font_size", 16)
	meta_row.add_child(_puzzle_stars)

	_score_label = Label.new()
	_score_label.theme_type_variation = "ScoreLabel"
	_score_label.text = "Bodovi: 0"
	meta_row.add_child(_score_label)

	_session_label = Label.new()
	_session_label.theme_type_variation = "MetaLabel"
	_session_label.text = ""
	meta_row.add_child(_session_label)

	var settings_btn: Button = Button.new()
	settings_btn.text = _icon("settings")
	settings_btn.add_theme_font_override("font", _icon_font())
	settings_btn.add_theme_font_size_override("font_size", 24)
	settings_btn.custom_minimum_size = Vector2(44, 44)
	settings_btn.theme_type_variation = "GhostButton"
	settings_btn.pressed.connect(_on_settings)
	meta_row.add_child(settings_btn)

func _build_solved_area(parent: VBoxContainer) -> void:
	_solved_container = VBoxContainer.new()
	_solved_container.add_theme_constant_override("separation", 9)
	parent.add_child(_solved_container)

func _build_grid_area(parent: VBoxContainer) -> void:
	_grid = GridContainer.new()
	_grid.columns = 4
	_grid.add_theme_constant_override("h_separation", 9)
	_grid.add_theme_constant_override("v_separation", 9)
	parent.add_child(_grid)

func _build_feedback_area(parent: VBoxContainer) -> void:
	_feedback_container = VBoxContainer.new()
	_feedback_container.add_theme_constant_override("separation", 6)
	parent.add_child(_feedback_container)

func _build_mistakes_row(parent: VBoxContainer) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	parent.add_child(row)
	_mistakes_row_node = row

	var lbl: Label = Label.new()
	lbl.text = "Preostale greške:"
	lbl.theme_type_variation = "SubtitleLabel"
	row.add_child(lbl)

	for i in GameState.MAX_MISTAKES:
		var dot: Panel = Panel.new()
		dot.custom_minimum_size = Vector2(32, 32)
		var style: StyleBoxFlat = _rounded_box(C_MISTAKE_ON, 16)
		dot.add_theme_stylebox_override("panel", style)
		row.add_child(dot)
		_mistake_dots.append(dot)

func _build_action_buttons(parent: VBoxContainer) -> void:
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)
	parent.add_child(vbox)
	_action_row_node = vbox

	_shuffle_btn  = _make_ghost_btn("Pomiješaj", "shuffle")
	_deselect_btn = _make_ghost_btn("Poništi", "undo")
	_submit_btn   = _make_submit_btn()
	_hint_btn     = _make_hint_btn()

	_shuffle_btn.pressed.connect(_on_shuffle)
	_deselect_btn.pressed.connect(_on_deselect)
	_submit_btn.pressed.connect(_on_submit)
	_hint_btn.pressed.connect(_on_hint)

	var top_row: HBoxContainer = HBoxContainer.new()
	top_row.alignment = BoxContainer.ALIGNMENT_CENTER
	top_row.add_theme_constant_override("separation", 10)
	vbox.add_child(top_row)
	top_row.add_child(_shuffle_btn)
	_shuffle_btn.theme_type_variation = "GhostButton"
	_shuffle_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(_deselect_btn)
	_deselect_btn.theme_type_variation = "GhostButton"
	_deselect_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bot_row: HBoxContainer = HBoxContainer.new()
	bot_row.alignment = BoxContainer.ALIGNMENT_CENTER
	bot_row.add_theme_constant_override("separation", 10)
	vbox.add_child(bot_row)
	bot_row.add_child(_hint_btn)
	_hint_btn.theme_type_variation = "HintButton"
	_hint_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bot_row.add_child(_submit_btn)
	_submit_btn.theme_type_variation = "GhostButton"
	_submit_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

func _build_nav_row(parent: VBoxContainer) -> void:
	var spacer: Control = Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	parent.add_child(spacer)

	var sep: ColorRect = ColorRect.new()
	sep.color = Color(1, 1, 1, 0.06)
	sep.custom_minimum_size = Vector2(0, 1)
	parent.add_child(sep)

	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	parent.add_child(row)

	var menu_btn: Button = _make_ghost_btn("Izbornik", "menu")
	menu_btn.pressed.connect(_go_to_menu)
	menu_btn.theme_type_variation = "GhostButton"
	row.add_child(menu_btn)

	if not _is_daily:
		var new_btn: Button = _make_ghost_btn("Novi set", "refresh")
		new_btn.pressed.connect(_on_new_set)
		new_btn.theme_type_variation = "GhostButton"
		row.add_child(new_btn)

# ── Puzzle loading ─────────────────────────────────────────────────────────
func _load_puzzle(index: int) -> void:
	_state_generation += 1  # invalidates any pending awaits from the old puzzle (#4, #9)
	_hide_summary()
	_state = GameState.new(_puzzles[index])
	_state.selection_changed.connect(_on_selection_changed)
	_state.guess_correct.connect(_on_guess_correct)
	_state.guess_wrong.connect(_on_guess_wrong)
	_state.hint_peek.connect(_on_hint_peek)
	_state.hint_word.connect(_on_hint_word)
	_state.hint_solve.connect(_on_hint_solve)
	_state.score_changed.connect(_on_score_changed)
	_state.game_won.connect(_on_game_won)
	_state.game_lost.connect(_on_game_lost)

	_puzzle_start_time = Time.get_unix_time_from_system()
	SaveManager.save_puzzle_start(_puzzle_start_time)

	_score_display = 0
	_score_label.text = "Bodovi: 0"

	for child in _solved_container.get_children():
		child.queue_free()

	# Stagger-in animation for mistake dots (#13)
	for i in GameState.MAX_MISTAKES:
		var dot: Panel = _mistake_dots[i]
		dot.modulate     = Color(1, 1, 1, 0)
		dot.scale        = Vector2(0.6, 0.6)
		dot.pivot_offset = dot.size / 2.0
		_set_dot_active(dot, true)
		var dt: Tween = create_tween().set_parallel(true)
		dt.tween_property(dot, "modulate", Color.WHITE, 0.25) \
			.set_delay(i * ANIM_DOT_STAGGER)
		dt.tween_property(dot, "scale", Vector2.ONE, 0.25) \
			.set_delay(i * ANIM_DOT_STAGGER) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	_hide_feedback()
	_submit_btn.disabled = true
	_deselect_btn.disabled = true
	_set_submit_ready(false)
	_update_hint_btn()

	_timer_label.text = "0s"
	_timer_running    = true
	_puzzle_stars.text = "  " + _difficulty_badge(_puzzles[index])
	_update_session_label()
	_rebuild_grid()

func _difficulty_badge(puzzle: PuzzleData.Puzzle) -> String:
	var total: int = 0
	for cat in puzzle.categories:
		total += cat.rank
	var avg: float = total / 4.0
	var s := _icon("star")
	if avg < 1.5:
		return s
	elif avg < 2.5:
		return s + s
	return s + s + s

func _rebuild_grid() -> void:
	for child in _grid.get_children():
		child.queue_free()
	_tile_buttons.clear()

	var words: Array[String] = _state.get_unsolved_words()
	words.shuffle()
	for word in words:
		var btn: Button = _make_tile(word)
		_grid.add_child(btn)
		btn.theme_type_variation = "TileButton"
		_tile_buttons[word] = btn

# ── Tile & button factories ────────────────────────────────────────────────
func _effective_font_size(word: String) -> int:
	var base: int = _tile_font_override if _tile_font_override > 0 else TILE_FONT
	if word.length() > 12:
		return maxi(base - 4, 15)
	elif word.length() > 8:
		return maxi(base - 2, 16)
	return base

func _make_tile(word: String) -> Button:
	var btn: Button = Button.new()
	btn.text = word.to_upper()
	btn.custom_minimum_size = Vector2(0, TILE_H)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.clip_text = false
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	btn.add_theme_font_size_override("font_size", _effective_font_size(word))

	btn.pressed.connect(func() -> void: _state.toggle_word(word))

	# Micro-bounce on press (#19)
	btn.button_down.connect(func() -> void:
		if is_instance_valid(btn):
			btn.pivot_offset = btn.size / 2.0
			var t := create_tween()
			t.tween_property(btn, "scale", Vector2(0.94, 0.94), ANIM_PRESS_DIP) \
				.set_trans(Tween.TRANS_SINE))
	btn.button_up.connect(func() -> void:
		if is_instance_valid(btn):
			btn.pivot_offset = btn.size / 2.0
			var t := create_tween()
			t.tween_property(btn, "scale", Vector2.ONE, ANIM_PRESS_RISE) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))

	return btn

func _icon_font() -> FontFile:
	return load(ICON_FONT_PATH) as FontFile

func _mixed_font(weight: int = 700) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = load(FONT_PATH)
	fv.variation_opentype = {"wght": weight}
	fv.fallbacks = [_icon_font()]
	return fv

func _make_ghost_btn(label: String, icon_name: String = "") -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(118, 60)
	if icon_name.is_empty():
		btn.text = label
	else:
		btn.text = _icon(icon_name) + "  " + label
		btn.add_theme_font_override("font", _mixed_font())
		btn.add_theme_font_size_override("font_size", 18)
	return btn

func _make_hint_btn() -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(138, 60)
	btn.text = _icon("lightbulb") + "  Hint  (%d)" % GameState.MAX_HINTS
	btn.add_theme_font_override("font", _mixed_font())
	btn.add_theme_font_size_override("font_size", 18)
	return btn

func _update_hint_btn() -> void:
	var left: int = _state.hints_remaining
	_hint_btn.text = _icon("lightbulb") + "  Hint  (%d)" % left
	_hint_btn.disabled = not _state.can_use_hint()

func _make_submit_btn() -> Button:
	var btn: Button = _make_ghost_btn("Potvrdi")
	_apply_submit_style(btn, false)
	return btn

func _set_submit_ready(is_ready: bool) -> void:
	_apply_submit_style(_submit_btn, is_ready)

func _apply_submit_style(btn: Button, is_ready: bool) -> void:
	var color: Color = C_SUBMIT_ON if is_ready else C_SUBMIT_OFF
	var normal: StyleBoxFlat = _rounded_box(color, RADIUS_BTN)
	if is_ready:
		normal.border_width_left   = 1
		normal.border_width_right  = 1
		normal.border_width_top    = 1
		normal.border_width_bottom = 1
		normal.border_color = C_WIN.lightened(0.2)
	btn.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = color.lightened(0.12)
	btn.add_theme_stylebox_override("hover", hover)

# ── Style helpers ──────────────────────────────────────────────────────────
func _tile_style_normal() -> StyleBoxFlat:
	return _rounded_box(C_TILE_NORMAL, RADIUS_TILE)

func _tile_style_selected() -> StyleBoxFlat:
	var s: StyleBoxFlat = _rounded_box(C_TILE_SEL, RADIUS_TILE)
	s.border_width_left   = BORDER_SEL
	s.border_width_right  = BORDER_SEL
	s.border_width_top    = BORDER_SEL
	s.border_width_bottom = BORDER_SEL
	s.border_color = C_SEL_BORDER
	return s

func _rounded_box(color: Color, radius: int) -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left     = radius
	s.corner_radius_top_right    = radius
	s.corner_radius_bottom_left  = radius
	s.corner_radius_bottom_right = radius
	s.content_margin_left   = 8
	s.content_margin_right  = 8
	s.content_margin_top    = 4
	s.content_margin_bottom = 4
	return s

func _set_dot_active(dot: Panel, active: bool) -> void:
	var color: Color = C_MISTAKE_ON if active else C_MISTAKE_OFF
	var style: StyleBoxFlat = _rounded_box(color, 11)
	if active:
		style.border_width_left   = 2
		style.border_width_right  = 2
		style.border_width_top    = 2
		style.border_width_bottom = 2
		style.border_color = C_MISTAKE_ON.lightened(0.3)
	dot.add_theme_stylebox_override("panel", style)

func _make_font(weight: int) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = load(FONT_PATH)
	fv.variation_opentype = {"wght": weight}
	return fv

# ── Feedback helpers ───────────────────────────────────────────────────────
const _FEEDBACK_CFG := {
	FeedbackType.CORRECT:  { "icon": "done",      "bg": Color(0.14, 0.26, 0.20), "accent": Color(0.30, 0.85, 0.55), "text": Color(0.75, 0.97, 0.82) },
	FeedbackType.WRONG:    { "icon": "cancel",    "bg": Color(0.26, 0.13, 0.14), "accent": Color(0.90, 0.35, 0.35), "text": Color(0.97, 0.72, 0.72) },
	FeedbackType.ONE_AWAY: { "icon": "close",     "bg": Color(0.26, 0.22, 0.10), "accent": Color(0.95, 0.65, 0.20), "text": Color(0.99, 0.88, 0.62) },
	FeedbackType.HINT:     { "icon": "lightbulb", "bg": Color(0.18, 0.20, 0.10), "accent": Color(0.95, 0.78, 0.25), "text": Color(0.99, 0.93, 0.70) },
	FeedbackType.END:      { "icon": "star",      "bg": Color(0.10, 0.17, 0.26), "accent": Color(0.45, 0.55, 1.00), "text": Color(0.80, 0.88, 1.00) },
}

func _show_typed_feedback(type: FeedbackType, msg: String, persistent: bool = false) -> void:
	# Evict oldest slot when full
	if _active_feedbacks.size() >= FEEDBACK_MAX_SLOTS:
		_dismiss_feedback_node(_active_feedbacks[0], true)

	var cfg: Dictionary = _FEEDBACK_CFG[type]
	var panel: PanelContainer = _make_feedback_panel(cfg, msg, persistent)
	_feedback_container.add_child(panel)
	_active_feedbacks.append(panel)

	panel.scale    = Vector2(1.0, 0.6)
	panel.modulate = Color(1, 1, 1, 0)
	var t: Tween = create_tween().set_parallel(true)
	t.tween_property(panel, "scale",    Vector2.ONE,  ANIM_FEEDBACK_SLIDE) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "modulate", Color.WHITE, ANIM_FEEDBACK_SLIDE * 0.8)

	if not persistent:
		var delay: float = FEEDBACK_ONE_AWAY_HIDE if type == FeedbackType.ONE_AWAY \
			else FEEDBACK_AUTO_HIDE
		_schedule_feedback_node_hide(panel, delay)

func _make_feedback_panel(cfg: Dictionary, msg: String, persistent: bool) -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP

	var bg_style: StyleBoxFlat = _rounded_box(cfg["bg"], RADIUS_TILE)
	bg_style.content_margin_top    = 12
	bg_style.content_margin_bottom = 12
	bg_style.content_margin_left   = 0
	bg_style.content_margin_right  = 0
	panel.add_theme_stylebox_override("panel", bg_style)

	var accent: ColorRect = ColorRect.new()
	accent.custom_minimum_size = Vector2(5, 0)
	accent.size_flags_vertical = Control.SIZE_EXPAND_FILL
	accent.color = cfg["accent"]

	var icon_lbl: Label = Label.new()
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.add_theme_font_override("font", _icon_font())
	icon_lbl.add_theme_font_size_override("font_size", 22)
	icon_lbl.custom_minimum_size = Vector2(40, 0)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.text = _icon(cfg["icon"])
	icon_lbl.add_theme_color_override("font_color", cfg["accent"])

	var text_lbl: Label = Label.new()
	text_lbl.theme_type_variation = "FeedbackLabel"
	text_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_lbl.text = msg
	text_lbl.add_theme_color_override("font_color", cfg["text"])

	var inner: HBoxContainer = HBoxContainer.new()
	inner.add_theme_constant_override("separation", 10)
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var pad_l: Control = Control.new()
	pad_l.custom_minimum_size = Vector2(12, 0)
	var pad_r: Control = Control.new()
	pad_r.custom_minimum_size = Vector2(12, 0)
	inner.add_child(pad_l)
	inner.add_child(icon_lbl)
	inner.add_child(text_lbl)
	inner.add_child(pad_r)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 0)
	hbox.add_child(accent)
	hbox.add_child(inner)
	panel.add_child(hbox)

	if not persistent:
		panel.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed:
				_dismiss_feedback_node(panel, false))

	return panel

func _dismiss_feedback_node(panel: Control, immediate: bool) -> void:
	if not is_instance_valid(panel):
		return
	_active_feedbacks.erase(panel)
	if immediate:
		panel.queue_free()
		return
	var t: Tween = create_tween()
	t.tween_property(panel, "modulate:a", 0.0, 0.18)
	await t.finished
	if is_instance_valid(panel):
		panel.queue_free()

func _schedule_feedback_node_hide(panel: Control, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(panel):
		_dismiss_feedback_node(panel, false)

func _hide_feedback() -> void:
	for p: Control in _active_feedbacks:
		if is_instance_valid(p):
			p.queue_free()
	_active_feedbacks.clear()

func _process(_delta: float) -> void:
	if _timer_running and _puzzle_start_time > 0.0:
		var elapsed := Time.get_unix_time_from_system() - _puzzle_start_time
		_timer_label.text = _fmt_time(elapsed)

# ── Signal handlers ────────────────────────────────────────────────────────
func _on_selection_changed(selected: Array[String]) -> void:
	for word in _tile_buttons:
		var btn: Button = _tile_buttons[word]
		if word in selected:
			var s: StyleBoxFlat = _tile_style_selected()
			btn.add_theme_stylebox_override("normal",  s)
			btn.add_theme_stylebox_override("hover",   s)
			btn.add_theme_stylebox_override("pressed", s)
		else:
			var s: StyleBoxFlat = _tile_style_normal()
			btn.add_theme_stylebox_override("normal",  s)
			btn.add_theme_stylebox_override("hover",   _rounded_box(C_TILE_HOVER, RADIUS_TILE))
			btn.add_theme_stylebox_override("pressed", _rounded_box(C_TILE_HOVER, RADIUS_TILE))
	var is_ready: bool = selected.size() == GameState.MAX_SELECTION
	_submit_btn.disabled = not is_ready
	_set_submit_ready(is_ready)
	_deselect_btn.disabled = selected.is_empty()

func _on_guess_correct(category: PuzzleData.Category) -> void:
	_show_typed_feedback(FeedbackType.CORRECT, "Točno!  —  " + category.name)
	_submit_btn.disabled = true
	_deselect_btn.disabled = true

	var solved_btns: Array[Button] = []
	for word in category.words:
		if _tile_buttons.has(word):
			solved_btns.append(_tile_buttons[word])

	# Phase 1: category-color sweep (#3)
	var cat_color: Color = PuzzleData.DIFFICULTY_COLORS[category.difficulty]
	var sweep_style: StyleBoxFlat = _rounded_box(cat_color.lightened(0.25), RADIUS_TILE)
	var sweep: Tween = create_tween().set_parallel(true)
	for btn in solved_btns:
		if is_instance_valid(btn):
			btn.pivot_offset = btn.size / 2.0
			btn.add_theme_stylebox_override("normal", sweep_style)
		sweep.tween_property(btn, "scale", Vector2(1.06, 1.06), ANIM_SWEEP) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	await sweep.finished

	# Phase 2: white flash
	var flash: Tween = create_tween().set_parallel(true)
	for btn in solved_btns:
		flash.tween_property(btn, "modulate", Color(1.5, 1.5, 1.5, 1.0), ANIM_FLASH)
	await flash.finished

	# Phase 3: settle
	var settle: Tween = create_tween().set_parallel(true)
	for btn in solved_btns:
		settle.tween_property(btn, "modulate", Color.WHITE, ANIM_SETTLE)
		settle.tween_property(btn, "scale", Vector2.ONE, ANIM_SETTLE)
	await settle.finished

	# Phase 4: staggered fade-out
	var fade: Tween = create_tween().set_parallel(true)
	for i in solved_btns.size():
		fade.tween_property(solved_btns[i], "modulate", Color(1, 1, 1, 0), ANIM_TILE_FADE) \
			.set_delay(i * ANIM_TILE_STAGGER).set_trans(Tween.TRANS_SINE)
	await fade.finished

	_rebuild_grid()
	_add_solved_row_animated(category)
	if not _is_daily:
		SaveManager.save_session.call_deferred(_puzzles, _current_puzzle_index, _state)  # (#27)

func _on_guess_wrong(words: Array[String], one_away: bool) -> void:  # (#5: use explicit words param)
	var used: int = GameState.MAX_MISTAKES - _state.mistakes_remaining
	for i in GameState.MAX_MISTAKES:
		_set_dot_active(_mistake_dots[i], i >= used)

	# Pop animation on the depleted dot
	if used > 0 and used <= _mistake_dots.size():
		var depleted: Panel = _mistake_dots[used - 1]
		depleted.pivot_offset = depleted.size / 2.0
		var pop: Tween = create_tween().set_parallel(true)
		pop.tween_property(depleted, "scale", Vector2(1.5, 1.5), ANIM_DOT_POP) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await pop.finished
		var shrink: Tween = create_tween()
		shrink.tween_property(depleted, "scale", Vector2.ONE, ANIM_DOT_SHRINK)

	# Red-flash the wrong tiles (#1 — layout-safe modulate approach)
	var btns: Array[Button] = []
	for word in words:
		if _tile_buttons.has(word):
			btns.append(_tile_buttons[word])
	_flash_tiles_wrong(btns)

	# Highlight the outlier tile in amber when one-away (#16)
	if one_away:
		var outlier: String = _state.get_one_away_outlier(words)
		if outlier != "" and _tile_buttons.has(outlier):
			var obtn: Button = _tile_buttons[outlier]
			var ot: Tween = create_tween()
			ot.tween_property(obtn, "modulate", Color(1.0, 0.65, 0.15, 1.0), 0.15)
			ot.tween_property(obtn, "modulate", Color.WHITE, 0.35)
		_show_typed_feedback(FeedbackType.ONE_AWAY, "Jedan pojam ne odgovara!")
	else:
		_show_typed_feedback(FeedbackType.WRONG, "Nije točno — pokušaj ponovo")

	if not _is_daily:
		SaveManager.save_session.call_deferred(_puzzles, _current_puzzle_index, _state)

func _flash_tiles_wrong(btns: Array[Button]) -> void:  # (#1)
	if btns.is_empty():
		return
	var t1: Tween = create_tween().set_parallel(true)
	for btn in btns:
		if is_instance_valid(btn):
			t1.tween_property(btn, "modulate", Color(1.3, 0.35, 0.35, 1.0), ANIM_FLASH) \
				.set_trans(Tween.TRANS_SINE)
	t1.tween_callback(func() -> void:
		var t2: Tween = create_tween().set_parallel(true)
		for btn in btns:
			if is_instance_valid(btn):
				t2.tween_property(btn, "modulate", Color.WHITE, ANIM_SETTLE * 2.5)) \
		.set_delay(ANIM_FLASH)

func _on_game_won() -> void:
	_timer_running = false
	var elapsed := Time.get_unix_time_from_system() - _puzzle_start_time
	_state.puzzle_time_sec = elapsed
	_puzzle_scores.append(_state.score)
	_puzzle_times.append(elapsed)
	var gen := _state_generation  # capture before await (#4)
	_show_typed_feedback(FeedbackType.END, "Čestitamo!  Riješili ste slagalicu!")
	_submit_btn.disabled = true
	_set_submit_ready(false)
	_record_session_score(_state.score)
	_spawn_confetti()  # (#17)
	await get_tree().create_timer(0.9).timeout
	if _state_generation != gen:  # navigated away during delay
		return
	_show_summary(true)

func _on_game_lost() -> void:
	_timer_running = false
	var elapsed := Time.get_unix_time_from_system() - _puzzle_start_time
	_state.puzzle_time_sec = elapsed
	_puzzle_scores.append(_state.score)
	_puzzle_times.append(elapsed)
	var gen := _state_generation
	_show_typed_feedback(FeedbackType.END, "Igra završena — ostali ste bez pokušaja")
	_submit_btn.disabled = true
	_set_submit_ready(false)
	_reveal_all()
	_record_session_score(_state.score)
	await get_tree().create_timer(1.0).timeout
	if _state_generation != gen:
		return
	_show_summary(false)

func _record_session_score(score: int) -> void:
	_session_scores.resize(_puzzles.size())  # cap at puzzle count (#7)
	_session_scores[_current_puzzle_index] = score
	var total: int = 0
	for s in _session_scores:
		total += s
	if total > _session_best:
		_session_best = total
		SaveManager.save_best_score(_session_best)
	_update_session_label()

func _update_session_label() -> void:
	_session_label.text = "Rekord: %d" % _session_best if _session_best > 0 else ""

# ── Solved rows ────────────────────────────────────────────────────────────
func _add_solved_row(category: PuzzleData.Category) -> void:
	var row: PanelContainer = PanelContainer.new()
	var diff_color: Color = PuzzleData.DIFFICULTY_COLORS[category.difficulty]
	var style: StyleBoxFlat = _rounded_box(diff_color, 12)
	style.content_margin_left   = 16
	style.content_margin_right  = 16
	style.content_margin_top    = 10
	style.content_margin_bottom = 10
	row.add_theme_stylebox_override("panel", style)
	row.custom_minimum_size = Vector2(0, 88 if not category.extra.is_empty() else 72)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 3)
	row.add_child(vbox)

	var cat_lbl: Label = Label.new()
	cat_lbl.text = category.name.to_upper()
	cat_lbl.theme_type_variation = "SolvedCategoryLabel"
	cat_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(cat_lbl)

	var words_lbl: Label = Label.new()
	words_lbl.text = "  /  ".join(category.words)
	words_lbl.theme_type_variation = "SolvedWordsLabel"
	words_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(words_lbl)

	if not category.extra.is_empty():
		var extra_lbl: Label = Label.new()
		extra_lbl.text = category.extra
		extra_lbl.theme_type_variation = "SolvedWordsLabel"
		extra_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		extra_lbl.add_theme_color_override("font_color", diff_color.darkened(0.55))
		vbox.add_child(extra_lbl)

	# Shimmer applied to the panel itself so it covers the full background (#18)
	var smat := ShaderMaterial.new()
	var sshader := Shader.new()
	sshader.code = SHIMMER_SHADER
	smat.shader = sshader
	smat.set_shader_parameter("spawn_time", Time.get_ticks_msec() / 1000.0)
	smat.set_shader_parameter("sparkle_intensity", SPARKLE_INTENSITY[category.difficulty])
	row.material = smat

	_solved_container.add_child(row)

func _reveal_all() -> void:
	for cat in _state.puzzle.categories:
		if cat not in _state.solved_categories:
			_add_solved_row(cat)
	_rebuild_grid()

func _add_solved_row_animated(category: PuzzleData.Category) -> void:
	_add_solved_row(category)
	var row: Control = _solved_container.get_child(_solved_container.get_child_count() - 1)
	row.pivot_offset = row.size / 2.0
	row.scale        = Vector2(0.85, 0.85)
	row.modulate     = Color(1, 1, 1, 0)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(row, "scale", Vector2.ONE, ANIM_SOLVED_ROW) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(row, "modulate", Color.WHITE, ANIM_SOLVED_ROW * 0.73) \
		.set_trans(Tween.TRANS_SINE)

# ── Summary overlay (#10, #11, #24) ───────────────────────────────────────
func _show_summary(won: bool) -> void:
	_hide_feedback()
	_grid.visible            = false
	_mistakes_row_node.visible = false
	_action_row_node.visible   = false

	var vbox: VBoxContainer = _summary_container

	# Clear any leftover content from a previous puzzle
	for child in vbox.get_children():
		child.queue_free()

	var summary := _state.get_puzzle_summary()

	# Title
	var title_lbl: Label = Label.new()
	title_lbl.text = "Čestitamo!" if won else "Igra završena"
	title_lbl.theme_type_variation = "TitleLabel"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 26)
	vbox.add_child(title_lbl)

	# Score
	var score_lbl: Label = Label.new()
	score_lbl.text = "Bodovi: %d" % summary["score"]
	score_lbl.theme_type_variation = "ScoreLabel"
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_lbl.add_theme_font_size_override("font_size", 32)
	score_lbl.add_theme_font_override("font", _make_font(700))
	score_lbl.add_theme_color_override("font_color", C_WIN if won else C_LOSE)
	vbox.add_child(score_lbl)

	_add_separator(vbox)

	# Stats
	for pair in [
		["Kategorije", "%d / %d" % [summary["solved_count"], summary["total_count"]]],
		["Greške",     "%d / %d" % [summary["mistakes_used"], GameState.MAX_MISTAKES]],
		["Hintovi",    "%d" % summary["hints_used"]],
	]:
		_add_stat_row(vbox, pair[0], pair[1])

	if _session_best > 0:
		var total: int = 0
		for s in _session_scores:
			total += s
		_add_stat_row(vbox, "Ukupno u skupu", "%d" % total)

	_add_separator(vbox)

	# Category breakdown
	var cat_scores: Dictionary = summary["category_scores"]
	for cat in _state.puzzle.categories:
		var solved: bool = cat in _state.solved_categories
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 10)
		vbox.add_child(row)

		var dot: Panel = Panel.new()
		dot.custom_minimum_size = Vector2(14, 14)
		var dot_color: Color = PuzzleData.DIFFICULTY_COLORS[cat.difficulty] if solved else C_MISTAKE_OFF
		dot.add_theme_stylebox_override("panel", _rounded_box(dot_color, 7))
		row.add_child(dot)

		var diff_lbl: Label = Label.new()
		diff_lbl.text = "[%s]  %s" % [PuzzleData.DIFFICULTY_LABELS[cat.difficulty], cat.name]
		diff_lbl.theme_type_variation = "SubtitleLabel"
		diff_lbl.add_theme_color_override("font_color", C_TEXT if solved else C_TEXT_DIM)
		diff_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(diff_lbl)

		var pts_lbl: Label = Label.new()
		if solved and cat.name in cat_scores:
			var pts: int = cat_scores[cat.name]
			pts_lbl.text = "%d bodova" % pts
			pts_lbl.add_theme_color_override("font_color", C_WIN if pts > 0 else C_TEXT_DIM)
		else:
			pts_lbl.text = "—"
			pts_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
		pts_lbl.theme_type_variation = "MetaLabel"
		row.add_child(pts_lbl)

	_add_separator(vbox)

	# Action button — lives outside the scroll so it's always visible
	for child in _summary_action_row.get_children():
		child.queue_free()

	if _current_puzzle_index < _puzzles.size() - 1:
		var next_btn: Button = _make_ghost_btn("Sljedeća slagalica", "next")
		next_btn.theme_type_variation = "GhostButton"
		next_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		next_btn.pressed.connect(func() -> void: _navigate_puzzle(1))
		_summary_action_row.add_child(next_btn)
	else:
		var finish_btn: Button = _make_ghost_btn("Završi i spremi")
		finish_btn.theme_type_variation = "GhostButton"
		finish_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		finish_btn.pressed.connect(_show_name_picker)
		_summary_action_row.add_child(finish_btn)

	_summary_action_row.visible = true

	# Fade in
	var wrapper: Control = _summary_container.get_parent()
	wrapper.modulate = Color(1, 1, 1, 0)
	wrapper.visible  = true
	var t: Tween = create_tween()
	t.tween_property(wrapper, "modulate", Color.WHITE, 0.25)

func _hide_summary() -> void:
	for child in _summary_container.get_children():
		child.queue_free()
	_summary_container.get_parent().visible = false
	_summary_action_row.visible = false
	for child in _summary_action_row.get_children():
		child.queue_free()
	_grid.visible              = true
	_mistakes_row_node.visible = true
	_action_row_node.visible   = true

# ── Name picker overlay ────────────────────────────────────────────────────
func _show_name_picker() -> void:
	_close_overlay()

	var dim: ColorRect = _make_dim()
	_overlay = dim
	_overlay_tag = "name_picker"

	var panel: PanelContainer = _make_overlay_panel(dim, 640)
	var vbox: VBoxContainer = _make_overlay_vbox(panel, 14)

	var header: Label = Label.new()
	header.text = "Unesite ime za ljestvicu"
	header.theme_type_variation = "TitleLabel"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 20)
	vbox.add_child(header)

	_add_separator(vbox)

	var name_display: Label = Label.new()
	name_display.text = ""
	name_display.theme_type_variation = "ScoreLabel"
	name_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_display.add_theme_font_size_override("font_size", 26)
	name_display.custom_minimum_size = Vector2(0, 44)
	vbox.add_child(name_display)

	var hint_lbl: Label = Label.new()
	hint_lbl.text = "4–10 znakova"
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_size_override("font_size", 13)
	hint_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	vbox.add_child(hint_lbl)

	_add_separator(vbox)

	# Use an Array as a mutable reference container so lambdas share state
	var name_buf: Array[String] = [""]
	# ok_btn_ref stored in an Array so lambdas capture the container by ref, not the null value
	var ok_btn_holder: Array[Button] = []

	const KEY_ROWS := [
		["0","1","2","3","4","5","6","7","8","9"],
		["A","B","C","Č","Ć","D","Đ","E","F","G"],
		["H","I","J","K","L","M","N","O","P","R"],
		["S","Š","T","U","V","Z","Ž"],
		["-"," "],
		["DEL","OK"],
	]

	var kbd_vbox := VBoxContainer.new()
	kbd_vbox.add_theme_constant_override("separation", 8)
	vbox.add_child(kbd_vbox)

	for row_chars in KEY_ROWS:
		var row_hbox := HBoxContainer.new()
		row_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
		row_hbox.add_theme_constant_override("separation", 8)
		row_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		kbd_vbox.add_child(row_hbox)

		for ch in row_chars:
			var btn := Button.new()
			btn.focus_mode = Control.FOCUS_NONE
			btn.add_theme_font_size_override("font_size", 18)

			var is_fn:  bool = ch == "DEL" or ch == "OK"
			var is_num: bool = ch.is_valid_int()
			var is_spc: bool = ch == " "

			# Key height is uniform; width expands to fill row
			btn.custom_minimum_size = Vector2(0, 58)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

			if is_fn:
				var key_color := C_SUBMIT_ON if ch == "OK" else C_SURFACE.lightened(0.05)
				var sb_n := _rounded_box(key_color, 8)
				sb_n.border_width_bottom = 3
				sb_n.border_color = key_color.darkened(0.35)
				btn.add_theme_stylebox_override("normal", sb_n)
				var sb_h := _rounded_box(key_color.lightened(0.08), 8)
				sb_h.border_width_bottom = 3
				sb_h.border_color = key_color.darkened(0.35)
				btn.add_theme_stylebox_override("hover", sb_h)
				var sb_p := _rounded_box(key_color.darkened(0.12), 8)
				sb_p.border_width_bottom = 1
				sb_p.border_color = key_color.darkened(0.35)
				sb_p.content_margin_top = 5
				btn.add_theme_stylebox_override("pressed", sb_p)
				btn.text = "⌫" if ch == "DEL" else ch
				btn.add_theme_font_size_override("font_size", 18)
				if ch == "OK":
					btn.add_theme_font_override("font", _make_font(700))
					btn.disabled = true
					ok_btn_holder.append(btn)
			else:
				var key_color: Color
				if is_num:
					key_color = C_SURFACE.lightened(0.06)
				elif is_spc:
					key_color = C_SURFACE.lightened(0.04)
				else:
					key_color = C_TILE_NORMAL
				var sb_n := _rounded_box(key_color, 8)
				sb_n.border_width_bottom = 3
				sb_n.border_color = key_color.darkened(0.40)
				btn.add_theme_stylebox_override("normal", sb_n)
				var sb_h := _rounded_box(key_color.lightened(0.08), 8)
				sb_h.border_width_bottom = 3
				sb_h.border_color = key_color.darkened(0.40)
				btn.add_theme_stylebox_override("hover", sb_h)
				var sb_p := _rounded_box(key_color.darkened(0.10), 8)
				sb_p.border_width_bottom = 1
				sb_p.border_color = key_color.darkened(0.40)
				sb_p.content_margin_top = 5
				btn.add_theme_stylebox_override("pressed", sb_p)
				btn.text = "SPC" if is_spc else ch

			var char_val: String = ch
			btn.pressed.connect(func() -> void:
				var ok_btn: Button = ok_btn_holder[0] if ok_btn_holder.size() > 0 else null
				if char_val == "DEL":
					if name_buf[0].length() > 0:
						name_buf[0] = name_buf[0].substr(0, name_buf[0].length() - 1)
						name_display.text = name_buf[0]
						if ok_btn and is_instance_valid(ok_btn):
							ok_btn.disabled = name_buf[0].length() < 4
				elif char_val == "OK":
					_on_name_confirmed(name_buf[0])
				else:
					if name_buf[0].length() < 10:
						name_buf[0] += char_val
						name_display.text = name_buf[0]
						if ok_btn and is_instance_valid(ok_btn):
							ok_btn.disabled = name_buf[0].length() < 4)
			row_hbox.add_child(btn)

	_animate_overlay_in(dim, panel)

func _on_name_confirmed(player_name: String) -> void:
	var total_score := 0
	var total_time := 0.0
	for s in _puzzle_scores:
		total_score += s
	for t in _puzzle_times:
		total_time += t

	var td          := SaveManager.get_today()
	var date_str    : String = td["date_str"]
	var daily_seed  : int    = td["daily_seed"]

	if _is_daily:
		SaveManager.save_daily_result(date_str, total_score, total_time)
		SaveManager.update_streak(date_str, "daily")
	elif _is_five_daily:
		SaveManager.save_five_result(date_str, total_score, total_time)
		SaveManager.update_streak(date_str, "five")

	SaveManager.clear_save()
	_close_overlay()

	if _is_daily or _is_five_daily:
		var mode         := "daily" if _is_daily else "five"
		var puzzle_seed  := daily_seed if _is_daily else daily_seed + 1
		_show_submitting_overlay(player_name, total_score, total_time, mode, date_str, puzzle_seed)
	else:
		_go_to_menu()

# ── Submitting / leaderboard overlays ─────────────────────────────────────
func _show_submitting_overlay(player_name: String, score: int, time_sec: float,
		mode: String, date_str: String, puzzle_seed: int) -> void:
	if FirebaseClient.was_submitted(mode, date_str):
		_show_leaderboard_overlay(mode, date_str, FirebaseClient.get_uid(), score, time_sec)
		return
	var dim := _make_dim()
	_overlay = dim
	_overlay_tag = "submitting"
	var panel := _make_overlay_panel(dim, 340)
	var vbox  := _make_overlay_vbox(panel, 18)

	var lbl := Label.new()
	lbl.text = "Slanje rezultata…"
	lbl.theme_type_variation = "TitleLabel"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", 20)
	vbox.add_child(lbl)

	_animate_overlay_in(dim, panel)

	var ok := await FirebaseClient.submit_score(player_name, score, time_sec, mode, date_str, puzzle_seed)
	if not is_instance_valid(dim):
		return

	if ok:
		_close_overlay()
		_show_leaderboard_overlay(mode, date_str, FirebaseClient.get_uid(), score, time_sec)
		return

	# Submission failed — show error with retry
	lbl.text = "Nema internetske veze." if FirebaseClient.get_last_error() == "auth_failed" else "Slanje nije uspjelo."
	lbl.add_theme_color_override("font_color", C_LOSE)

	var retry_btn := _make_ghost_btn("Pokušaj ponovo")
	retry_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	retry_btn.pressed.connect(func() -> void:
		_close_overlay()
		_show_submitting_overlay(player_name, score, time_sec, mode, date_str, puzzle_seed))
	vbox.add_child(retry_btn)

	var skip_btn := _make_ghost_btn("Odustani")
	skip_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	skip_btn.pressed.connect(func() -> void:
		_close_overlay()
		_go_to_menu())
	vbox.add_child(skip_btn)

func _show_leaderboard_overlay(mode: String, date_str: String, my_uid: String, my_score: int = -1, _my_time: float = 0.0) -> void:
	var dim := _make_dim()
	_overlay = dim
	_overlay_tag = "leaderboard"
	var panel := _make_overlay_panel(dim, 420)
	var vbox  := _make_overlay_vbox(panel, 12)

	var mode_label := "Dnevni izazov" if mode == "daily" else "Dnevnih 5"
	var header := Label.new()
	header.text = "Ljestvica — " + mode_label
	header.theme_type_variation = "TitleLabel"
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 20)
	vbox.add_child(header)

	var date_lbl := Label.new()
	var parts := date_str.split("-")
	date_lbl.text = "%s.%s.%s." % [parts[2], parts[1], parts[0]]
	date_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	date_lbl.add_theme_font_override("font", _make_font(500))
	date_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	date_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(date_lbl)

	_add_separator(vbox)

	var loading_lbl := Label.new()
	loading_lbl.text = "Učitavanje…"
	loading_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	loading_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	vbox.add_child(loading_lbl)

	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(loading_lbl, "modulate:a", 0.3, 0.65).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(loading_lbl, "modulate:a", 1.0, 0.65).set_trans(Tween.TRANS_SINE)

	_animate_overlay_in(dim, panel)

	var entries := await FirebaseClient.fetch_leaderboard(mode, date_str)
	if not is_instance_valid(loading_lbl):
		return

	pulse.kill()
	loading_lbl.queue_free()
	_add_separator(vbox)

	if entries.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "Nema rezultata."
		empty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
		vbox.add_child(empty_lbl)
	else:
		var scroll := ScrollContainer.new()
		scroll.custom_minimum_size = Vector2(0, 320)
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		vbox.add_child(scroll)

		var list := VBoxContainer.new()
		list.add_theme_constant_override("separation", 6)
		list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(list)

		var me_row: Control = null
		for i in entries.size():
			var is_me: bool = entries[i]["uid"] == my_uid
			var row := _make_leaderboard_row(i + 1, entries[i], is_me)
			list.add_child(row)
			if is_me:
				me_row = row
		if me_row != null:
			await get_tree().process_frame
			scroll.ensure_control_visible(me_row)

		var player_in_list: bool = entries.any(func(e): return e["uid"] == my_uid)
		if not player_in_list and my_score >= 0:
			var my_rank := await FirebaseClient.fetch_player_rank(mode, date_str, my_score)
			if my_rank > 0 and is_instance_valid(vbox):
				var rank_lbl := Label.new()
				rank_lbl.text = "Tvoje mjesto: #%d" % my_rank
				rank_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				rank_lbl.add_theme_color_override("font_color", C_ACCENT)
				vbox.add_child(rank_lbl)

	_add_separator(vbox)
	var close_btn := _make_ghost_btn("Zatvori")
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(func() -> void:
		_close_overlay()
		_go_to_menu())
	vbox.add_child(close_btn)

func _make_leaderboard_row(rank: int, entry: Dictionary, is_me: bool) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)

	var rank_lbl := Label.new()
	rank_lbl.text = "%d." % rank
	rank_lbl.custom_minimum_size = Vector2(32, 0)
	rank_lbl.add_theme_font_override("font", _make_font(700))
	var rank_color: Color
	if is_me:
		rank_color = C_ACCENT
	elif rank == 1:
		rank_color = Color(1.00, 0.84, 0.10)
	elif rank == 2:
		rank_color = Color(0.75, 0.76, 0.82)
	elif rank == 3:
		rank_color = Color(0.80, 0.52, 0.25)
	else:
		rank_color = C_TEXT_DIM
	rank_lbl.add_theme_color_override("font_color", rank_color)
	row.add_child(rank_lbl)

	var name_lbl := Label.new()
	name_lbl.text = entry["name"]
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_override("font", _make_font(700 if is_me else 600))
	row.add_child(name_lbl)

	var score_lbl := Label.new()
	score_lbl.text = "%d" % entry["score"]
	score_lbl.add_theme_color_override("font_color", C_WIN if is_me else C_TEXT)
	row.add_child(score_lbl)

	var time_lbl := Label.new()
	time_lbl.text = "  " + _fmt_time(entry["time"])
	time_lbl.add_theme_font_override("font", _make_font(500))
	time_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	time_lbl.add_theme_font_size_override("font_size", 13)
	row.add_child(time_lbl)

	if is_me:
		var row_bg := PanelContainer.new()
		row_bg.add_theme_stylebox_override("panel", _rounded_box(C_ACCENT.darkened(0.6), 8))
		row_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_bg.add_child(row)
		return row_bg
	return row

func _fmt_time(secs: float) -> String:
	var s: int = int(secs)
	if s < 60:
		return "%ds" % s
	var mins: int = s / 60
	return "%dm%02ds" % [mins, s % 60]

# ── Settings overlay (#14, #18) ────────────────────────────────────────────
func _on_settings() -> void:
	# Toggle: if settings is already open close it; close any other overlay too (#8)
	if _overlay and is_instance_valid(_overlay):
		_close_overlay()
		if _overlay_tag == "settings":
			return

	var dim: ColorRect = _make_dim()
	_overlay = dim
	_overlay_tag = "settings"

	var panel: PanelContainer = _make_overlay_panel(dim, 380)
	var vbox: VBoxContainer = _make_overlay_vbox(panel, 18)

	var title_lbl: Label = Label.new()
	title_lbl.text = "Postavke"
	title_lbl.theme_type_variation = "TitleLabel"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 22)
	vbox.add_child(title_lbl)

	_add_separator(vbox)

	# Font size (#14 — persisted)
	var fs_lbl: Label = Label.new()
	fs_lbl.text = "Veličina fonta pločica"
	fs_lbl.theme_type_variation = "SubtitleLabel"
	vbox.add_child(fs_lbl)

	var fs_row: HBoxContainer = HBoxContainer.new()
	fs_row.add_theme_constant_override("separation", 10)
	vbox.add_child(fs_row)

	for pair in [["Malo", 16], ["Srednje", 20], ["Veliko", 24]]:
		var fs_btn: Button = _make_ghost_btn(pair[0])
		fs_btn.theme_type_variation = "GhostButton"
		fs_btn.custom_minimum_size = Vector2(100, 44)
		var size_val: int = pair[1]
		fs_btn.pressed.connect(func() -> void:
			_tile_font_override = size_val
			_set_tile_font_size(size_val)
			SaveManager.save_prefs(size_val))  # (#14)
		fs_row.add_child(fs_btn)

	_add_separator(vbox)

	var save_lbl: Label = Label.new()
	save_lbl.text = "Pohrana igre"
	save_lbl.theme_type_variation = "SubtitleLabel"
	vbox.add_child(save_lbl)

	var save_info: Label = Label.new()
	save_info.text = "Napredak se automatski sprema." if SaveManager.has_save() else "Nema pohrane."
	save_info.theme_type_variation = "MetaLabel"
	vbox.add_child(save_info)

	var clear_btn: Button = _make_ghost_btn("Obriši pohranjeni napredak")
	clear_btn.theme_type_variation = "GhostButton"
	clear_btn.custom_minimum_size = Vector2(300, 46)
	clear_btn.pressed.connect(func() -> void:
		SaveManager.clear_save()
		save_info.text = "Napredak je obrisan.")
	vbox.add_child(clear_btn)

	_add_separator(vbox)

	var close_btn: Button = _make_ghost_btn("Zatvori")
	close_btn.theme_type_variation = "GhostButton"
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(_close_overlay)
	vbox.add_child(close_btn)

	_animate_overlay_in(dim, panel)

func _set_tile_font_size(tile_size: int) -> void:
	for word in _tile_buttons:
		var btn: Button = _tile_buttons[word]
		if is_instance_valid(btn):
			var fs: int = tile_size
			if word.length() > 12 and tile_size > 14:
				fs = tile_size - 4
			elif word.length() > 8 and tile_size > 14:
				fs = tile_size - 2
			btn.add_theme_font_size_override("font_size", fs)

# ── Overlay helpers ────────────────────────────────────────────────────────
func _close_overlay() -> void:
	if _overlay and is_instance_valid(_overlay):
		_overlay.queue_free()
	_overlay = null
	_overlay_tag = ""

func _make_dim() -> ColorRect:
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.65)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	return dim

func _make_overlay_panel(parent: Control, min_width: int) -> PanelContainer:
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(center)

	var panel: PanelContainer = PanelContainer.new()
	var style: StyleBoxFlat = _rounded_box(C_SURFACE, 20)
	style.content_margin_left   = 32
	style.content_margin_right  = 32
	style.content_margin_top    = 28
	style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(min_width, 0)
	center.add_child(panel)
	return panel

func _make_overlay_vbox(parent: Control, separation: int) -> VBoxContainer:
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", separation)
	parent.add_child(vbox)
	return vbox

func _add_separator(parent: VBoxContainer) -> void:
	var sep: ColorRect = ColorRect.new()
	sep.color = Color(1, 1, 1, 0.08)
	sep.custom_minimum_size = Vector2(0, 1)
	parent.add_child(sep)

func _add_stat_row(parent: VBoxContainer, key: String, value: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	parent.add_child(row)
	var k: Label = Label.new()
	k.text = key
	k.theme_type_variation = "SubtitleLabel"
	k.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(k)
	var v: Label = Label.new()
	v.text = value
	v.theme_type_variation = "ScoreLabel"
	v.add_theme_font_size_override("font_size", 17)
	row.add_child(v)

func _animate_overlay_in(dim: Control, panel: Control) -> void:
	panel.pivot_offset = panel.size / 2.0
	panel.scale        = Vector2(0.88, 0.88)
	panel.modulate     = Color(1, 1, 1, 0)
	dim.modulate   = Color(1, 1, 1, 0)
	var t: Tween = create_tween().set_parallel(true)
	t.tween_property(dim,   "modulate",       Color.WHITE,    ANIM_OVERLAY_IN)
	t.tween_property(panel, "scale",          Vector2.ONE,    ANIM_OVERLAY_IN * 1.27) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "modulate",       Color.WHITE,    ANIM_OVERLAY_IN)

# ── Confetti (#17) ────────────────────────────────────────────────────────
func _spawn_confetti() -> void:
	var particles := CPUParticles2D.new()
	particles.position            = get_viewport_rect().size * 0.5
	particles.emitting            = true
	particles.one_shot            = true
	particles.explosiveness       = 0.95
	particles.amount              = 90
	particles.lifetime            = 2.5
	particles.lifetime_randomness = 0.55
	particles.direction           = Vector2(0.0, -1.0)
	particles.spread              = 160.0
	particles.gravity             = Vector2(0.0, 220.0)
	particles.initial_velocity_min = 220.0
	particles.initial_velocity_max = 520.0
	particles.scale_amount_min    = 5.0
	particles.scale_amount_max    = 11.0
	particles.angle_min           = 0.0
	particles.angle_max           = 360.0
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max =  180.0

	var grad := Gradient.new()
	grad.set_color(0, PuzzleData.DIFFICULTY_COLORS[PuzzleData.Difficulty.YELLOW])
	grad.add_point(0.33, PuzzleData.DIFFICULTY_COLORS[PuzzleData.Difficulty.GREEN])
	grad.add_point(0.66, PuzzleData.DIFFICULTY_COLORS[PuzzleData.Difficulty.BLUE])
	grad.set_color(1,    PuzzleData.DIFFICULTY_COLORS[PuzzleData.Difficulty.PURPLE])
	particles.color_ramp = grad

	add_child(particles)
	await get_tree().create_timer(particles.lifetime + 0.5).timeout
	if is_instance_valid(particles):
		particles.queue_free()

# ── Button callbacks ───────────────────────────────────────────────────────
func _on_score_changed(total: int, gained: int) -> void:
	var tween: Tween = create_tween()
	tween.tween_method(func(v: int) -> void:
		_score_label.text = "Bodovi: %d" % v, _score_display, total, ANIM_SCORE) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_score_display = total
	if gained > 0:
		_score_label.add_theme_color_override("font_color", C_WIN)
		var restore: Tween = create_tween()
		restore.tween_interval(0.6)
		restore.tween_callback(func() -> void:
			_score_label.add_theme_color_override("font_color", C_ACCENT))

func _on_hint() -> void:
	_state.use_hint()

func _on_hint_peek(category_name: String, hints_left: int) -> void:
	_show_typed_feedback(FeedbackType.HINT, "Jedna kategorija je: \"%s\"  —  još %d hint" % [category_name, hints_left])
	_update_hint_btn()

func _on_hint_word(category_name: String, word: String, hints_left: int) -> void:
	_show_typed_feedback(FeedbackType.HINT, "Riječ \"%s\" pripada kategoriji \"%s\"  —  još %d hint" % [word, category_name, hints_left])
	_update_hint_btn()

func _on_hint_solve(category: PuzzleData.Category, hints_left: int) -> void:
	var msg: String = "💡  Riješena kategorija: \"%s\"" % category.name
	if hints_left > 0:
		msg += "  —  još %d hint" % hints_left
	_show_typed_feedback(FeedbackType.HINT, msg)
	_update_hint_btn()
	_add_solved_row_animated(category)
	_rebuild_grid()
	if not _is_daily:
		SaveManager.save_session.call_deferred(_puzzles, _current_puzzle_index, _state)

func _highlight_peeked_category(category_name: String) -> void:
	for cat in _state.puzzle.categories:
		if cat.name != category_name:
			continue
		for word in cat.words:
			if not _tile_buttons.has(word):
				continue
			var btn: Button = _tile_buttons[word]
			var tween: Tween = create_tween().set_loops(2)
			var hint_style: StyleBoxFlat = _tile_style_normal().duplicate()
			hint_style.border_width_left   = BORDER_SEL
			hint_style.border_width_right  = BORDER_SEL
			hint_style.border_width_top    = BORDER_SEL
			hint_style.border_width_bottom = BORDER_SEL
			hint_style.border_color = C_MISTAKE_ON
			tween.tween_callback(func() -> void:
				if btn and is_instance_valid(btn):
					btn.add_theme_stylebox_override("normal", hint_style))
			tween.tween_interval(0.35)
			tween.tween_callback(func() -> void:
				if btn and is_instance_valid(btn):
					btn.add_theme_stylebox_override("normal", _tile_style_normal()))
			tween.tween_interval(0.35)
		break

func _on_shuffle() -> void:
	_rebuild_grid()
	_on_selection_changed(_state.selected_words)

func _on_deselect() -> void:
	_state.deselect_all()

func _on_submit() -> void:
	_state.submit_guess()

func _on_new_set() -> void:
	SaveManager.clear_save()
	_puzzles = PuzzleData.get_puzzles()
	_current_puzzle_index = 0
	_session_scores.clear()
	_puzzle_times.clear()
	_puzzle_scores.clear()
	_puzzle_start_time = 0.0
	_update_session_label()
	_close_overlay()
	_load_puzzle(0)

func _go_to_menu() -> void:
	_close_overlay()
	_fade_rect.modulate = Color(1, 1, 1, 0)
	var t: Tween = create_tween()
	t.tween_property(_fade_rect, "modulate:a", 1.0, ANIM_FADE_OUT) \
		.set_trans(Tween.TRANS_SINE)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _navigate_puzzle(direction: int) -> void:
	_current_puzzle_index = (_current_puzzle_index + direction) % _puzzles.size()
	if _current_puzzle_index < 0:
		_current_puzzle_index = _puzzles.size() - 1
	_load_puzzle(_current_puzzle_index)
