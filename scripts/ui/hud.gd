extends CanvasLayer
## Minimal in-world HUD: a small reticle and the contextual interaction prompt.
## Nothing else is shown permanently (GDD section 13).

const TEXT_COLOR := Color(0.86, 0.84, 0.72)

var _prompt: Label
var _reticle: ColorRect


func _ready() -> void:
	layer = 10

	_reticle = ColorRect.new()
	_reticle.color = Color(TEXT_COLOR, 0.55)
	_reticle.custom_minimum_size = Vector2(4.0, 4.0)
	_reticle.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_reticle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_reticle)

	_prompt = Label.new()
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_prompt.anchor_top = 0.62
	_prompt.anchor_bottom = 0.62
	_prompt.anchor_left = 0.0
	_prompt.anchor_right = 1.0
	_prompt.offset_left = 0.0
	_prompt.offset_right = 0.0
	_prompt.add_theme_color_override(&"font_color", TEXT_COLOR)
	_prompt.add_theme_color_override(&"font_outline_color", Color(0.02, 0.04, 0.03))
	_prompt.add_theme_constant_override(&"outline_size", 8)
	_prompt.add_theme_font_size_override(&"font_size", 30)
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_prompt)

	EventBus.interaction_prompt_changed.connect(_on_prompt_changed)
	EventBus.room_view_opened.connect(func(_id: StringName) -> void: visible = false)
	EventBus.room_view_closed.connect(func(_id: StringName) -> void: visible = true)


func _on_prompt_changed(text: String) -> void:
	_prompt.text = text


## Current prompt text; used by tests.
func get_prompt_text() -> String:
	return _prompt.text
