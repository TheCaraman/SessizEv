class_name DialogueView
extends CanvasLayer
## Shows the conversation a DialogueRunner is playing: who is speaking, what
## they say, and the replies Daniel can give.
##
## The speaker appears as a 2D figure. The picture is loaded from
## assets/characters/<id>/default.png; until that exists a plain silhouette
## with the character's name stands in for it.
##
## Replies can be clicked or chosen with the number keys.

const TEXT_COLOR := Color(0.88, 0.86, 0.76)
const DIM_COLOR := Color(0.62, 0.60, 0.52)
const PANEL_COLOR := Color(0.04, 0.05, 0.05, 0.92)
const CHARACTER_IMAGE_PATH: String = "res://assets/characters/%s/default.png"

var _runner: DialogueRunner
var _figure: TextureRect
var _silhouette: Panel
var _silhouette_name: Label
var _speaker: Label
var _text: Label
var _choices: VBoxContainer


func _ready() -> void:
	layer = 7
	_build_interface()
	visible = false


## Called once by the session scene.
func setup(runner: DialogueRunner) -> void:
	_runner = runner
	_runner.node_changed.connect(_show_node)
	_runner.ended.connect(func(_id: String) -> void: visible = false)


func is_open() -> bool:
	return visible


func _show_node(node: Dictionary) -> void:
	var speaker_id: String = node.get("speaker", "")
	var narration: bool = speaker_id == ""
	_speaker.text = "" if narration else Roster.get_display_name(speaker_id)
	_speaker.visible = not narration
	_text.text = tr(node.get("text", ""))
	_text.add_theme_color_override(&"font_color", DIM_COLOR if narration else TEXT_COLOR)
	_show_figure(speaker_id)

	for child: Node in _choices.get_children():
		_choices.remove_child(child)
		child.queue_free()
	var choices: Array = node.get("choices", [])
	for i: int in choices.size():
		var button := Button.new()
		button.text = "%d.  %s" % [i + 1, tr(choices[i]["text"]).format(choices[i].get("args", {}))]
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override(&"font_size", 24)
		button.pressed.connect(_runner.choose.bind(i))
		_choices.add_child(button)
	visible = true


## Keeps the last speaker on screen during narration lines, so the figure does
## not blink in and out between sentences.
func _show_figure(speaker_id: String) -> void:
	if speaker_id == "":
		return
	var path: String = CHARACTER_IMAGE_PATH % speaker_id
	if ResourceLoader.exists(path):
		_figure.texture = load(path) as Texture2D
		_figure.visible = true
		_silhouette.visible = false
	else:
		_figure.visible = false
		_silhouette.visible = true
		_silhouette_name.text = Roster.get_display_name(speaker_id)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		var key: Key = (event as InputEventKey).physical_keycode
		var index: int = -1
		if key >= KEY_1 and key <= KEY_9:
			index = key - KEY_1
		elif key >= KEY_KP_1 and key <= KEY_KP_9:
			index = key - KEY_KP_1
		if index >= 0 and index < _choices.get_child_count():
			_runner.choose(index)
			get_viewport().set_input_as_handled()
			return
	# A conversation cannot be walked away from; swallow the keys that would
	# otherwise close the room view or release the mouse.
	if event.is_action(&"pause") or event.is_action(&"interact"):
		get_viewport().set_input_as_handled()


func _build_interface() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.01, 0.01, 0.72)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)

	# The speaker's figure stands in the upper middle of the screen.
	_figure = TextureRect.new()
	_figure.anchor_left = 0.32
	_figure.anchor_right = 0.68
	_figure.anchor_top = 0.04
	_figure.anchor_bottom = 0.56
	_figure.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_figure.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_figure.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_figure.visible = false
	root.add_child(_figure)

	_silhouette = Panel.new()
	_silhouette.anchor_left = 0.41
	_silhouette.anchor_right = 0.59
	_silhouette.anchor_top = 0.06
	_silhouette.anchor_bottom = 0.56
	var silhouette_style := StyleBoxFlat.new()
	silhouette_style.bg_color = Color(0.03, 0.05, 0.05)
	silhouette_style.border_color = Color(0.22, 0.26, 0.24)
	silhouette_style.set_border_width_all(2)
	silhouette_style.corner_radius_top_left = 90
	silhouette_style.corner_radius_top_right = 90
	_silhouette.add_theme_stylebox_override(&"panel", silhouette_style)
	_silhouette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_silhouette.visible = false
	root.add_child(_silhouette)

	_silhouette_name = Label.new()
	_silhouette_name.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_silhouette_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_silhouette_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_silhouette_name.add_theme_color_override(&"font_color", DIM_COLOR)
	_silhouette_name.add_theme_font_size_override(&"font_size", 24)
	_silhouette.add_child(_silhouette_name)

	var panel := PanelContainer.new()
	panel.anchor_left = 0.12
	panel.anchor_right = 0.88
	# Anchored to the bottom and growing upward, so six replies still fit.
	panel.anchor_top = 0.97
	panel.anchor_bottom = 0.97
	panel.grow_vertical = Control.GROW_DIRECTION_BEGIN
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = PANEL_COLOR
	panel_style.border_color = Color(0.30, 0.32, 0.26)
	panel_style.set_border_width_all(1)
	panel_style.set_content_margin_all(24)
	panel.add_theme_stylebox_override(&"panel", panel_style)
	root.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override(&"separation", 10)
	panel.add_child(column)

	_speaker = Label.new()
	_speaker.add_theme_color_override(&"font_color", Color(0.80, 0.68, 0.36))
	_speaker.add_theme_font_size_override(&"font_size", 26)
	column.add_child(_speaker)

	_text = Label.new()
	_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_text.add_theme_font_size_override(&"font_size", 28)
	column.add_child(_text)

	_choices = VBoxContainer.new()
	_choices.add_theme_constant_override(&"separation", 4)
	column.add_child(_choices)
