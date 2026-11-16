class_name RoomView
extends CanvasLayer
## Shows a room as a layered 2D scene (docs/DecisionLog.md, K-011).
##
## Layers, back to front:
##   Background  - the painted room, from assets/rooms/<room_id>.png
##   Props       - things that change over the campaign (beds, damage, evidence)
##   Characters  - 2D figures of whoever is in the room
##   Interface   - room name, narration, actions, passages, "leave" hint
##
## What can be done in a room comes from the CampaignDirector: this view only
## draws the buttons and shows the narration the director returns.
##
## Opens on EventBus.room_view_requested and announces itself with
## room_view_opened / room_view_closed.

const TEXT_COLOR := Color(0.86, 0.84, 0.72)
const ROOM_IMAGE_PATH: String = "res://assets/rooms/%s.png"
const CHARACTER_IMAGE_PATH: String = "res://assets/characters/%s/default.png"

var _director: CampaignDirector
var _room_id: StringName = &""
var _root: Control
var _background: TextureRect
var _prop_layer: Control
var _character_layer: HBoxContainer
var _title: Label
var _placeholder_note: Label
var _present: Label
var _narration: Label
var _narration_panel: PanelContainer
var _actions: HBoxContainer
var _links: HBoxContainer
var _hint: Label
var _placeholder_texture: Texture2D


func _ready() -> void:
	layer = 5
	_build_interface()
	visible = false
	EventBus.room_view_requested.connect(open)
	EventBus.residents_changed.connect(_refresh)
	EventBus.time_changed.connect(func(_day: int, _minutes: int) -> void: _refresh())
	EventBus.dialogue_ended.connect(func(_id: String) -> void: _refresh())


## Called once by the session scene. Without a director the view still works
## but offers no actions.
func setup(director: CampaignDirector) -> void:
	_director = director


func is_open() -> bool:
	return visible


func get_room_id() -> StringName:
	return _room_id


## Layer that changeable room props are added to.
func get_prop_layer() -> Control:
	return _prop_layer


## Ids of the actions currently offered; used by tests.
func get_action_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for button: Node in _actions.get_children():
		if not button.is_queued_for_deletion():
			ids.append(button.get_meta(&"action_id", ""))
	return ids


func get_narration_text() -> String:
	return _narration.text


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

	_set_narration("")
	visible = true
	_refresh()
	EventBus.room_view_opened.emit(_room_id)


func close() -> void:
	if not visible:
		return
	visible = false
	EventBus.room_view_closed.emit(_room_id)


## Performs one of the room's actions, as its button would.
func perform_action(action_id: String) -> void:
	if _director == null or not visible:
		return
	_set_narration(_director.perform_room_action(_room_id, action_id))
	_refresh()


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"interact"):
		close()
		get_viewport().set_input_as_handled()


## Rebuilds everything that depends on campaign state: who is here, what can
## be done, where one can go.
func _refresh() -> void:
	if not visible:
		return
	_clear(_character_layer)
	var names := PackedStringArray()
	for npc_id: String in GameState.get_room_occupants(_room_id):
		names.append(Roster.get_display_name(npc_id))
		_character_layer.add_child(_make_figure(npc_id))
	_present.visible = not names.is_empty()
	_present.text = tr("ROOMVIEW_PRESENT").format({"names": ", ".join(names)})

	_clear(_actions)
	if _director != null:
		for action: Dictionary in _director.get_room_actions(_room_id):
			var button: Button = _make_button(action["label"])
			button.set_meta(&"action_id", action["id"])
			button.pressed.connect(perform_action.bind(action["id"]))
			_actions.add_child(button)

	_clear(_links)
	for linked_id: StringName in HouseLayout.ROOM_LINKS.get(_room_id, []):
		var button: Button = _make_button(
			tr("ROOMVIEW_GO").format({"room": tr(HouseLayout.get_room(linked_id)["name_key"])})
		)
		button.pressed.connect(open.bind(linked_id))
		_links.add_child(button)


func _set_narration(text: String) -> void:
	_narration.text = text
	_narration_panel.visible = text != ""


func _clear(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override(&"font_size", 24)
	button.focus_mode = Control.FOCUS_NONE
	return button


## A resident's figure: their picture if it exists, otherwise a silhouette
## with their name.
func _make_figure(npc_id: String) -> Control:
	var path: String = CHARACTER_IMAGE_PATH % npc_id
	if ResourceLoader.exists(path):
		var picture := TextureRect.new()
		picture.texture = load(path) as Texture2D
		picture.custom_minimum_size = Vector2(300.0, 560.0)
		picture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		picture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		picture.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return picture
	var silhouette := Panel.new()
	silhouette.custom_minimum_size = Vector2(220.0, 520.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.05, 0.94)
	style.border_color = Color(0.22, 0.26, 0.24)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 80
	style.corner_radius_top_right = 80
	silhouette.add_theme_stylebox_override(&"panel", style)
	silhouette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var label: Label = _make_label(22)
	label.text = Roster.get_display_name(npc_id)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	silhouette.add_child(label)
	return silhouette


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

	_prop_layer = Control.new()
	_prop_layer.name = "Props"
	_prop_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_prop_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_prop_layer)

	# Figures stand along the lower middle of the picture.
	_character_layer = HBoxContainer.new()
	_character_layer.name = "Characters"
	_character_layer.anchor_left = 0.2
	_character_layer.anchor_right = 0.8
	_character_layer.anchor_top = 0.16
	_character_layer.anchor_bottom = 0.72
	_character_layer.alignment = BoxContainer.ALIGNMENT_CENTER
	_character_layer.add_theme_constant_override(&"separation", 40)
	_character_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(_character_layer)

	var header := VBoxContainer.new()
	header.position = Vector2(48.0, 76.0)
	header.add_theme_constant_override(&"separation", 2)
	_root.add_child(header)
	_title = _make_label(34)
	header.add_child(_title)
	_placeholder_note = _make_label(20)
	_placeholder_note.text = tr("ROOMVIEW_PLACEHOLDER")
	_placeholder_note.modulate = Color(1.0, 1.0, 1.0, 0.55)
	header.add_child(_placeholder_note)
	_present = _make_label(22)
	header.add_child(_present)

	# Everything along the bottom: narration, then actions, passages, hint.
	var footer := VBoxContainer.new()
	footer.anchor_left = 0.0
	footer.anchor_right = 1.0
	footer.anchor_top = 1.0
	footer.anchor_bottom = 1.0
	footer.offset_left = 48.0
	footer.offset_right = -48.0
	footer.offset_bottom = -36.0
	footer.grow_vertical = Control.GROW_DIRECTION_BEGIN
	footer.add_theme_constant_override(&"separation", 14)
	_root.add_child(footer)

	_narration_panel = PanelContainer.new()
	var narration_style := StyleBoxFlat.new()
	narration_style.bg_color = Color(0.04, 0.05, 0.05, 0.9)
	narration_style.border_color = Color(0.30, 0.32, 0.26)
	narration_style.set_border_width_all(1)
	narration_style.set_content_margin_all(20)
	_narration_panel.add_theme_stylebox_override(&"panel", narration_style)
	footer.add_child(_narration_panel)
	_narration = _make_label(26)
	_narration.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_narration_panel.add_child(_narration)

	_actions = HBoxContainer.new()
	_actions.add_theme_constant_override(&"separation", 14)
	footer.add_child(_actions)

	_links = HBoxContainer.new()
	_links.add_theme_constant_override(&"separation", 14)
	footer.add_child(_links)

	_hint = _make_label(22)
	_hint.modulate = Color(1.0, 1.0, 1.0, 0.7)
	footer.add_child(_hint)


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
