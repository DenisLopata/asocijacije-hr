class_name UIHelpers

# Shared palette subset used by leaderboard row (same values as C_* in each screen file).
const C_SURFACE  := Color(0.13, 0.14, 0.18)
const C_TEXT     := Color(0.96, 0.96, 0.98)
const C_TEXT_DIM := Color(0.68, 0.69, 0.74)
const C_ACCENT   := Color(0.45, 0.55, 1.00)
const C_WIN      := Color(0.30, 0.85, 0.55)

# ── Style helpers ──────────────────────────────────────────────────────────────
static func rounded_box(color: Color, radius: int) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
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

# Converts "YYYY-MM-DD" storage format to "DD.MM.YYYY." display format.
static func format_date_label(date_str: String) -> String:
	var parts := date_str.split("-")
	return "%s.%s.%s." % [parts[2], parts[1], parts[0]]

static func fmt_time(secs: float) -> String:
	var s: int = int(secs)
	if s < 60:
		return "%ds" % s
	var mins: int = floori(s / 60.0)
	return "%dm%02ds" % [mins, s % 60]

static func add_separator(parent: VBoxContainer) -> void:
	var sep := ColorRect.new()
	sep.color = Color(1, 1, 1, 0.08)
	sep.custom_minimum_size = Vector2(0, 1)
	parent.add_child(sep)

# ── Overlay layout helpers ─────────────────────────────────────────────────────
# h_inset: horizontal padding applied to the CenterContainer (main_menu uses 16).
static func make_overlay_panel(parent: Control, min_width: int, h_inset: int = 0) -> PanelContainer:
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if h_inset > 0:
		center.offset_left  = h_inset
		center.offset_right = -h_inset
	parent.add_child(center)

	var panel := PanelContainer.new()
	var style := rounded_box(C_SURFACE, 20)
	style.content_margin_left   = 32
	style.content_margin_right  = 32
	style.content_margin_top    = 28
	style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", style)
	panel.custom_minimum_size = Vector2(min_width, 0)
	center.add_child(panel)
	return panel

static func make_overlay_vbox(parent: Control, separation: int) -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", separation)
	parent.add_child(vbox)
	return vbox

# owner_node is required so create_tween() has a scene-tree context.
static func animate_overlay_in(owner_node: Node, dim: Control, panel: Control, anim_time: float) -> void:
	panel.scale   = Vector2(0.88, 0.88)
	panel.modulate = Color(1, 1, 1, 0)
	dim.modulate   = Color(1, 1, 1, 0)
	# panel.size is Vector2.ZERO until the first layout pass; update pivot after resize
	panel.item_rect_changed.connect(func() -> void:
		panel.pivot_offset = panel.size / 2.0
	, CONNECT_ONE_SHOT)
	var t: Tween = owner_node.create_tween().set_parallel(true)
	t.tween_property(dim,   "modulate", Color.WHITE, anim_time)
	t.tween_property(panel, "scale",    Vector2.ONE, anim_time * 1.27) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t.tween_property(panel, "modulate", Color.WHITE, anim_time)

# ── Leaderboard row ────────────────────────────────────────────────────────────
# make_font: Callable(weight: int) -> FontVariation — provided by the calling scene.
static func make_leaderboard_row(rank: int, entry: Dictionary, is_me: bool, odd: bool,
		make_font: Callable) -> Control:
	var wrapper := PanelContainer.new()
	wrapper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if is_me:
		var hl := rounded_box(C_ACCENT.darkened(0.30), 8)
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
	rank_lbl.add_theme_font_override("font", make_font.call(700))
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
	name_lbl.add_theme_font_override("font", make_font.call(700 if is_me else 500))
	row.add_child(name_lbl)

	var score_lbl := Label.new()
	score_lbl.text = "%d" % entry["score"]
	score_lbl.add_theme_color_override("font_color", C_WIN if is_me else C_TEXT)
	row.add_child(score_lbl)

	var time_lbl := Label.new()
	time_lbl.text = fmt_time(entry["time"])
	time_lbl.add_theme_font_override("font", make_font.call(500))
	time_lbl.add_theme_color_override("font_color", C_TEXT_DIM)
	time_lbl.add_theme_font_size_override("font_size", 13)
	row.add_child(time_lbl)

	return wrapper
