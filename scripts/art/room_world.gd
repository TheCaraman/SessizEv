class_name RoomWorld
extends Control
## Shared world-only room drawing. No buttons, dialogue or campaign mutations.
const FigureScript = preload("res://scripts/art/room_figure.gd")
const CHARACTER_IMAGE_PATH: String = "res://assets/characters/%s/default.png"
var background: TextureRect
var props: RoomProps
var characters: HBoxContainer
var resident_ids: Array[String] = []
var _visuals := RoomVisuals.new()
var _placeholder: Texture2D
var _room_id: StringName = &""

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.01, 0.02, 0.02)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	background = TextureRect.new()
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)
	props = RoomProps.new()
	props.name = "Props"
	props.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(props)
	characters = HBoxContainer.new()
	characters.name = "Characters"
	characters.anchor_left = 0.2
	characters.anchor_right = 0.8
	characters.anchor_top = 0.42
	characters.anchor_bottom = 0.90
	characters.alignment = BoxContainer.ALIGNMENT_CENTER
	characters.add_theme_constant_override(&"separation", 40)
	characters.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(characters)

func show_room(id: StringName, minutes: int, powered: bool, canvas_brightness: bool = true) -> Dictionary:
	var visual: Dictionary = _visuals.resolve(str(id), minutes, powered)
	var available: bool = ResourceLoader.exists(visual["path"])
	var texture: Texture2D = load(visual["path"]) as Texture2D if available else _get_placeholder()
	if background.texture != texture or id != _room_id:
		background.texture = texture
		props.show_room(str(id), texture.get_size())
	_room_id = id
	# The corridor post-process already applies brightness to a 3D aperture.
	# Native canvas rooms sit above that pass and apply it here instead.
	background.modulate = Settings.world_tint(visual["background_tint"]) if canvas_brightness else visual["background_tint"]
	props.modulate = Settings.world_tint(visual["actor_tint"]) if canvas_brightness else visual["actor_tint"]
	characters.modulate = props.modulate
	var occupants: Array[String] = GameState.get_room_occupants(id)
	if occupants != resident_ids:
		for child: Node in characters.get_children():
			characters.remove_child(child)
			child.queue_free()
		resident_ids = occupants.duplicate()
		for npc_id: String in resident_ids:
			var figure: Control = make_figure(npc_id)
			figure.set_meta(&"npc_id", npc_id)
			characters.add_child(figure)
	visual["available"] = available
	return visual

static func make_figure(npc_id: String) -> Control:
	var path: String = CHARACTER_IMAGE_PATH % npc_id
	if ResourceLoader.exists(path):
		var picture := FigureScript.new()
		picture.texture = load(path) as Texture2D
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
	var label := Label.new()
	label.add_theme_font_size_override(&"font_size", 22)
	label.text = Roster.get_display_name(npc_id)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	silhouette.add_child(label)
	return silhouette

func _get_placeholder() -> Texture2D:
	if _placeholder == null:
		var noise := FastNoiseLite.new()
		noise.seed = 5
		noise.frequency = 0.02
		var image := Image.create_empty(320, 180, false, Image.FORMAT_RGB8)
		for y: int in 180:
			for x: int in 320:
				var offset := Vector2(float(x) / 320.0 - 0.5, float(y) / 180.0 - 0.5)
				var falloff: float = clampf(1.0 - offset.length() * 1.5, 0.0, 1.0)
				var value: float = 0.5 + 0.5 * noise.get_noise_2d(x, y)
				image.set_pixel(x, y, Color(0.05, 0.16, 0.14).lerp(Color(0.16, 0.30, 0.24), value) * falloff)
		_placeholder = ImageTexture.create_from_image(image)
	return _placeholder
