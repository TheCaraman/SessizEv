class_name HouseBuilder
extends Node3D
## Builds the 3D part of the house from HouseLayout at runtime.
##
## Only the corridors are walkable (docs/DecisionLog.md, K-011): the entrance,
## the hall, the staircase, the landing and the upstairs corridor. Every
## opening from a corridor into a room is closed by a RoomDoor; using it shows
## the room as a 2D scene. Walls of the rooms themselves are still built so
## the house stays one closed, consistent solid.

const WALL_HEIGHT: float = HouseLayout.STOREY_HEIGHT - HouseLayout.SLAB_THICKNESS
const DOOR_THICKNESS: float = 0.05
const LAMP_COLOR := Color(1.0, 0.90, 0.66)
const RUNNER_WIDTH: float = 1.1


func _ready() -> void:
	build()


## Removes any previous geometry and rebuilds the whole house.
func build() -> void:
	for child: Node in get_children():
		child.queue_free()
	_build_slabs()
	for wall: Dictionary in HouseLayout.WALLS:
		_build_wall(wall)
	_build_stairs()
	_build_ceilings()
	_build_lamps()
	_build_runners()


func _build_slabs() -> void:
	var w: float = HouseLayout.WIDTH
	var d: float = HouseLayout.DEPTH
	var stairs: Rect2 = HouseLayout.STAIRS
	var slabs := Node3D.new()
	slabs.name = "Slabs"
	add_child(slabs)

	# Ground floor: one piece.
	_add_slab(slabs, Rect2(0.0, 0.0, w, d), 0.0)

	# Upper floor: four pieces leaving a hole above the staircase.
	var upper: float = HouseLayout.STOREY_HEIGHT
	_add_slab(slabs, Rect2(0.0, 0.0, stairs.position.x, d), upper)
	_add_slab(slabs, Rect2(stairs.end.x, 0.0, w - stairs.end.x, d), upper)
	_add_slab(slabs, Rect2(stairs.position.x, 0.0, stairs.size.x, stairs.position.y), upper)
	_add_slab(slabs, Rect2(stairs.position.x, stairs.end.y, stairs.size.x, d - stairs.end.y), upper)

	# Roof.
	_add_slab(slabs, Rect2(0.0, 0.0, w, d), 2.0 * HouseLayout.STOREY_HEIGHT)


## Adds a slab whose top surface is at [param top_y].
func _add_slab(parent: Node3D, rect: Rect2, top_y: float) -> void:
	var center: Vector2 = rect.get_center()
	var thickness: float = HouseLayout.SLAB_THICKNESS
	_add_box(
		parent,
		Vector3(center.x, top_y - thickness * 0.5, center.y),
		Vector3(rect.size.x, thickness, rect.size.y),
		&"parquet"
	)


func _build_wall(wall: Dictionary) -> void:
	var exterior: bool = wall.get("exterior", false)
	var thickness: float = (
		HouseLayout.EXTERIOR_WALL_THICKNESS if exterior else HouseLayout.INTERIOR_WALL_THICKNESS
	)
	var base_y: float = HouseLayout.floor_height(wall["floor"])

	var holder := Node3D.new()
	holder.name = "Wall_F%d_%s_%s" % [wall["floor"], wall["axis"], str(wall["at"]).replace(".", "_")]
	add_child(holder)

	var openings: Array = (wall["openings"] as Array).duplicate()
	openings.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["pos"] < b["pos"])

	var cursor: float = wall["from"]
	for opening: Dictionary in openings:
		var width: float = opening.get("width", HouseLayout.DOOR_WIDTH)
		var start: float = opening["pos"] - width * 0.5
		var end: float = opening["pos"] + width * 0.5
		if start > cursor:
			_add_wall_piece(holder, wall, cursor, start, base_y, WALL_HEIGHT, thickness)
		# Lintel above the opening.
		_add_wall_piece(
			holder, wall, start, end,
			base_y + HouseLayout.DOOR_HEIGHT, WALL_HEIGHT - HouseLayout.DOOR_HEIGHT, thickness
		)
		if opening.has("to") or opening.get("sealed", false):
			_add_door(holder, wall, opening, base_y, thickness)
		cursor = end
	if cursor < wall["to"]:
		_add_wall_piece(holder, wall, cursor, wall["to"], base_y, WALL_HEIGHT, thickness)


## Adds one box of a wall between [param from] and [param to] along the wall's
## axis, starting at height [param bottom_y].
func _add_wall_piece(
	parent: Node3D, wall: Dictionary, from: float, to: float,
	bottom_y: float, height: float, thickness: float
) -> StaticBody3D:
	var mid: float = (from + to) * 0.5
	var length: float = to - from
	var center_y: float = bottom_y + height * 0.5
	if wall["axis"] == "x":
		return _add_box(
			parent, Vector3(mid, center_y, wall["at"]), Vector3(length, height, thickness), &"wallpaper_green"
		)
	return _add_box(
		parent, Vector3(wall["at"], center_y, mid), Vector3(thickness, height, length), &"wallpaper_green"
	)


## Adds a closed panelled door with its frame in an opening. Doors with a
## "to" room open that room's 2D scene; sealed exterior doors are locked.
func _add_door(
	parent: Node3D, wall: Dictionary, opening: Dictionary, base_y: float, wall_thickness: float
) -> void:
	var width: float = opening.get("width", HouseLayout.DOOR_WIDTH)
	var height: float = HouseLayout.DOOR_HEIGHT

	var door := RoomDoor.new()
	door.room_id = opening.get("to", &"")
	door.locked = opening.get("sealed", false)
	door.name = "Door_%s" % (opening.get("id", door.room_id))
	if wall["axis"] == "x":
		door.position = Vector3(opening["pos"], base_y, wall["at"])
	else:
		door.position = Vector3(wall["at"], base_y, opening["pos"])
		door.rotation.y = PI * 0.5
	parent.add_child(door)

	# From here on everything is in door space: X across the door, Z through it.
	var shape := BoxShape3D.new()
	shape.size = Vector3(width, height, DOOR_THICKNESS)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(0.0, height * 0.5, 0.0)
	door.add_child(collision)

	_add_mesh(door, Vector3(0.0, height * 0.5, 0.0), Vector3(width, height, DOOR_THICKNESS), &"door_paint")
	for side: float in [-1.0, 1.0]:
		var face_z: float = side * (DOOR_THICKNESS * 0.5 + 0.008)
		# Three raised panels: one wide at the top, two tall below.
		_add_mesh(door, Vector3(0.0, 1.72, face_z), Vector3(width - 0.22, 0.46, 0.016), &"door_panel_paint")
		_add_mesh(door, Vector3(-0.19, 0.78, face_z), Vector3(0.27, 1.22, 0.016), &"door_panel_paint")
		_add_mesh(door, Vector3(0.19, 0.78, face_z), Vector3(0.27, 1.22, 0.016), &"door_panel_paint")
		# Handle plate and lever.
		var handle_z: float = side * (DOOR_THICKNESS * 0.5 + 0.012)
		_add_mesh(door, Vector3(width * 0.5 - 0.07, 1.02, handle_z), Vector3(0.035, 0.16, 0.012), &"brass")
		_add_mesh(
			door, Vector3(width * 0.5 - 0.12, 1.04, side * (DOOR_THICKNESS * 0.5 + 0.035)),
			Vector3(0.12, 0.02, 0.02), &"brass"
		)

	# Frame, standing slightly proud of the wall on both sides.
	var frame_depth: float = wall_thickness + 0.04
	for side: float in [-1.0, 1.0]:
		_add_mesh(
			door, Vector3(side * (width * 0.5 + 0.035), height * 0.5 + 0.035, 0.0),
			Vector3(0.07, height + 0.07, frame_depth), &"frame_paint"
		)
	_add_mesh(door, Vector3(0.0, height + 0.035, 0.0), Vector3(width, 0.07, frame_depth), &"frame_paint")


## The staircase is a single ramp: bottom at the south edge on floor 0, top at
## the north edge on floor 1 (docs/DecisionLog.md, V-012).
func _build_stairs() -> void:
	var stairs: Rect2 = HouseLayout.STAIRS
	var rise: float = HouseLayout.STOREY_HEIGHT
	var run: float = stairs.size.y
	var angle: float = atan2(rise, run)
	var thickness: float = 0.2
	var center: Vector2 = stairs.get_center()
	var ramp: StaticBody3D = _add_box(
		self,
		Vector3(center.x, rise * 0.5 - thickness * 0.5 * cos(angle), center.y),
		Vector3(stairs.size.x, thickness, sqrt(rise * rise + run * run)),
		&"wood_stairs",
		Vector3(angle, 0.0, 0.0)
	)
	ramp.name = "Stairs"


## Dark ceiling panels over the corridors and the stairwell.
func _build_ceilings() -> void:
	var ceilings := Node3D.new()
	ceilings.name = "Ceilings"
	add_child(ceilings)
	for room: Dictionary in HouseLayout.ROOMS:
		if not HouseLayout.WALKABLE_ROOMS.has(room["id"]):
			continue
		var base_y: float = HouseLayout.floor_height(room["floor"])
		for rect: Rect2 in room["rects"]:
			_add_ceiling_panel(ceilings, rect, base_y + WALL_HEIGHT)
	_add_ceiling_panel(ceilings, HouseLayout.STAIRS, HouseLayout.STOREY_HEIGHT + WALL_HEIGHT)


func _add_ceiling_panel(parent: Node3D, rect: Rect2, ceiling_y: float) -> void:
	var center: Vector2 = rect.get_center()
	_add_mesh(
		parent, Vector3(center.x, ceiling_y - 0.01, center.y),
		Vector3(rect.size.x, 0.02, rect.size.y), &"ceiling_dark"
	)


func _build_lamps() -> void:
	var lamps := Node3D.new()
	lamps.name = "Lamps"
	add_child(lamps)
	for room: Dictionary in HouseLayout.ROOMS:
		if not HouseLayout.WALKABLE_ROOMS.has(room["id"]):
			continue
		var rect: Rect2 = room["rects"][0]
		var center: Vector2 = rect.get_center()
		var ceiling_y: float = HouseLayout.floor_height(room["floor"]) + WALL_HEIGHT
		_add_lamp(
			lamps, "Lamp_%s" % room["id"],
			Vector3(center.x, ceiling_y, center.y), maxf(rect.size.x, rect.size.y) + 2.0
		)
	var stair_center: Vector2 = HouseLayout.STAIRS.get_center()
	_add_lamp(
		lamps, "Lamp_stairs",
		Vector3(stair_center.x, HouseLayout.STOREY_HEIGHT + WALL_HEIGHT, stair_center.y), 7.5
	)


## A flat ceiling fitting with a light just below it.
func _add_lamp(parent: Node3D, lamp_name: String, ceiling_point: Vector3, light_range: float) -> void:
	var shade: MeshInstance3D = _add_mesh(
		parent, ceiling_point + Vector3(0.0, -0.05, 0.0), Vector3(0.28, 0.06, 0.28), &"lamp_shade"
	)
	shade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var lamp := OmniLight3D.new()
	lamp.name = lamp_name
	lamp.position = ceiling_point + Vector3(0.0, -0.25, 0.0)
	lamp.omni_range = light_range
	lamp.light_color = LAMP_COLOR
	lamp.light_energy = 1.25
	lamp.omni_attenuation = 1.2
	lamp.shadow_enabled = true
	parent.add_child(lamp)


## Carpet runners along the downstairs hall and the upstairs corridor.
func _build_runners() -> void:
	for floor_index: int in 2:
		var length: float = 5.0
		var quad := QuadMesh.new()
		quad.size = Vector2(RUNNER_WIDTH, length)
		# The runner texture is square; repeat it along the length.
		var material := HouseMaterials.get_material(&"runner").duplicate() as StandardMaterial3D
		material.uv1_scale = Vector3(1.0, length / RUNNER_WIDTH, 1.0)
		quad.material = material
		var runner := MeshInstance3D.new()
		runner.name = "Runner_F%d" % floor_index
		runner.mesh = quad
		runner.rotation.x = -PI * 0.5
		runner.position = Vector3(6.0, HouseLayout.floor_height(floor_index) + 0.006, 5.75)
		runner.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(runner)


## Adds a solid, visible box. [param euler] is the rotation in radians.
func _add_box(
	parent: Node3D, center: Vector3, size: Vector3, material: StringName,
	euler: Vector3 = Vector3.ZERO
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = center
	body.rotation = euler

	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)

	_add_mesh(body, Vector3.ZERO, size, material)
	parent.add_child(body)
	return body


## Adds a visible box with no collision.
func _add_mesh(parent: Node3D, center: Vector3, size: Vector3, material: StringName) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = HouseMaterials.get_material(material)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	mesh_instance.position = center
	parent.add_child(mesh_instance)
	return mesh_instance
