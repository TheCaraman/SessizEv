class_name HouseBuilder
extends Node3D
## Builds the house from HouseLayout at runtime.
##
## Structure is made of solid boxes: floor slabs, walls with door-height
## openings, sealed exterior door panels and a ramp for the staircase.
## Each room also gets a ceiling panel and, unless it has its own dressing
## (furniture and lighting), one plain lamp.

const WALL_HEIGHT: float = HouseLayout.STOREY_HEIGHT - HouseLayout.SLAB_THICKNESS
const DOOR_PANEL_THICKNESS: float = 0.08
const LAMP_COLOR := Color(1.0, 0.80, 0.52)

## Rooms that bring their own lighting through a dressing node.
const DRESSED_ROOMS: Array[StringName] = [&"living_room"]


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

	var living_room := LivingRoomDressing.new()
	living_room.name = "LivingRoomDressing"
	add_child(living_room)


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
		&"floorboards"
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
			_add_wall_piece(holder, wall, cursor, start, base_y, WALL_HEIGHT, thickness, &"wallpaper")
		# Lintel above the opening.
		_add_wall_piece(
			holder, wall, start, end,
			base_y + HouseLayout.DOOR_HEIGHT, WALL_HEIGHT - HouseLayout.DOOR_HEIGHT,
			thickness, &"wallpaper"
		)
		if opening.get("sealed", false):
			var panel: StaticBody3D = _add_wall_piece(
				holder, wall, start, end, base_y, HouseLayout.DOOR_HEIGHT,
				DOOR_PANEL_THICKNESS, &"door_panel"
			)
			panel.name = String(opening.get("id", &"sealed_door"))
		cursor = end
	if cursor < wall["to"]:
		_add_wall_piece(holder, wall, cursor, wall["to"], base_y, WALL_HEIGHT, thickness, &"wallpaper")


## Adds one box of a wall between [param from] and [param to] along the wall's
## axis, starting at height [param bottom_y].
func _add_wall_piece(
	parent: Node3D, wall: Dictionary, from: float, to: float,
	bottom_y: float, height: float, thickness: float, material: StringName
) -> StaticBody3D:
	var mid: float = (from + to) * 0.5
	var length: float = to - from
	var center_y: float = bottom_y + height * 0.5
	if wall["axis"] == "x":
		return _add_box(
			parent, Vector3(mid, center_y, wall["at"]), Vector3(length, height, thickness), material
		)
	return _add_box(
		parent, Vector3(wall["at"], center_y, mid), Vector3(thickness, height, length), material
	)


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


## Thin plaster panels under each slab so ceilings do not show floorboards.
func _build_ceilings() -> void:
	var ceilings := Node3D.new()
	ceilings.name = "Ceilings"
	add_child(ceilings)
	var material: StandardMaterial3D = HouseMaterials.get_material(&"plaster")
	for room: Dictionary in HouseLayout.ROOMS:
		var base_y: float = HouseLayout.floor_height(room["floor"])
		for rect: Rect2 in room["rects"]:
			var center: Vector2 = rect.get_center()
			var mesh := BoxMesh.new()
			mesh.size = Vector3(rect.size.x, 0.02, rect.size.y)
			mesh.material = material
			var panel := MeshInstance3D.new()
			panel.mesh = mesh
			panel.position = Vector3(center.x, base_y + WALL_HEIGHT - 0.01, center.y)
			ceilings.add_child(panel)


func _build_lamps() -> void:
	var lamps := Node3D.new()
	lamps.name = "Lamps"
	add_child(lamps)
	for room: Dictionary in HouseLayout.ROOMS:
		if DRESSED_ROOMS.has(room["id"]):
			continue
		var rect: Rect2 = room["rects"][0]
		var center: Vector2 = rect.get_center()
		var base_y: float = HouseLayout.floor_height(room["floor"])
		_add_lamp(
			lamps, "Lamp_%s" % room["id"],
			Vector3(center.x, base_y + WALL_HEIGHT - 0.3, center.y),
			maxf(rect.size.x, rect.size.y) + 1.5
		)
	# One lamp high in the stairwell.
	var stair_center: Vector2 = HouseLayout.STAIRS.get_center()
	_add_lamp(
		lamps, "Lamp_stairs",
		Vector3(stair_center.x, HouseLayout.STOREY_HEIGHT + WALL_HEIGHT - 0.3, stair_center.y),
		7.0
	)


func _add_lamp(parent: Node3D, lamp_name: String, at: Vector3, light_range: float) -> void:
	var lamp := OmniLight3D.new()
	lamp.name = lamp_name
	lamp.position = at
	lamp.omni_range = light_range
	lamp.light_color = LAMP_COLOR
	lamp.light_energy = 0.8
	lamp.shadow_enabled = true
	parent.add_child(lamp)


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

	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = HouseMaterials.get_material(material)
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	body.add_child(mesh_instance)

	parent.add_child(body)
	return body
