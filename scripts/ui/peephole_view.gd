class_name PeepholeView
extends CanvasLayer
## A free, read-only optical view. It never triggers an arrival or dialogue.

var viewport: SubViewport
var camera: Camera3D
var visitor_slot: Control
var visitor_id: String = ""
var _image: TextureRect
var _back: Button
var _player: PlayerController
var _door: Node3D
var _open: bool = false


func _ready() -> void:
	layer = 24
	viewport = SubViewport.new()
	viewport.name = "ExteriorViewport"
	viewport.world_2d = World2D.new()
	viewport.gui_disable_input = true
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(viewport)
	camera = Camera3D.new()
	camera.fov = 105.0
	camera.near = 0.03
	viewport.add_child(camera)
	visitor_slot = Control.new()
	visitor_slot.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	visitor_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport.add_child(visitor_slot)
	_image = TextureRect.new()
	_image.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_image.texture = viewport.get_texture()
	_image.mouse_filter = Control.MOUSE_FILTER_STOP
	var lens := ShaderMaterial.new()
	lens.shader = preload("res://shaders/peephole.gdshader")
	_image.material = lens
	add_child(_image)
	_back = Button.new()
	_back.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_back.offset_left = -160.0
	_back.offset_right = 160.0
	_back.offset_top = -68.0
	_back.offset_bottom = -20.0
	_back.pressed.connect(close)
	add_child(_back)
	get_viewport().size_changed.connect(_resize)
	Settings.preferences_changed.connect(_refresh)
	EventBus.visitor_changed.connect(func(_id: String) -> void: _refresh())
	EventBus.time_changed.connect(func(_day: int, _minutes: int) -> void: _refresh())
	EventBus.day_started.connect(func(_day: int) -> void: close())
	visible = false
	_resize()


func open(door: Node3D, player: PlayerController) -> void:
	if _open or not player.control_enabled:
		return
	_player = player
	_door = door
	viewport.world_3d = player.get_viewport().world_3d
	camera.global_position = door.to_global(Vector3(0.0, 1.48, 0.18))
	camera.look_at(camera.global_position + door.global_basis.z, Vector3.UP)
	camera.current = true
	_open = true
	visible = true
	_resize()
	_refresh()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	EventBus.door_transition_changed.emit(true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_back.grab_focus()


func close() -> void:
	if not _open:
		return
	_open = false
	visible = false
	viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	EventBus.door_transition_changed.emit(false)
	_player = null
	_door = null


func is_open() -> bool:
	return _open


func _unhandled_input(event: InputEvent) -> void:
	if _open and event.is_action_pressed(&"pause"):
		close()
		get_viewport().set_input_as_handled()


func _resize() -> void:
	var dimensions := Vector2i(get_viewport().get_visible_rect().size)
	viewport.size = Vector2i(maxi(dimensions.x, 1), maxi(dimensions.y, 1))
	visitor_slot.position = Vector2(dimensions) * Vector2(0.36, 0.16)
	visitor_slot.size = Vector2(dimensions) * Vector2(0.28, 0.76)
	for child: Control in visitor_slot.get_children():
		child.size = visitor_slot.size
	(_image.material as ShaderMaterial).set_shader_parameter("aspect", float(viewport.size.x) / float(viewport.size.y))


func _refresh() -> void:
	_back.text = tr("SETTINGS_BACK")
	_back.add_theme_font_size_override("font_size", 24)
	(_image.material as ShaderMaterial).set_shader_parameter("brightness", Settings.get_number("brightness"))
	if not _open:
		return
	# Public door state only: no infection, secret, trust or evidence lookup.
	if visitor_id != GameState.visitor:
		visitor_id = GameState.visitor
		for child: Node in visitor_slot.get_children():
			visitor_slot.remove_child(child)
			child.queue_free()
		if visitor_id != "":
			var figure: Control = RoomWorld.make_figure(visitor_id)
			figure.set_meta("npc_id", visitor_id)
			visitor_slot.add_child(figure)
			figure.size = visitor_slot.size
	var night: bool = posmod(GameState.minutes, 1440) >= 1200 or posmod(GameState.minutes, 1440) < 420
	visitor_slot.modulate = Color(0.57, 0.66, 0.64) if night else Color(0.90, 0.93, 0.88)


func _exit_tree() -> void:
	if _open:
		EventBus.door_transition_changed.emit(false)
