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
var _hinge: Node3D
var _opening: bool = false
var _held_open: bool = false
var _tween: Tween
var _portal: MeshInstance3D
var _width: float = 0.9

func configure_leaf(leaf: Node3D, width: float) -> void:
	_width = width
	_hinge = Node3D.new()
	_hinge.name = "Hinge"
	_hinge.position.x = -width * 0.5
	add_child(_hinge)
	leaf.reparent(_hinge, true)
	EventBus.room_view_closed.connect(func(_room: StringName) -> void:
		if _held_open:
			_hinge.rotation.y = 0.0
			_held_open = false
			if _portal != null:
				_portal.visible = false
	)

func _show_room_threshold() -> void:
	var visuals := RoomVisuals.new()
	var look: Dictionary = visuals.resolve(str(room_id), GameState.minutes, GameState.power_incident.get("state", "") != "outage")
	if not ResourceLoader.exists(look["path"]):
		return
	var texture: Texture2D = load(look["path"])
	if _portal == null:
		_portal = MeshInstance3D.new()
		_portal.name = "RoomThreshold"
		var quad := QuadMesh.new()
		quad.size = Vector2(_width, HouseLayout.DOOR_HEIGHT)
		_portal.mesh = quad
		_portal.position.y = HouseLayout.DOOR_HEIGHT * 0.5
		add_child(_portal)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = texture
	material.albedo_color = look["background_tint"]
	var crop: float = (_width / HouseLayout.DOOR_HEIGHT) / (texture.get_width() / float(texture.get_height()))
	material.uv1_scale = Vector3(crop, 1.0, 1.0)
	material.uv1_offset = Vector3((1.0 - crop) * 0.5, 0.0, 0.0)
	_portal.material_override = material
	_portal.visible = true

func _exit_tree() -> void:
	if _opening:
		EventBus.door_transition_changed.emit(false)


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
	if _opening or _held_open:
		return
	if _hinge == null:
		return
	_opening = true
	EventBus.door_transition_changed.emit(true)
	var direction: float = 1.0
	if player is Node3D and to_local(player.global_position).z < 0.0:
		direction = -1.0
	_show_room_threshold()
	if _portal != null:
		_portal.position.z = -direction * 0.065
	_tween = create_tween()
	_tween.tween_property(_hinge, "rotation:y", direction * deg_to_rad(82.0), 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_callback(func() -> void:
		_held_open = true
		EventBus.room_view_requested.emit(room_id)
		_opening = false
		EventBus.door_transition_changed.emit(false)
	)
