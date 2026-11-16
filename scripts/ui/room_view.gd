class_name RoomView
extends CanvasLayer
## Shows a room as a layered 2D scene (docs/DecisionLog.md, K-011).
##
## Layers, back to front:
##   Background  - the painted room, from assets/rooms/<room_id>.png
##   Props       - things that change over the campaign (beds, damage, evidence)
##   Characters  - 2D figures of whoever is in the room
##   Interface   - room name, passages to linked rooms, "leave" hint
##
## The prop and character layers are empty containers for now; the systems
## that fill them (residents, room state) do not exist yet.
##
## Opens on EventBus.room_view_requested and announces itself with
## room_view_opened / room_view_closed.

const TEXT_COLOR := Color(0.86, 0.84, 0.72)
const ROOM_IMAGE_PATH: String = "res://assets/rooms/%s.png"

var _room_id: StringName = &""
var _root: Control
var _background: TextureRect
var _prop_layer: Control
var _character_layer: Control
var _title: Label
var _placeholder_note: Label
var _hint: Label
var _links: HBoxContainer
var _placeholder_texture: Texture2D


func _ready() -> void:
	layer = 5
	_build_interface()
	visible = false
	EventBus.room_view_requested.connect(open)


func is_open() -> bool:
	return visible


func get_room_id() -> StringName:
	return _room_id


## Layer that resident figures are added to.
func get_character_layer() -> Control:
	return _character_layer


## Layer that changeable room props are added to.
func get_prop_layer() -> Control:
	return _prop_layer


func open(room_id: StringName) -> void:
	var room: Dictionary = HouseLayout.get_room(room_id)
	if room.is_empty() or HouseLayout.WALKABLE_ROOMS.has(room_id):
		push_warning("RoomView: '%s' is not a 2D room" % room_id)
		return
	_room_id = room_id
	_title.text = tr(room["name_key"])
	_hint.text = tr("ROOMVIEW_LEAVE").format({
		"key": "%s / %s" % [InputSetup.get_key_label(&"interact"), InputSetup.get_key_label(&"pause")],
	})

	var path: String = ROOM_IMAGE_PATH % room_id
	var has_image: bool = ResourceLoader.exists(path)
	_background.texture = load(path) as Texture2D if has_image else _get_placeholder()
	_placeholder_note.visible = not has_image

	for child: Node in _links.get_children():
		child.queue_free()
	for linked_id: StringName in HouseLayout.ROOM_LINKS.get(room_id, []):
		var button := Button.new()
		button.text = tr("ROOMVIEW_GO").format({"room": tr(HouseLayout.get_room(linked_id)["name_key"])})
		button.add_theme_font_size_override(&"font_size", 26)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(open.bind(linked_id))
		_links.add_child(button)

	visible = true
	EventBus.room_view_opened.emit(_room_id)


func close() -> void:
	if not visible:
		return
	visible = false
	EventBus.room_view_closed.emit(_room_id)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"interact"):
		close()
		get_viewport().set_input_as_handled()


func _build_interface() -> void:
	_root = Control.new()
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.01, 0.02, 0.02)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(backdrop)

	_background = TextureRect.new()
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_background)

	_prop_layer = _make_layer("Props")
	_character_layer = _make_layer("Characters")

	_title = _make_label(34)
	_title.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_title.position = Vector2(48.0, 36.0)
	_root.add_child(_title)

	_placeholder_note = _make_label(22)
	_placeholder_note.text = tr("ROOMVIEW_PLACEHOLDER")
	_placeholder_note.modulate = Color(1.0, 1.0, 1.0, 0.6)
	_placeholder_note.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_placeholder_note.position = Vector2(48.0, 84.0)
	_root.add_child(_placeholder_note)

	_links = HBoxContainer.new()
	_links.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_links.position = Vector2(48.0, -150.0)
	_links.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_links.add_theme_constant_override(&"separation", 16)
	_root.add_child(_links)

	_hint = _make_label(24)
	_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_hint.position = Vector2(48.0, -72.0)
	_hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_root.add_child(_hint)


func _make_layer(layer_name: String) -> Control:
	var control := Control.new()
	control.name = layer_name
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(control)
	return control


func _make_label(font_size: int) -> Label:
	var label := Label.new()
	label.add_theme_color_override(&"font_color", TEXT_COLOR)
	label.add_theme_color_override(&"font_outline_color", Color(0.02, 0.04, 0.03))
	label.add_theme_constant_override(&"outline_size", 8)
	label.add_theme_font_size_override(&"font_size", font_size)
	return label


## A murky green stand-in shown until a room has a painted image.
func _get_placeholder() -> Texture2D:
	if _placeholder_texture != null:
		return _placeholder_texture
	var width: int = 320
	var height: int = 180
	var noise := FastNoiseLite.new()
	noise.seed = 5
	noise.frequency = 0.02
	var image := Image.create_empty(width, height, false, Image.FORMAT_RGB8)
	for y: int in height:
		for x: int in width:
			var offset := Vector2(float(x) / width - 0.5, float(y) / height - 0.5)
			var falloff: float = clampf(1.0 - offset.length() * 1.5, 0.0, 1.0)
			var value: float = 0.5 + 0.5 * noise.get_noise_2d(x, y)
			image.set_pixel(x, y, Color(0.05, 0.16, 0.14).lerp(Color(0.16, 0.30, 0.24), value) * falloff)
	_placeholder_texture = ImageTexture.create_from_image(image)
	return _placeholder_texture
