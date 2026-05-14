extends Control

# ── Animation timings ──────────────────────────────────────────────────────
const ANIM_FADE_OUT    := 0.35
const ANIM_FADE_IN     := 0.30
const ANIM_OVERLAY_IN  := 0.22
const ANIM_BTN_STAGGER := 0.07
const ANIM_PRESS_DIP   := 0.07
const ANIM_PRESS_RISE  := 0.13

# ── Palette (mirrors game_screen) ──────────────────────────────────────────
const C_BG       := Color(0.07, 0.08, 0.11)
const C_SURFACE  := Color(0.13, 0.14, 0.18)
const C_TEXT     := Color(0.96, 0.96, 0.98)
const C_TEXT_DIM := Color(0.55, 0.56, 0.62)
const C_ACCENT   := Color(0.45, 0.55, 1.00)
const C_WIN      := Color(0.30, 0.85, 0.55)
const C_SUBMIT_ON := Color(0.28, 0.60, 0.42)

const RADIUS_BTN : int = 22
const FONT_PATH  := "res://assets/fonts/Nunito-VariableFont_wght.ttf"
const VERSION    := "v0.1.0"

const VIGNETTE_SHADER := "
shader_type canvas_item;
void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float v = dot(uv, uv);
	float alpha = smoothstep(0.4, 1.6, v) * 0.50;
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
"

# ── State ──────────────────────────────────────────────────────────────────
var _overlay: Control = null
var _overlay_tag: String = ""
var _fade_rect: ColorRect

# ── Boot ───────────────────────────────────────────────────────────────────
func _ready() -> void:
	_register_theme_variations()
	_build_ui()
	# Fade in from black on arrival
	_fade_rect.modulate = Color(1, 1, 1, 1)
	var t: Tween = create_tween()
	t.tween_property(_fade_rect, "modulate:a", 0.0, ANIM_FADE_IN)

func _register_theme_variations() -> void:
	if not theme:
		push_warning("MainMenu: no theme assigned")
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
	bg.color = C_BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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

	# Centered content
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 0)
	vbox.custom_minimum_size = Vector2(480, 0)
	center.add_child(vbox)

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
	title.add_theme_font_size_override("font_size", 52)
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
	subtitle.add_theme_font_override("font", _make_font(300))
	parent.add_child(subtitle)

func _build_buttons(parent: VBoxContainer) -> void:
	var btns: Array[Dictionary] = []

	# Continue — only when save exists
	var saved := SaveManager.load_session()
	if saved.size() > 0:
		var idx: int = saved.get("current_index", 0)
		var total: int = saved["puzzles"].size() if saved.has("puzzles") else 5
		var score: int = saved["state"].get("score", 0) if saved.has("state") else 0
		btns.append({
			"label": "Nastavi igru",
			"sub":   "Slagalica %d/%d  •  %d bodova" % [idx + 1, total, score],
			"style": "continue",
			"action": func() -> void: _go_to_game(false),
		})

	btns.append({
		"label":  "Nova igra",
		"sub":    "",
		"style":  "primary",
		"action": func() -> void: _go_to_game(true),
	})

	var today := Time.get_date_dict_from_system()
	var daily_seed: int = today["year"] * 10000 + today["month"] * 100 + today["day"]
	btns.append({
		"label": "Dnevni izazov",
		"sub":   "%d.%02d.%d." % [today["day"], today["month"], today["year"]],
		"style": "daily",
		"action": func() -> void: _go_to_daily(daily_seed),
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
		parent.add_child(btn)
		_build_spacer(parent, 14)
		# Stagger-in: fade + scale only — no position tweak inside VBox (#layout-safe)
		btn.modulate = Color(1, 1, 1, 0)
		btn.scale    = Vector2(0.96, 0.96)
		var delay: float = i * ANIM_BTN_STAGGER + ANIM_FADE_IN
		var t: Tween = create_tween().set_parallel(true)
		t.tween_property(btn, "modulate", Color.WHITE, 0.28).set_delay(delay)
		t.tween_property(btn, "scale", Vector2.ONE, 0.28) \
			.set_delay(delay).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _build_bottom_bar() -> void:
	var bar: HBoxContainer = HBoxContainer.new()
	bar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bar.offset_top    = -52
	bar.offset_bottom = -10
	bar.offset_left   = 28
	bar.offset_right  = -28
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
		"continue": bg_color = C_SUBMIT_ON
		"primary":  bg_color = Color(0.28, 0.35, 0.65)
		"daily":    bg_color = Color(0.50, 0.32, 0.68)
		_:          bg_color = Color(0.17, 0.19, 0.25)

	var normal: StyleBoxFlat = _rounded_box(bg_color, RADIUS_BTN)
	if style == "continue":
		normal.border_width_left   = 1
		normal.border_width_right  = 1
		normal.border_width_top    = 1
		normal.border_width_bottom = 1
		normal.border_color        = C_WIN.lightened(0.2)
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
		btn.add_child(vbox)

		var main_lbl: Label = Label.new()
		main_lbl.text = label
		main_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		main_lbl.add_theme_font_override("font", _make_font(600))
		main_lbl.add_theme_font_size_override("font_size", 18)
		main_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(main_lbl)

		var sub_lbl: Label = Label.new()
		sub_lbl.text = subtitle
		sub_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		sub_lbl.add_theme_font_override("font", _make_font(300))
		sub_lbl.add_theme_font_size_override("font_size", 15)
		sub_lbl.add_theme_color_override("font_color", C_TEXT.darkened(0.15))
		sub_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(sub_lbl)

		# Hide the default button text
		btn.text = ""
	else:
		btn.text = label
		btn.add_theme_font_override("font", _make_font(600))
		btn.add_theme_font_size_override("font_size", 18)

	# Micro-bounce
	btn.button_down.connect(func() -> void:
		if is_instance_valid(btn):
			create_tween().tween_property(btn, "scale", Vector2(0.97, 0.97), ANIM_PRESS_DIP) \
				.set_trans(Tween.TRANS_SINE))
	btn.button_up.connect(func() -> void:
		if is_instance_valid(btn):
			create_tween().tween_property(btn, "scale", Vector2.ONE, ANIM_PRESS_RISE) \
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT))

	return btn

# ── Navigation ─────────────────────────────────────────────────────────────
func _go_to_game(clear_save: bool) -> void:
	if clear_save:
		SaveManager.clear_save()
	# Fade to black then switch scene
	_fade_rect.modulate = Color(1, 1, 1, 0)
	var t: Tween = create_tween()
	t.tween_property(_fade_rect, "modulate:a", 1.0, ANIM_FADE_OUT) \
		.set_trans(Tween.TRANS_SINE)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")

func _go_to_daily(seed: int) -> void:
	get_tree().set_meta("daily_seed", seed)
	_fade_rect.modulate = Color(1, 1, 1, 0)
	var t: Tween = create_tween()
	t.tween_property(_fade_rect, "modulate:a", 1.0, ANIM_FADE_OUT) \
		.set_trans(Tween.TRANS_SINE)
	await t.finished
	get_tree().change_scene_to_file("res://scenes/game_screen.tscn")

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

	for pair in [["Malo", 14], ["Srednje", 18], ["Veliko", 22]]:
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
	panel.scale    = Vector2(0.88, 0.88)
	panel.modulate = Color(1, 1, 1, 0)
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
