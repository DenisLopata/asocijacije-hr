extends Control

# ── Animation timings ──────────────────────────────────────────────────────
const ANIM_FADE_OUT    := 0.35
const ANIM_FADE_IN     := 0.30
const ANIM_OVERLAY_IN  := 0.22
const ANIM_BTN_STAGGER := 0.07
const ANIM_PRESS_DIP   := 0.07
const ANIM_PRESS_RISE  := 0.13

# ── Palette (mirrors game_screen) ──────────────────────────────────────────
const C_BG         := Color(0.07, 0.08, 0.11)
const C_SURFACE    := Color(0.13, 0.14, 0.18)
const C_TEXT       := Color(0.96, 0.96, 0.98)
const C_TEXT_DIM   := Color(0.68, 0.69, 0.74)
const C_ACCENT     := Color(0.45, 0.55, 1.00)
const C_WIN        := Color(0.30, 0.85, 0.55)
const C_SUBMIT_ON  := Color(0.28, 0.60, 0.42)
const C_BTN_PRIMARY := Color(0.28, 0.35, 0.65)
const C_BTN_DAILY   := Color(0.50, 0.32, 0.68)
const C_BTN_FIVE    := Color(0.10, 0.32, 0.38)
const C_BTN_DONE    := Color(0.18, 0.20, 0.26)

const RADIUS_BTN      : int = 22
const FONT_PATH       := "res://assets/fonts/Outfit-VariableFont_wght.ttf"
const ICON_FONT_PATH  := "res://assets/fonts/MaterialSymbolsOutlined.ttf"
const VERSION         := "v0.1.1"

func _icon(icon_name: String) -> String:
	const CP := {
		"calendar":    0xE935,
		"timer":       0xE425,
		"shuffle":     0xE043,
		"done":        0xE876,
		"quiz":        0xF04C,
		"star":        0xF09A,
		"leaderboard": 0xF20C,
		"chevron":     0xE5CC,
		"local_fire":  0xEF55,
	}
	return char(CP.get(icon_name, 0x3F))

func _icon_font() -> FontFile:
	return load(ICON_FONT_PATH) as FontFile

func _mixed_font(weight: int) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = load(FONT_PATH)
	fv.variation_opentype = {"wght": weight}
	var icon_f := _icon_font()
	if icon_f:
		fv.fallbacks = [icon_f]
	return fv

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
var _overlay: Control = null
var _overlay_tag: String = ""
var _fade_rect: ColorRect

# ── Boot ───────────────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_D and event.ctrl_pressed and event.shift_pressed:
			var date_str: String = SaveManager.get_today()["date_str"]
			var cfg := ConfigFile.new()
			cfg.load(SaveManager.PREFS_PATH)
			for sec in ["daily_single", "daily_five"]:
				if cfg.has_section(sec):
					cfg.erase_section_key(sec, date_str + "_score")
					cfg.erase_section_key(sec, date_str + "_time")
			if cfg.has_section("submitted"):
				for key in ["daily_" + date_str, "five_" + date_str]:
					if cfg.has_section_key("submitted", key):
						cfg.erase_section_key("submitted", key)
			cfg.save(SaveManager.PREFS_PATH)
			print("[DEBUG] Cleared daily results for ", date_str)
			get_tree().reload_current_scene()
		if event.keycode == KEY_S and event.ctrl_pressed and event.shift_pressed:
			var yesterday: String = SaveManager._yesterday(SaveManager.get_today()["date_str"])
			var cfg := ConfigFile.new()
			cfg.load(SaveManager.PREFS_PATH)
			for sec in ["streak_daily", "streak_five"]:
				cfg.set_value(sec, "last_date", yesterday)
				cfg.set_value(sec, "count", 5)
			cfg.save(SaveManager.PREFS_PATH)
			print("[DEBUG] Injected fake streaks (daily+five): 5 days, last=", yesterday)
			get_tree().reload_current_scene()

func _ready() -> void:
	_register_theme_variations()
	_build_ui()
	# Fade in from black on arrival
	_fade_rect.modulate = Color(1, 1, 1, 1)
	var t: Tween = create_tween()
	t.tween_property(_fade_rect, "modulate:a", 0.0, ANIM_FADE_IN)

func _register_theme_variations() -> void:
	if not theme:
		return
	theme.set_type_variation("TitleLabel",    &"Label")
	theme.set_type_variation("SubtitleLabel", &"Label")
	theme.set_type_variation("MetaLabel",     &"Label")
	theme.set_type_variation("ScoreLabel",    &"Label")
	theme.set_type_variation("GhostButton",   &"Button")

# ── UI construction ────────────────────────────────────────────────────────
func _build_ui() -> void:
	# Background
	var bg: ColorRect = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg_mat := ShaderMaterial.new()
	var bg_shader := Shader.new()
	bg_shader.code = BG_SHADER
	bg_mat.shader = bg_shader
	bg.material = bg_mat
	add_child(bg)

	# Vignette
	var vignette: ColorRect = ColorRect.new()
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	var shader := Shader.new()
	shader.code = VIGNETTE_SHADER
	mat.shader = shader
	vignette.material = mat
	add_child(vignette)

	# Content margin — horizontal padding so buttons don't touch screen edges
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left",   32)
	margin.add_theme_constant_override("margin_right",  32)
	margin.add_theme_constant_override("margin_top",    0)
	margin.add_theme_constant_override("margin_bottom", 64)
	add_child(margin)

	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 0)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.add_child(vbox)

	_build_spacer(vbox, 48)
	_build_logo(vbox)
	_build_spacer(vbox, 48)
	_build_buttons(vbox)
	_build_spacer(vbox, 16)

	# Bottom bar: version + exit
	_build_bottom_bar()

	# Fade overlay — always on top
	_fade_rect = ColorRect.new()
	_fade_rect.color = Color(0, 0, 0, 1)
	_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade_rect)

func _build_logo(parent: VBoxContainer) -> void:
	var title: Label = Label.new()
	title.text = "ASOCIJACIJE"
	title.theme_type_variation = "TitleLabel"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_font_override("font", _make_font(800))
	parent.add_child(title)

	_build_spacer(parent, 10)

	var accent_bar: ColorRect = ColorRect.new()
	accent_bar.color = C_ACCENT
	accent_bar.custom_minimum_size = Vector2(80, 4)
	accent_bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	parent.add_child(accent_bar)

	_build_spacer(parent, 14)

	var subtitle: Label = Label.new()
	subtitle.text = "Grupirajte 16 pojmova u 4 kategorije"
	subtitle.theme_type_variation = "SubtitleLabel"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_override("font", _make_font(400))
	subtitle.add_theme_color_override("font_color", C_TEXT)
	parent.add_child(subtitle)

func _build_buttons(parent: VBoxContainer) -> void:
	var btns: Array[Dictionary] = []

	var today       := SaveManager.get_today()
	var date_str    : String = today["date_str"]
	var date_label  : String = today["date_label"]
	var daily_seed  : int    = today["daily_seed"]
	var five_seed   : int    = today["five_seed"]

	var daily_result := SaveManager.load_daily_result(date_str)
	var streak: int = SaveManager.load_streak("daily")
	if daily_result.size() > 0:
		btns.append(_done_btn("Dnevni izazov", daily_result, "daily", date_str, streak))
	else:
		var daily_sub := date_label
		if streak >= 2:
			daily_sub = "%s %d  •  %s" % [_icon("local_fire"), streak, date_label]
		btns.append({
			"label":  "Dnevni izazov",
			"sub":    daily_sub,
			"style":  "daily",
			"action": func() -> void: _go_to_daily(daily_seed),
		})

	var five_result := SaveManager.load_five_result(date_str)
	var five_streak: int = SaveManager.load_streak("five")
	if five_result.size() > 0:
		btns.append(_done_btn("Dnevnih 5", five_result, "five", date_str, five_streak))
	else:
		var saved := SaveManager.load_session()
		if saved.size() > 0:
			var idx: int = saved.get("current_index", 0)
			var total: int = saved["puzzles"].size() if saved.has("puzzles") else 5
			var score: int = saved["state"].get("score", 0) if saved.has("state") else 0
			btns.append({
				"label":  "Nastavi Dnevnih 5",
				"sub":    "%s  Slagalica %d/%d  •  %d bodova" % [_icon("timer"), idx + 1, total, score],
				"style":  "five",
				"action": func() -> void: _go_to_five(five_seed, false),
			})
		var five_sub := "%s  Pet slagalica  •  %s" % [_icon("quiz"), date_label]
		if five_streak >= 2:
			five_sub += "  •  %s %d" % [_icon("local_fire"), five_streak]
		btns.append({
			"label":  "Dnevnih 5",
			"sub":    five_sub,
			"style":  "five",
			"action": func() -> void: _go_to_five(five_seed, true),
		})

	btns.append({
		"label":    "Beskraj",
		"sub":      "Dolazi uskoro",
		"style":    "primary",
		"action":   func() -> void: pass,
		"disabled": true,
	})

	btns.append({
		"label":  "Postavke",
		"sub":    "",
		"style":  "ghost",
		"action": _on_settings,
	})

	for i in btns.size():
		var info: Dictionary = btns[i]
		var btn: Button = _make_menu_btn(info["label"], info.get("sub", ""), info["style"])
		btn.pressed.connect(info["action"])
		if info.get("disabled", false):
			btn.disabled = true
		parent.add_child(btn)
		_build_spacer(parent, 14)
		# Stagger-in: fade + scale only — no position tweak inside VBox (#layout-safe)
		btn.modulate     = Color(1, 1, 1, 0)
		btn.scale        = Vector2(0.96, 0.96)
		btn.pivot_offset = btn.size / 2.0
		var delay: float = i * ANIM_BTN_STAGGER + ANIM_FADE_IN
		var t: Tween = create_tween().set_parallel(true)
		t.tween_property(btn, "modulate", Color.WHITE, 0.28).set_delay(delay)
		t.tween_property(btn, "scale", Vector2.ONE, 0.28) \
			.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _build_bottom_bar() -> void:
	var bar: HBoxContainer = HBoxContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top    = -60
	bar.offset_bottom = -16
	bar.offset_left   = 32
	bar.offset_right  = -32
	bar.alignment     = BoxContainer.ALIGNMENT_BEGIN
	add_child(bar)

	var ver_lbl: Label = Label.new()
	ver_lbl.text = VERSION
	ver_lbl.theme_type_variation = "MetaLabel"
	ver_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	ver_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(ver_lbl)

	# Exit only on desktop (#4)
	if OS.has_feature("pc"):
		var exit_btn: Button = Button.new()
		exit_btn.text = "Izlaz"
		exit_btn.theme_type_variation = "GhostButton"
		exit_btn.custom_minimum_size = Vector2(90, 44)
		exit_btn.pressed.connect(func() -> void: get_tree().quit())
		bar.add_child(exit_btn)

# ── Button factory ─────────────────────────────────────────────────────────
func _make_menu_btn(label: String, subtitle: String, style: String) -> Button:
	var btn: Button = Button.new()
	btn.custom_minimum_size = Vector2(0, 68 if subtitle != "" else 54)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Style
	var bg_color: Color
	match style:
		"continue":   bg_color = C_SUBMIT_ON
		"primary":    bg_color = C_BTN_PRIMARY
		"daily":      bg_color = C_BTN_DAILY
		"five":       bg_color = C_BTN_FIVE
		"daily_done": bg_color = C_BTN_DONE
		_:            bg_color = C_SURFACE

	var normal: StyleBoxFlat = _rounded_box(bg_color, RADIUS_BTN)
	normal.content_margin_left  = 20
	normal.content_margin_right = 20
	if style == "continue":
		normal.border_width_left   = 1
		normal.border_width_right  = 1
		normal.border_width_top    = 1
		normal.border_width_bottom = 1
		normal.border_color        = C_WIN.lightened(0.2)
	elif style == "daily_done":
		normal.border_width_left   = 1
		normal.border_width_right  = 1
		normal.border_width_top    = 1
		normal.border_width_bottom = 1
		normal.border_color        = C_ACCENT.darkened(0.35)
	btn.add_theme_stylebox_override("normal", normal)
	var hover: StyleBoxFlat = normal.duplicate()
	hover.bg_color = bg_color.lightened(0.10)
	btn.add_theme_stylebox_override("hover", hover)
	var pressed_style: StyleBoxFlat = normal.duplicate()
	pressed_style.bg_color = bg_color.darkened(0.08)
	btn.add_theme_stylebox_override("pressed", pressed_style)

	# Text — use a VBox inside to stack label + subtitle
	if subtitle != "":
		# Put a VBox as the button's "icon area" workaround via a child label container
		# Godot buttons don't support multiline natively, so we overlay a VBox
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.clip_contents = true
		btn.add_child(vbox)

		var main_lbl: Label = Label.new()
		main_lbl.text = label
		main_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		main_lbl.add_theme_font_override("font", _make_font(700))
		main_lbl.add_theme_font_size_override("font_size", 26)
		main_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(main_lbl)

		var sub_lbl: Label = Label.new()
		sub_lbl.text = subtitle
		sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sub_lbl.add_theme_font_override("font", _mixed_font(400))
		sub_lbl.add_theme_font_size_override("font_size", 18)
		sub_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
		sub_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(sub_lbl)

		# Hide the default button text
		btn.text = ""
	else:
		btn.text = label
		btn.add_theme_font_override("font", _make_font(700))
		btn.add_theme_font_size_override("font_size", 26)

	# Micro-bounce
	btn.button_down.connect(func() -> void:
		if is_instance_valid(btn):
			btn.pivot_offset = btn.size / 2.0
			create_tween().tween_property(btn, "scale", Vector2(0.97, 0.97), ANIM_PRESS_DIP) \
				.set_trans(Tween.TRANS_SINE))
	btn.button_up.connect(func() -> void:
		if is_instance_valid(btn):
			btn.pivot_offset = btn.size / 2.0
			create_tween().tween_property(btn, "scale", Vector2.ONE, ANIM_PRESS_RISE) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))

	return btn

func _done_btn(label: String, result: Dictionary, mode: String, date_str: String, streak: int = 0) -> Dictionary:
	var sub := "%s  %d bodova  •  %s  %s  •  %s ljestvica" % [_icon("done"), result["score"], _icon("timer"), _fmt_time(result["time"]), _icon("leaderboard")]
	if streak >= 2:
		sub += "  •  %s %d" % [_icon("local_fire"), streak]
	return {
		"label":  label,
		"sub":    sub,
		"style":  "daily_done",
		"action": func() -> void: _show_leaderboard_overlay_menu(mode, date_str),
	}

# ── Navigation ─────────────────────────────────────────────────────────────
func _go_to_game(clear_save: bool) -> void:
	if clear_save:
		SaveManager.clear_save()
	await _fade_to_black()
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")

func _go_to_daily(p_seed: int) -> void:
	get_tree().set_meta("daily_seed", p_seed)
	await _fade_to_black()
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")

func _go_to_five(p_seed: int, clear_save: bool) -> void:
	if clear_save:
		SaveManager.clear_save()
	get_tree().set_meta("five_seed", p_seed)
	await _fade_to_black()
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")

func _fade_to_black() -> void:
	_fade_rect.modulate = Color(1, 1, 1, 0)
	var t: Tween = create_tween()
	t.tween_property(_fade_rect, "modulate:a", 1.0, ANIM_FADE_OUT).set_trans(Tween.TRANS_SINE)
	await t.finished

# ── Settings overlay (mirrors game_screen) ────────────────────────────────
func _on_settings() -> void:
	if _overlay and is_instance_valid(_overlay):
		_close_overlay()
		if _overlay_tag == "settings":
			return

	var dim: ColorRect = _make_dim()
	_overlay = dim
	_overlay_tag = "settings"

	var panel: PanelContainer = _make_overlay_panel(dim, 380)
	var vbox: VBoxContainer   = _make_overlay_vbox(panel, 18)

	var title_lbl: Label = Label.new()
	title_lbl.text = "Postavke"
	title_lbl.theme_type_variation = "TitleLabel"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_lbl.add_theme_font_size_override("font_size", 22)
	title_lbl.add_theme_font_override("font", _make_font(700))
	vbox.add_child(title_lbl)

	_add_separator(vbox)

	var fs_lbl: Label = Label.new()
	fs_lbl.text = "Veličina fonta pločica"
	fs_lbl.theme_type_variation = "SubtitleLabel"
	vbox.add_child(fs_lbl)

	var fs_row: HBoxContainer = HBoxContainer.new()
	fs_row.add_theme_constant_override("separation", 10)
	vbox.add_child(fs_row)

	for pair in [["Malo", 16], ["Srednje", 20], ["Veliko", 26]]:
		var fs_btn: Button = _make_small_btn(pair[0])
		var size_val: int = pair[1]
		fs_btn.pressed.connect(func() -> void: SaveManager.save_prefs(size_val))
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

	var clear_btn: Button = _make_small_btn("Obriši pohranjeni napredak")
	clear_btn.custom_minimum_size = Vector2(300, 46)
	clear_btn.pressed.connect(func() -> void:
		SaveManager.clear_save()
		save_info.text = "Napredak je obrisan."
		# Reload menu so Continue button disappears
		get_tree().reload_current_scene())
	vbox.add_child(clear_btn)

	_add_separator(vbox)

	var close_btn: Button = _make_small_btn("Zatvori")
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(_close_overlay)
	vbox.add_child(close_btn)

	_animate_overlay_in(dim, panel)

# ── Shared overlay helpers ─────────────────────────────────────────────────
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
	center.offset_left  = 16
	center.offset_right = -16
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

func _animate_overlay_in(dim: Control, panel: Control) -> void:
	panel.pivot_offset = panel.size / 2.0
	panel.scale        = Vector2(0.88, 0.88)
	panel.modulate     = Color(1, 1, 1, 0)
	dim.modulate   = Color(1, 1, 1, 0)
	var t: Tween = create_tween().set_parallel(true)
	t.tween_property(dim,   "modulate", Color.WHITE, ANIM_OVERLAY_IN)
	t.tween_property(panel, "scale",    Vector2.ONE, ANIM_OVERLAY_IN * 1.27) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "modulate", Color.WHITE, ANIM_OVERLAY_IN)

func _make_small_btn(label: String) -> Button:
	var btn: Button = Button.new()
	btn.text = label
	btn.theme_type_variation = "GhostButton"
	btn.custom_minimum_size = Vector2(100, 44)
	return btn

# ── Style helpers ──────────────────────────────────────────────────────────
func _rounded_box(color: Color, radius: int) -> StyleBoxFlat:
	var s: StyleBoxFlat = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left     = radius
	s.corner_radius_top_right    = radius
	s.corner_radius_bottom_left  = radius
	s.corner_radius_bottom_right = radius
	s.content_margin_left   = 12
	s.content_margin_right  = 12
	s.content_margin_top    = 8
	s.content_margin_bottom = 8
	return s

func _make_font(weight: int) -> FontVariation:
	var fv := FontVariation.new()
	fv.base_font = load(FONT_PATH)
	fv.variation_opentype = {"wght": weight}
	return fv

func _build_spacer(parent: VBoxContainer, height: int) -> void:
	var s: Control = Control.new()
	s.custom_minimum_size = Vector2(0, height)
	parent.add_child(s)

func _fmt_time(secs: float) -> String:
	var s: int = int(secs)
	if s < 60:
		return "%ds" % s
	var mins: int = floori(s / 60.0)
	return "%dm%02ds" % [mins, s % 60]

func _make_leaderboard_row_menu(rank: int, entry: Dictionary, is_me: bool, odd: bool = false) -> Control:
	var wrapper := PanelContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_me:
		var hl := _rounded_box(C_ACCENT.darkened(0.30), 8)
		hl.border_width_left   = 2
		hl.border_width_right  = 2
		hl.border_width_top    = 2
		hl.border_width_bottom = 2
		hl.border_color = C_ACCENT
		wrapper.add_theme_stylebox_override("panel", hl)
	else:
		var flat := StyleBoxFlat.new()
		flat.bg_color = Color(1, 1, 1, 0.04 if odd else 0.0)
		flat.corner_radius_top_left     = 6
		flat.corner_radius_top_right    = 6
		flat.corner_radius_bottom_left  = 6
		flat.corner_radius_bottom_right = 6
		flat.content_margin_left   = 8
		flat.content_margin_right  = 8
		flat.content_margin_top    = 4
		flat.content_margin_bottom = 4
		wrapper.add_theme_stylebox_override("panel", flat)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	wrapper.add_child(row)

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
	name_lbl.add_theme_font_override("font", _make_font(700 if is_me else 500))
	row.add_child(name_lbl)

	var score_lbl := Label.new()
	score_lbl.text = "%d" % entry["score"]
	score_lbl.add_theme_color_override("font_color", C_WIN if is_me else C_TEXT)
	row.add_child(score_lbl)

	var time_lbl := Label.new()
	time_lbl.text = _fmt_time(entry["time"])
	time_lbl.add_theme_font_override("font", _make_font(500))
	time_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	time_lbl.add_theme_font_size_override("font_size", 13)
	row.add_child(time_lbl)

	return wrapper

func _show_leaderboard_overlay_menu(mode: String, date_str: String) -> void:
	if _overlay and is_instance_valid(_overlay):
		_close_overlay()

	var dim := _make_dim()
	_overlay = dim
	_overlay_tag = "leaderboard"
	var panel := _make_overlay_panel(dim, 480)
	var vbox  := _make_overlay_vbox(panel, 12)

	var mode_label := "Dnevni izazov" if mode == "daily" else "Dnevnih 5"
	var header := Label.new()
	header.text = "Ljestvica — " + mode_label
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_theme_font_size_override("font_size", 20)
	header.add_theme_font_override("font", _make_font(700))
	vbox.add_child(header)

	var parts := date_str.split("-")
	var date_lbl := Label.new()
	date_lbl.text = "%s.%s.%s." % [parts[2], parts[1], parts[0]]
	date_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	date_lbl.add_theme_font_override("font", _make_font(300))
	date_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	date_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(date_lbl)

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

	var my_uid: String = FirebaseClient.get_uid()

	if entries.is_empty():
		var empty_lbl := Label.new()
		var fetch_err := FirebaseClient.get_last_fetch_error()
		empty_lbl.text = "Ljestvica nije dostupna\nbez internetske veze." if fetch_err != "" \
			else "Nema rezultata."
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
			var row := _make_leaderboard_row_menu(i + 1, entries[i], is_me, i % 2 == 1)
			list.add_child(row)
			if is_me:
				me_row = row

		if me_row != null:
			await get_tree().process_frame
			scroll.ensure_control_visible(me_row)

	_add_separator(vbox)
	var close_btn := _make_small_btn("Zatvori")
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.pressed.connect(_close_overlay)
	vbox.add_child(close_btn)
