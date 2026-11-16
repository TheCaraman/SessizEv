extends CanvasLayer
## In-world HUD: a small reticle, the contextual interaction prompt, the clock,
## a subtitle line for sounds that matter, and the day title card.
## No survival meters are shown (GDD section 13).

const TEXT_COLOR := Color(0.86, 0.84, 0.72)
const NOTICE_SECONDS: float = 5.0
const TITLE_SECONDS: float = 4.0

var _prompt: Label
var _reticle: ColorRect
var _clock: Label
var _subtitle: Label
var _title: Label
var _notice_time_left: float = 0.0
var _title_tween: Tween
var _covered_by: Dictionary = {}


func _ready() -> void:
	layer = 10

	_reticle = ColorRect.new()
	_reticle.color = Color(TEXT_COLOR, 0.55)
	_reticle.custom_minimum_size = Vector2(4.0, 4.0)
	_reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_reticle)

	_prompt = _make_line(30, 0.62)
	_subtitle = _make_line(26, 0.86)
	_subtitle.modulate = Color(1.0, 1.0, 1.0, 0.85)
	_title = _make_line(52, 0.36)
	_title.modulate = Color(1.0, 1.0, 1.0, 0.0)

	_clock = Label.new()
	_clock.position = Vector2(40.0, 28.0)
	_style(_clock, 24)
	_clock.modulate = Color(1.0, 1.0, 1.0, 0.8)
	add_child(_clock)

	EventBus.interaction_prompt_changed.connect(func(text: String) -> void: _prompt.text = text)
	EventBus.time_changed.connect(func(_day: int, _minutes: int) -> void: _update_clock())
	EventBus.visitor_changed.connect(func(_id: String) -> void: _update_subtitle())
	EventBus.notice_requested.connect(_show_notice)
	EventBus.day_started.connect(_show_title)
	# While a room or a conversation fills the screen only the clock stays.
	EventBus.room_view_opened.connect(func(_id: StringName) -> void: _set_covered(&"room", true))
	EventBus.room_view_closed.connect(func(_id: StringName) -> void: _set_covered(&"room", false))
	EventBus.dialogue_started.connect(func(_id: String) -> void: _set_covered(&"dialogue", true))
	EventBus.dialogue_ended.connect(func(_id: String) -> void: _set_covered(&"dialogue", false))
	EventBus.shelter_view_opened.connect(func() -> void: _set_covered(&"shelter", true))
	EventBus.shelter_view_closed.connect(func() -> void: _set_covered(&"shelter", false))
	_update_clock()
	_update_subtitle()
	if GameState.active:
		_show_title(GameState.day)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _clock != null:
		_update_clock()
		_update_subtitle()
		_title.text = tr("TITLE_DAY_1") if GameState.day == 1 else tr("TITLE_DAY_N").format({"day": GameState.day})


func _process(delta: float) -> void:
	if _notice_time_left > 0.0:
		_notice_time_left -= delta
		if _notice_time_left <= 0.0:
			_update_subtitle()


func _set_covered(what: StringName, covered: bool) -> void:
	if covered:
		_covered_by[what] = true
	else:
		_covered_by.erase(what)
	var clear: bool = _covered_by.is_empty()
	for control: Control in [_reticle, _prompt, _subtitle, _title]:
		control.visible = clear


## Current prompt text; used by tests.
func get_prompt_text() -> String:
	return _prompt.text


func get_subtitle_text() -> String:
	return _subtitle.text


func get_clock_text() -> String:
	return _clock.text


func _update_clock() -> void:
	if not GameState.active:
		_clock.text = ""
		return
	var phase_keys: Array[String] = ["PHASE_MORNING", "PHASE_AFTERNOON", "PHASE_EVENING", "PHASE_NIGHT"]
	_clock.text = tr("HUD_CLOCK").format({
		"day": GameState.day,
		"time": GameState.get_clock_text(),
		"phase": tr(phase_keys[GameState.get_phase()]),
	})


## The subtitle names any sound the player must not miss, so the cue never
## depends on hearing alone.
func _update_subtitle() -> void:
	if _notice_time_left > 0.0:
		return
	_subtitle.text = tr("HUD_KNOCKING") if GameState.visitor != "" else ""


func _show_notice(text: String) -> void:
	_subtitle.text = text
	_notice_time_left = NOTICE_SECONDS


func _show_title(day: int) -> void:
	_title.text = tr("TITLE_DAY_1") if day == 1 else tr("TITLE_DAY_N").format({"day": day})
	if _title_tween != null:
		_title_tween.kill()
	_title.modulate.a = 0.0
	_title_tween = create_tween()
	_title_tween.tween_property(_title, "modulate:a", 1.0, 0.8)
	_title_tween.tween_interval(TITLE_SECONDS)
	_title_tween.tween_property(_title, "modulate:a", 0.0, 1.2)


## A centred, full-width line of text at a fraction of the screen height.
func _make_line(font_size: int, height_fraction: float) -> Label:
	var label := Label.new()
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.anchor_left = 0.0
	label.anchor_right = 1.0
	label.anchor_top = height_fraction
	label.anchor_bottom = height_fraction
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_style(label, font_size)
	add_child(label)
	return label


func _style(label: Label, font_size: int) -> void:
	label.add_theme_color_override(&"font_color", TEXT_COLOR)
	label.add_theme_color_override(&"font_outline_color", Color(0.02, 0.04, 0.03))
	label.add_theme_constant_override(&"outline_size", 8)
	label.add_theme_font_size_override(&"font_size", font_size)
