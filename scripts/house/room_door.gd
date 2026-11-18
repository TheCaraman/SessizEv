class_name RoomDoor
extends StaticBody3D
## A corridor door. Using it shows the 2D scene of the room behind it.
##
## The physical leaf opens before the layered room is revealed. The player
## remains on the corridor side; room navigation is still 2D.
##
## The front door is a special case: it leads outside, stays locked, and can
## only be used while a visitor is waiting on the step.

## Room shown when the door is used. Empty for doors that lead nowhere yet.
var room_id: StringName = &""
## A locked door shows a "locked" prompt and cannot be used.
var locked: bool = false
## True for the house's front door.
var is_front: bool = false
## How long the leaf takes to swing shut after the player leaves the room.
const CLOSE_SECONDS: float = 0.45
## Leaf swing when opening. The camera's step into the doorway runs in
## parallel (DOOR-REFERENCE-003), starting APPROACH_DELAY later so the leaf
## is already moving clear.
const OPEN_SECONDS: float = 0.4
const APPROACH_DELAY: float = 0.08
const APPROACH_SECONDS: float = 0.32
## From pressing the key to the room view, with camera motion on.
## Equals max(OPEN_SECONDS, APPROACH_DELAY + APPROACH_SECONDS); the door test
## checks that.
const TRANSITION_SECONDS: float = 0.4
## With camera motion off the camera does not move: a shorter leaf swing,
## then RoomView dissolves in over RoomView.DISSOLVE_SECONDS.
const REDUCED_OPEN_SECONDS: float = 0.25

var _hinge: Node3D
var _opening: bool = false
var _held_open: bool = false
var _closing: bool = false
var _tween: Tween
var _portal: MeshInstance3D
var _width: float = 0.9
var _cover: ColorRect
var _camera: Camera3D
var _camera_start: Transform3D
var _preview_viewport: SubViewport
var _composition: RoomWorld
var _power_source: PowerIncident
## FOLEY-001: open and close cues, built on first use.
var _sound: AudioStreamPlayer3D
var _open_cue: AudioStream
var _close_cue: AudioStream
## Emitted when the door plays a cue (&"open" or &"close").
signal sound_played(kind: StringName)

func configure_leaf(leaf: Node3D, width: float) -> void:
	_width = width
	_hinge = Node3D.new()
	_hinge.name = "Hinge"
	_hinge.position.x = -width * 0.5
	add_child(_hinge)
	var transition := CanvasLayer.new()
	transition.layer = 20
	add_child(transition)
	_cover = ColorRect.new()
	_cover.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cover.color = Color(0.008, 0.012, 0.01)
	_cover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cover.visible = false
	transition.add_child(_cover)
	leaf.reparent(_hinge, true)
	_sound = AudioStreamPlayer3D.new()
	_sound.name = "DoorSound"
	_sound.position = Vector3(0.0, 1.05, 0.0)
	_sound.volume_db = -9.0
	_sound.unit_size = 4.0
	_sound.max_distance = 20.0
	add_child(_sound)
	if is_front:
		add_child(PeepholeInteraction.new())
	EventBus.room_view_closed.connect(_on_room_view_closed)
	EventBus.time_changed.connect(func(_day: int, _minutes: int) -> void:
		if _portal != null and _portal.visible and (_opening or _closing):
			_show_room_threshold()
	)
	EventBus.residents_changed.connect(_refresh_preview)
	Settings.preferences_changed.connect(_refresh_preview)
	get_viewport().size_changed.connect(_refresh_preview)


## Back in the corridor the door is still standing open where the player left
## it, and swings shut behind them. Control returns at once; the door cannot
## be reopened until it has closed. (DOOR-CLOSE-001)
func _on_room_view_closed(_room: StringName) -> void:
	if not _held_open:
		return
	_held_open = false
	_closing = true
	_show_room_threshold()
	_play_cue(&"close")
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_hinge, "rotation:y", 0.0, CLOSE_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(func() -> void:
		_closing = false
		if _portal != null:
			_portal.visible = false
		if _preview_viewport != null:
			_preview_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	)


## True while the leaf is swinging shut after leaving a room.
func is_closing() -> bool:
	return _closing

func _refresh_preview() -> void:
	if _portal != null and _portal.visible and (_opening or _closing):
		_show_room_threshold()

func _on_preview_power_changed(_powered: bool) -> void:
	_refresh_preview()

func _show_room_threshold() -> void:
	# Screen-matched image through a physical aperture, never a scaled card.
	if _portal == null:
		_portal = MeshInstance3D.new()
		_portal.name = "RoomThreshold"
		var quad := QuadMesh.new()
		quad.size = Vector2(_width, HouseLayout.DOOR_HEIGHT)
		_portal.mesh = quad
		_portal.position.y = HouseLayout.DOOR_HEIGHT * 0.5
		var material := ShaderMaterial.new()
		material.shader = preload("res://shaders/door_room_preview.gdshader")
		_portal.material_override = material
		add_child(_portal)
		_preview_viewport = SubViewport.new()
		_preview_viewport.name = "RoomPreviewViewport"
		_preview_viewport.disable_3d = true
		_preview_viewport.world_2d = World2D.new()
		_preview_viewport.gui_disable_input = true
		add_child(_preview_viewport)
		_composition = RoomWorld.new()
		_composition.name = "World"
		_composition.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		_preview_viewport.add_child(_composition)
	_preview_viewport.size = Vector2i(get_viewport().get_visible_rect().size)
	_composition.size = Vector2(_preview_viewport.size)
	_preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	var parent: Node = get_parent()
	var powered: bool = true
	while parent != null:
		var director: Node = parent.get_node_or_null("CampaignDirector")
		if director is CampaignDirector:
			powered = director.power.is_powered()
			if _power_source != director.power:
				if _power_source != null and _power_source.power_changed.is_connected(_on_preview_power_changed):
					_power_source.power_changed.disconnect(_on_preview_power_changed)
				_power_source = director.power
				_power_source.power_changed.connect(_on_preview_power_changed)
			break
		parent = parent.get_parent()
	_composition.show_room(room_id, GameState.minutes, powered, false)
	var material: ShaderMaterial = _portal.material_override
	material.set_shader_parameter("room_image", _preview_viewport.get_texture())
	material.set_shader_parameter("room_tint", Color.WHITE)
	_portal.visible = true

func _exit_tree() -> void:
	if _sound != null:
		_sound.stop()
	if _power_source != null and _power_source.power_changed.is_connected(_on_preview_power_changed):
		_power_source.power_changed.disconnect(_on_preview_power_changed)
	if is_instance_valid(_camera) and _camera.is_inside_tree():
		_camera.global_transform = _camera_start
	if _opening:
		EventBus.door_transition_changed.emit(false)

func _unhandled_input(event: InputEvent) -> void:
	if not _opening or not event.is_action_pressed(&"pause"):
		return
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if is_instance_valid(_camera):
		_camera.global_transform = _camera_start
	_camera = null
	_hinge.rotation.y = 0.0
	_portal.visible = false
	if _sound != null:
		_sound.stop()
	_preview_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	_opening = false
	EventBus.door_transition_changed.emit(false)
	get_viewport().set_input_as_handled()


## The leaf has its own sound: the latch and hinge as it opens, a falling
## creak and the frame hit (timed to CLOSE_SECONDS) as it swings shut.
func _play_cue(kind: StringName) -> void:
	if _sound == null:
		return
	if kind == &"open":
		if _open_cue == null:
			_open_cue = Foley.door_open()
		_sound.stream = _open_cue
	else:
		if _close_cue == null:
			_close_cue = Foley.door_close(CLOSE_SECONDS)
		_sound.stream = _close_cue
	_sound.play()
	sound_played.emit(kind)


func get_interaction_prompt() -> String:
	if is_front:
		if GameState.visitor != "":
			return tr("PROMPT_ANSWER_DOOR").format({"key": InputSetup.get_key_label(&"interact")})
		return tr("PROMPT_LOCKED")
	if locked or room_id == &"":
		return tr("PROMPT_LOCKED")
	var room: Dictionary = HouseLayout.get_room(room_id)
	return tr("PROMPT_ENTER_ROOM").format({
		"key": InputSetup.get_key_label(&"interact"),
		"room": tr(room.get("name_key", "")),
	})


func interact(player: Node) -> void:
	if is_front:
		if GameState.visitor != "":
			EventBus.front_door_used.emit()
		return
	if locked or room_id == &"":
		return
	if _opening or _held_open or _closing:
		return
	if _hinge == null:
		return
	_opening = true
	EventBus.door_transition_changed.emit(true)
	_play_cue(&"open")
	var direction: float = 1.0
	if player is Node3D and to_local(player.global_position).z < 0.0:
		direction = -1.0
	_show_room_threshold()
	if _portal != null:
		_portal.position.z = -direction * 0.065
	# DOOR-REFERENCE-003: the leaf starts at once (ease-out, no slow wind-up)
	# and the step into the doorway runs alongside it, so the room is shown
	# after TRANSITION_SECONDS instead of leaf-then-approach.
	var reduced: bool = Settings.get_number("camera_motion") < 0.5
	_tween = create_tween()
	_tween.tween_property(_hinge, "rotation:y", direction * deg_to_rad(82.0), REDUCED_OPEN_SECONDS if reduced else OPEN_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_camera = player.get_node_or_null("Head/Camera3D") as Camera3D
	if _camera != null:
		_camera_start = _camera.global_transform
		# Reduced motion: the camera stays put; RoomView dissolves in instead.
		if not reduced:
			var eye_height: float = clampf(to_local(_camera.global_position).y, 0.35, HouseLayout.DOOR_HEIGHT - 0.25)
			var destination: Vector3 = to_global(Vector3(0.0, eye_height, direction * 0.18))
			var target: Transform3D = _camera.global_transform
			target.origin = destination
			target = target.looking_at(to_global(Vector3(0.0, eye_height, -direction)), Vector3.UP)
			_tween.parallel().tween_property(_camera, "global_transform", target, APPROACH_SECONDS).set_delay(APPROACH_DELAY).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(func() -> void:
		_held_open = true
		EventBus.room_view_requested.emit(room_id)
		_preview_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		if is_instance_valid(_camera):
			_camera.global_transform = _camera_start
		_camera = null
		_cover.visible = false
		_opening = false
		EventBus.door_transition_changed.emit(false)
	)
