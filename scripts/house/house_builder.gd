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
const LAMP_COLOR := Color(0.96, 0.79, 0.56)
const RUNNER_WIDTH: float = 1.3
const SKIRTING_HEIGHT: float = 0.13
const CEILING_RAIL_HEIGHT: float = 0.09


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
	var exterior := preload("res://scripts/house/exterior_vista.gd").new()
	exterior.name = "ExteriorVista"
	add_child(exterior)

	var dressing := CorridorDressing.new()
	dressing.name = "CorridorDressing"
	add_child(dressing)


func _build_slabs() -> void:
	var w: float = HouseLayout.WIDTH
	var d: float = HouseLayout.DEPTH
	var slabs := Node3D.new()
	slabs.name = "Slabs"
	add_child(slabs)

	# Ground floor: one piece.
	_add_slab(slabs, Rect2(0.0, 0.0, w, d), 0.0)

	# Upper floor is complete except for the staircase opening.
	var upper: float = HouseLayout.STOREY_HEIGHT
	for piece: Rect2 in _cells_outside(Rect2(0.0, 0.0, w, d), HouseLayout.VOIDS):
		_add_slab(slabs, piece, upper)

	# A normal enclosed upper storey, no atrium or roof-light set.
	_add_slab(slabs, Rect2(0.0, 0.0, w, d), 2.0 * HouseLayout.STOREY_HEIGHT)


## Splits [param area] along every edge of [param holes] and returns the
## pieces that are not inside any hole.
static func _cells_outside(area: Rect2, holes: Array[Rect2]) -> Array[Rect2]:
	var xs: Array[float] = [area.position.x, area.end.x]
	var zs: Array[float] = [area.position.y, area.end.y]
	for hole: Rect2 in holes:
		for x: float in [hole.position.x, hole.end.x]:
			if x > area.position.x and x < area.end.x and not xs.has(x):
				xs.append(x)
		for z: float in [hole.position.y, hole.end.y]:
			if z > area.position.y and z < area.end.y and not zs.has(z):
				zs.append(z)
	xs.sort()
	zs.sort()
	var pieces: Array[Rect2] = []
	for i: int in xs.size() - 1:
		for j: int in zs.size() - 1:
			var cell := Rect2(xs[i], zs[j], xs[i + 1] - xs[i], zs[j + 1] - zs[j])
			var inside: bool = false
			for hole: Rect2 in holes:
				if hole.has_point(cell.get_center()):
					inside = true
					break
			if not inside:
				pieces.append(cell)
	return pieces


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
	if wall.get("guard", false):
		# Solid 1.1m guard preserves safe stair separation, opens the sightline.
		_add_wall_piece(holder, wall, wall["from"], wall["to"], base_y, 1.1, thickness)
		var along_x: bool = wall["axis"] == "x"
		var mid: float = (wall["from"] + wall["to"]) * 0.5
		var length: float = wall["to"] - wall["from"]
		var center := Vector3(mid, base_y + 1.12, wall["at"]) if along_x else Vector3(wall["at"], base_y + 1.12, mid)
		var size := Vector3(length, 0.06, 0.16) if along_x else Vector3(0.16, 0.06, length)
		_add_mesh(holder, center, size, &"wood_stairs")
		return

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
		elif opening.get("window", false):
			# Wall below the sill, then the window itself.
			_add_wall_piece(holder, wall, start, end, base_y, HouseLayout.WINDOW_SILL, thickness)
			_add_window(holder, wall, opening, base_y, thickness)
		cursor = end
	if cursor < wall["to"]:
		_add_wall_piece(holder, wall, cursor, wall["to"], base_y, WALL_HEIGHT, thickness)
	# Continuous cornice crosses the door lintels too, never broken into stubs.
	var along_x: bool = wall["axis"] == "x"
	var mid: float = (wall["from"] + wall["to"]) * 0.5
	var center := Vector3(mid, base_y + WALL_HEIGHT - 0.045, wall["at"]) if along_x else Vector3(wall["at"], base_y + WALL_HEIGHT - 0.045, mid)
	var size := Vector3(wall["to"] - wall["from"], 0.09, thickness + 0.04) if along_x else Vector3(thickness + 0.04, 0.09, wall["to"] - wall["from"])
	_add_mesh(holder, center, size, &"frame_paint")


## Adds one box of a wall between [param from] and [param to] along the wall's
## axis, starting at height [param bottom_y].
func _add_wall_piece(
	parent: Node3D, wall: Dictionary, from: float, to: float,
	bottom_y: float, height: float, thickness: float
) -> StaticBody3D:
	var mid: float = (from + to) * 0.5
	var length: float = to - from
	var center_y: float = bottom_y + height * 0.5
	var along_x: bool = wall["axis"] == "x"
	var center := Vector3(mid, center_y, wall["at"]) if along_x else Vector3(wall["at"], center_y, mid)
	var size := Vector3(length, height, thickness) if along_x else Vector3(thickness, height, length)
	var piece: StaticBody3D = _add_box(parent, center, size, &"wallpaper")

	# Full-height pieces get a skirting board and a dark rail under the ceiling,
	# both standing proud of the wall on either side.
	# The patterned paper runs floor to ceiling (HOUSE-ATMOS-001): no dado panel.
	if is_equal_approx(height, WALL_HEIGHT):
		var trims: Array[Array] = [
			[SKIRTING_HEIGHT * 0.5, SKIRTING_HEIGHT, 0.036, &"frame_paint"],
			[SKIRTING_HEIGHT + 0.012, 0.024, 0.05, &"frame_paint"],
		]
		for trim: Array in trims:
			var trim_center := center
			trim_center.y = bottom_y + (trim[0] as float)
			var trim_size := size
			trim_size.y = trim[1]
			if along_x:
				trim_size.z = thickness + (trim[2] as float)
			else:
				trim_size.x = thickness + (trim[2] as float)
			_add_mesh(parent, trim_center, trim_size, trim[3])
	return piece


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
	door.is_front = opening.get("front", false)
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

	var leaf := Node3D.new()
	leaf.name = "DoorLeaf"
	door.add_child(leaf)
	_add_mesh(leaf, Vector3(0.0, height * 0.5, 0.0), Vector3(width, height, DOOR_THICKNESS), &"door_paint")
	# Panels: a wide one at the top, two tall ones below, a low one at the foot.
	# Each is three stepped layers (moulding, field, raised centre).
	var panels: Array[Rect2] = [
		Rect2(-0.33, 1.52, 0.66, 0.44),
		Rect2(-0.33, 0.50, 0.30, 0.92),
		Rect2(0.03, 0.50, 0.30, 0.92),
		Rect2(-0.33, 0.12, 0.66, 0.28),
	]
	for side: float in [-1.0, 1.0]:
		var face: float = side * DOOR_THICKNESS * 0.5
		for panel: Rect2 in panels:
			var c: Vector2 = panel.get_center()
			_add_mesh(leaf, Vector3(c.x, c.y, face + side * 0.004), Vector3(panel.size.x, panel.size.y, 0.008), &"trim_door")
			_add_mesh(leaf, Vector3(c.x, c.y, face + side * 0.007), Vector3(panel.size.x - 0.05, panel.size.y - 0.05, 0.014), &"door_panel_paint")
			_add_mesh(leaf, Vector3(c.x, c.y, face + side * 0.012), Vector3(panel.size.x - 0.13, panel.size.y - 0.13, 0.024), &"door_paint")
		# Handle: backplate, spindle boss, lever and keyhole cover.
		var handle_x: float = width * 0.5 - 0.075
		_add_mesh(leaf, Vector3(handle_x, 1.02, face + side * 0.006), Vector3(0.04, 0.20, 0.012), &"brass")
		_add_mesh(leaf, Vector3(handle_x, 1.06, face + side * 0.022), Vector3(0.028, 0.028, 0.032), &"brass")
		_add_mesh(leaf, Vector3(handle_x - 0.055, 1.06, face + side * 0.042), Vector3(0.13, 0.018, 0.018), &"brass")
		_add_mesh(leaf, Vector3(handle_x, 0.96, face + side * 0.013), Vector3(0.018, 0.03, 0.006), &"trim_dark")
	door.configure_leaf(leaf, width)

	# Light switch beside the door, on both faces of the wall.
	for face_side: float in [-1.0, 1.0]:
		var switch_z: float = face_side * (wall_thickness * 0.5 + 0.008)
		_add_mesh(door, Vector3(width * 0.5 + 0.28, 1.15, switch_z), Vector3(0.085, 0.085, 0.016), &"frame_paint")
		_add_mesh(door, Vector3(width * 0.5 + 0.28, 1.155, switch_z + face_side * 0.01), Vector3(0.022, 0.04, 0.012), &"frame_paint")

	# Architrave: a wide flat casing with a narrower raised bead on top of it,
	# on both sides of the wall, plus the lining inside the opening.
	var lining_depth: float = wall_thickness + 0.02
	for side: float in [-1.0, 1.0]:
		_add_mesh(
			door, Vector3(side * (width * 0.5 + 0.01), height * 0.5, 0.0),
			Vector3(0.02, height, lining_depth), &"frame_paint"
		)
	_add_mesh(door, Vector3(0.0, height + 0.01, 0.0), Vector3(width + 0.04, 0.02, lining_depth), &"frame_paint")
	for face_side: float in [-1.0, 1.0]:
		var wall_face: float = face_side * wall_thickness * 0.5
		for side: float in [-1.0, 1.0]:
			_add_mesh(
				door, Vector3(side * (width * 0.5 + 0.06), (height + 0.10) * 0.5, wall_face + face_side * 0.009),
				Vector3(0.10, height + 0.10, 0.018), &"frame_paint"
			)
			_add_mesh(
				door, Vector3(side * (width * 0.5 + 0.085), (height + 0.10) * 0.5, wall_face + face_side * 0.022),
				Vector3(0.035, height + 0.10, 0.012), &"frame_paint"
			)
		_add_mesh(
			door, Vector3(0.0, height + 0.06, wall_face + face_side * 0.009),
			Vector3(width + 0.22, 0.10, 0.018), &"frame_paint"
		)
		_add_mesh(
			door, Vector3(0.0, height + 0.125, wall_face + face_side * 0.016),
			Vector3(width + 0.28, 0.035, 0.032), &"frame_paint"
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
	# The ramp is only what the player walks on; the visible stairs are steps.
	(ramp.get_child(1) as MeshInstance3D).visible = false

	var steps := Node3D.new()
	steps.name = "Steps"
	add_child(steps)
	var count: int = 18
	var step_rise: float = rise / float(count)
	var step_run: float = run / float(count)
	var inner_width: float = stairs.size.x - HouseLayout.INTERIOR_WALL_THICKNESS
	for i: int in count:
		var top: float = step_rise * float(i + 1)
		var z: float = stairs.end.y - step_run * (float(i) + 0.5)
		# Solid block up to this step, a paler riser, and a tread with a nosing.
		_add_mesh(steps, Vector3(center.x, top * 0.5, z), Vector3(inner_width, top, step_run), &"wood_stairs")
		_add_mesh(
			steps, Vector3(center.x, top - step_rise * 0.5, z + step_run * 0.5 + 0.004),
			Vector3(inner_width, step_rise - 0.03, 0.008), &"frame_paint"
		)
		_add_mesh(
			steps, Vector3(center.x, top - 0.012, z + 0.014),
			Vector3(inner_width, 0.03, step_run + 0.03), &"wood_stairs"
		)

	# Open side of the stair: a balustrade over the hall, with an invisible
	# barrier following the slope so nobody steps off into the hall.
	var length: float = sqrt(rise * rise + run * run)
	var edge_x: float = stairs.position.x + 0.03
	# A slanted prism with vertical ends, so it stops exactly at the foot and
	# the head of the stairs (IMMERSION I-03). A box rotated to the slope stuck
	# its corners 25 cm out past both ends, just above the floor, and caught
	# players stepping off the bottom step beside the hall guard.
	var barrier := StaticBody3D.new()
	barrier.name = "StairBalustrade"
	var barrier_shape := ConvexPolygonShape3D.new()
	var half_thickness: float = 0.03
	var barrier_height: float = 1.0
	var points := PackedVector3Array()
	for x: float in [edge_x - half_thickness, edge_x + half_thickness]:
		points.append(Vector3(x, 0.0, stairs.end.y))
		points.append(Vector3(x, barrier_height, stairs.end.y))
		points.append(Vector3(x, rise, stairs.position.y))
		points.append(Vector3(x, rise + barrier_height, stairs.position.y))
	barrier_shape.points = points
	var barrier_collision := CollisionShape3D.new()
	barrier_collision.shape = barrier_shape
	barrier.add_child(barrier_collision)
	add_child(barrier)
	var balustrade_rail: MeshInstance3D = _add_mesh(steps, Vector3(edge_x, rise * 0.5 + 0.95, center.y), Vector3(0.07, 0.06, length), &"wood_stairs")
	balustrade_rail.rotation.x = angle
	for i: int in count:
		var t: float = (float(i) + 0.5) / float(count)
		var step_top: float = step_rise * float(i + 1)
		PropMeshes.cylinder(steps, Vector3(edge_x, step_top + 0.46, stairs.end.y - run * t), 0.014, 0.014, 0.92,
			HouseMaterials.get_material(&"frame_paint"), Vector3.ZERO, 8)

	# Handrail on the hall-side wall, following the slope, on four brackets.
	var rail_x: float = stairs.position.x + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5 + 0.07
	var rail: MeshInstance3D = _add_mesh(
		steps, Vector3(rail_x, rise * 0.5 + 0.95, center.y),
		Vector3(0.05, 0.05, sqrt(rise * rise + run * run) - 0.3), &"wood_stairs"
	)
	rail.rotation.x = angle
	for i: int in 4:
		var t: float = (float(i) + 0.5) / 4.0
		_add_mesh(
			steps, Vector3(rail_x - 0.035, rise * t + 0.92, stairs.end.y - run * t),
			Vector3(0.07, 0.02, 0.02), &"brass"
		)


## Pale plaster ceiling panels over the corridors and the stairwell.
func _build_ceilings() -> void:
	var ceilings := Node3D.new()
	ceilings.name = "Ceilings"
	add_child(ceilings)
	for room: Dictionary in HouseLayout.ROOMS:
		if not HouseLayout.WALKABLE_ROOMS.has(room["id"]):
			continue
		var base_y: float = HouseLayout.floor_height(room["floor"])
		for rect: Rect2 in room["rects"]:
			# Downstairs, no ceiling where the hall opens up to the roof.
			var pieces: Array[Rect2] = [rect]
			if room["floor"] == 0:
				pieces = _cells_outside(rect, HouseLayout.VOIDS)
			for piece: Rect2 in pieces:
				_add_ceiling_panel(ceilings, piece, base_y + WALL_HEIGHT)
	# Ceiling above the staircase.
	var skylight: Array[Rect2] = []
	for opening: Rect2 in HouseLayout.VOIDS:
		for piece: Rect2 in _cells_outside(opening, skylight):
			_add_ceiling_panel(ceilings, piece, HouseLayout.STOREY_HEIGHT + WALL_HEIGHT)


func _add_ceiling_panel(parent: Node3D, rect: Rect2, ceiling_y: float) -> void:
	var center: Vector2 = rect.get_center()
	_add_mesh(
		parent, Vector3(center.x, ceiling_y - 0.01, center.y),
		Vector3(rect.size.x, 0.02, rect.size.y), &"ceiling"
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
		if room["floor"] == 0 and HouseLayout.is_in_void(center):
			# Under the open hall the lamp hangs on a long flex from the roof.
			var drop_to: float = ceiling_y + 0.5
			var roof_y: float = HouseLayout.STOREY_HEIGHT + WALL_HEIGHT
			var flex := _add_mesh(lamps, Vector3(center.x, (roof_y + drop_to) * 0.5, center.y), Vector3(0.012, roof_y - drop_to, 0.012), &"trim_dark")
			flex.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			ceiling_y = drop_to
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
	var shade := MeshInstance3D.new()
	var cover := CylinderMesh.new()
	cover.top_radius = 0.15
	cover.bottom_radius = 0.19
	cover.height = 0.08
	cover.radial_segments = 48
	var cover_material := HouseMaterials.get_material(&"lamp_shade").duplicate() as StandardMaterial3D
	cover_material.emission_energy_multiplier = 0.6
	cover.material = cover_material
	shade.mesh = cover
	shade.position = ceiling_point + Vector3(0.0, -0.05, 0.0)
	parent.add_child(shade)
	shade.add_to_group("electric_fittings")
	shade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var lamp := OmniLight3D.new()
	lamp.add_to_group("electric_lights")
	lamp.name = lamp_name
	lamp.position = ceiling_point + Vector3(0.0, -0.25, 0.0)
	lamp.omni_range = light_range
	lamp.light_color = LAMP_COLOR
	# Weak warm pools: the corridors are lit mostly by the cold haze.
	lamp.light_energy = 0.32
	lamp.omni_attenuation = 1.6
	lamp.shadow_enabled = true
	lamp.shadow_blur = 2.5
	lamp.light_volumetric_fog_energy = 0.5
	parent.add_child(lamp)


## Adds a curtained window in an exterior wall: a solid pane you cannot walk
## through, a glazed frame, a sill, two curtains that do not quite meet, and
## daylight from outside that reaches in through the gap.
func _add_window(
	parent: Node3D, wall: Dictionary, opening: Dictionary, base_y: float, wall_thickness: float
) -> void:
	var width: float = opening.get("width", HouseLayout.DOOR_WIDTH)
	var sill: float = HouseLayout.WINDOW_SILL
	var height: float = HouseLayout.DOOR_HEIGHT - sill
	var middle: float = sill + height * 0.5

	# Window space: X across the window, Z through the wall. `out` is the sign
	# of Z that points outdoors.
	var window := StaticBody3D.new()
	window.name = "Window_F%d_%s" % [wall["floor"], str(opening["pos"]).replace(".", "_")]
	var out: float
	if wall["axis"] == "x":
		window.position = Vector3(opening["pos"], base_y, wall["at"])
		out = 1.0 if wall["at"] > HouseLayout.DEPTH * 0.5 else -1.0
	else:
		window.position = Vector3(wall["at"], base_y, opening["pos"])
		window.rotation.y = PI * 0.5
		out = 1.0 if wall["at"] > HouseLayout.WIDTH * 0.5 else -1.0
	parent.add_child(window)

	var shape := BoxShape3D.new()
	shape.size = Vector3(width, height, 0.05)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	collision.position = Vector3(0.0, middle, 0.0)
	window.add_child(collision)

	# An actual exterior vista replaces the opaque luminous card.

	# Frame, one upright and one cross bar. These throw shadows into the room.
	for side: float in [-1.0, 1.0]:
		_add_mesh(window, Vector3(side * (width * 0.5 - 0.025), middle, 0.0), Vector3(0.05, height, 0.07), &"frame_paint")
		_add_mesh(window, Vector3(0.0, middle + side * (height * 0.5 - 0.025), 0.0), Vector3(width, 0.05, 0.07), &"frame_paint")
	_add_mesh(window, Vector3(0.0, middle, 0.0), Vector3(0.035, height, 0.05), &"frame_paint")
	_add_mesh(window, Vector3(0.0, sill + height * 0.62, 0.0), Vector3(width, 0.035, 0.05), &"frame_paint")

	# Sill board and casing on the room side.
	var inner: float = -out * wall_thickness * 0.5
	_add_mesh(window, Vector3(0.0, sill - 0.015, inner - out * 0.05), Vector3(width + 0.20, 0.03, 0.14), &"frame_paint")
	for side: float in [-1.0, 1.0]:
		_add_mesh(window, Vector3(side * (width * 0.5 + 0.045), middle, inner - out * 0.009), Vector3(0.09, height + 0.18, 0.018), &"frame_paint")
	_add_mesh(window, Vector3(0.0, sill + height + 0.045, inner - out * 0.009), Vector3(width + 0.18, 0.09, 0.018), &"frame_paint")

	# Venetian blinds, half tilted: daylight comes through the gaps as stripes
	# and visible shafts in the haze (HOUSE-ATMOS-001).
	_add_blinds(window, width, sill + height - 0.02, sill + height * 0.76, inner - out * 0.045, out)

	# Open cream curtains frame the outdoor view instead of sealing the window.
	var curtain_z: float = inner - out * 0.10
	var curtain_top: float = sill + height + 0.16
	var curtain_bottom: float = sill - 0.22
	_add_mesh(window, Vector3(0.0, curtain_top + 0.02, curtain_z), Vector3(width + 0.40, 0.022, 0.022), &"brass")
	_add_curtain(window, -width * 0.5 - 0.12, -0.34, curtain_bottom, curtain_top - curtain_bottom, curtain_z)
	_add_curtain(window, 0.34, width * 0.5 + 0.12, curtain_bottom, curtain_top - curtain_bottom, curtain_z)
	# Daylight: a spot outside, aimed through the window and down the corridor.
	# Low, raking, from one side: the shafts cut diagonally across the room.
	var from := Vector3(0.9, sill + height + 0.9, out * 2.6)
	var toward := Vector3(-0.9, 0.0, -out * 4.2)
	var daylight := SpotLight3D.new()
	daylight.name = "Daylight"
	daylight.add_to_group("window_lights")
	daylight.transform = Transform3D(Basis.looking_at(toward - from, Vector3.UP), from)
	daylight.light_color = Color(0.67, 0.86, 0.76)
	daylight.light_energy = 3.8
	daylight.spot_range = 14.0
	daylight.spot_angle = 26.0
	daylight.spot_angle_attenuation = 0.5
	daylight.spot_attenuation = 0.6
	daylight.shadow_enabled = true
	# Crisp enough that the blind slats print as stripes.
	daylight.shadow_blur = 0.4
	daylight.light_volumetric_fog_energy = 2.4
	window.add_child(daylight)
	# Broad low-energy bounced daylight, local to the actual window.
	var bounce := OmniLight3D.new()
	bounce.name = "WindowBounce"
	bounce.position = Vector3(0.0, 1.45, -out * 0.8)
	bounce.light_color = Color(0.57, 0.78, 0.69)
	bounce.light_energy = 0.7
	bounce.omni_range = 6.0
	bounce.omni_attenuation = 1.6
	bounce.shadow_enabled = false
	bounce.add_to_group("window_lights")
	window.add_child(bounce)

	# At night a cold moon- and streetlight comes in through the same slats.
	# Its strength follows the clock (house_blockout: moon_lights).
	var moon := SpotLight3D.new()
	moon.name = "Moonlight"
	moon.add_to_group("moon_lights")
	var moon_from := Vector3(-0.7, sill + height + 1.4, out * 3.0)
	var moon_toward := Vector3(0.6, 0.0, -out * 4.0)
	moon.transform = Transform3D(Basis.looking_at(moon_toward - moon_from, Vector3.UP), moon_from)
	moon.light_color = Color(0.54, 0.75, 0.76)
	moon.light_energy = 3.8
	moon.spot_range = 11.0
	moon.spot_angle = 24.0
	moon.spot_angle_attenuation = 0.5
	moon.shadow_enabled = true
	moon.shadow_blur = 0.4
	moon.light_volumetric_fog_energy = 4.0
	window.add_child(moon)

## Dusty venetian blinds across a window: a head rail, two cords and a stack
## of thin tilted slats. One slat hangs askew. [param out] is the outdoor Z
## sign in window space.
func _add_blinds(window: Node3D, width: float, top: float, bottom: float, z: float, out: float) -> void:
	var slat_material: Material = HouseMaterials.get_material(&"blind_slat")
	_add_mesh(window, Vector3(0.0, top + 0.03, z), Vector3(width + 0.06, 0.045, 0.06), &"frame_paint")
	var pitch: float = 0.052
	var count: int = int((top - bottom) / pitch)
	for i: int in count:
		var slat := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(width - 0.02, 0.004, 0.05)
		mesh.material = slat_material
		slat.mesh = mesh
		slat.position = Vector3(0.0, top - pitch * (float(i) + 0.5), z)
		# Half open, the room-side edge lower, so light falls downward.
		slat.rotation.x = -out * 0.62
		if i == int(count * 0.62):
			slat.rotation.z = 0.06
			slat.position.y -= 0.012
		window.add_child(slat)
	for side: float in [-0.32, 0.32]:
		_add_mesh(window, Vector3(side * width, (top + bottom) * 0.5, z + out * 0.012), Vector3(0.004, top - bottom, 0.004), &"blind_slat")


## A hanging curtain between two X positions: one continuous sheet of cloth
## with soft vertical folds, gathered on rings under the rail. Thin enough
## that daylight behind it glows through (CORRIDOR-REFERENCE-002).
func _add_curtain(
	window: Node3D, from_x: float, to_x: float, bottom: float, height: float, z: float
) -> void:
	var width: float = to_x - from_x
	var folds: int = maxi(int(round(width / 0.075)), 2)
	# Seed from the position so every curtain in the house hangs differently.
	var seed_value: int = int(absf(window.position.x * 37.0 + window.position.z * 101.0 + from_x * 13.0))
	var cloth := MeshInstance3D.new()
	cloth.name = "Curtain"
	cloth.mesh = PropMeshes.cloth_mesh(width, width * 1.04, height, folds, 0.028, seed_value)
	cloth.mesh.surface_set_material(0, HouseMaterials.get_material(&"curtain_cloth"))
	cloth.position = Vector3((from_x + to_x) * 0.5, bottom + height, z)
	window.add_child(cloth)
	# Curtain rings along the rail.
	var ring_material: Material = HouseMaterials.get_material(&"brass")
	for i: int in folds + 1:
		var ring_x: float = from_x + width * float(i) / float(folds)
		PropMeshes.cylinder(
			window, Vector3(ring_x, bottom + height + 0.012, z), 0.014, 0.014, 0.006,
			ring_material, Vector3(PI * 0.5, 0.0, 0.0), 10
		)


## Carpet runners along the downstairs hall and the upstairs corridor.
func _build_runners() -> void:
	# Downstairs down the middle of the hall; upstairs along the gallery,
	# clear of the parapet over the open hall.
	var placements: Array[Array] = [[6.875, 7.2, 6.4, RUNNER_WIDTH], [5.88, 6.7, 5.6, 0.95]]
	for floor_index: int in 2:
		var length: float = placements[floor_index][2]
		var runner_width: float = placements[floor_index][3]
		var quad := QuadMesh.new()
		quad.size = Vector2(runner_width, length)
		# The runner texture is square; repeat it along the length.
		var material := HouseMaterials.get_material(&"runner").duplicate() as StandardMaterial3D
		material.uv1_scale = Vector3(1.0, length / runner_width, 1.0)
		quad.material = material
		var runner := MeshInstance3D.new()
		runner.name = "Runner_F%d" % floor_index
		runner.mesh = quad
		runner.rotation.x = -PI * 0.5
		runner.position = Vector3(placements[floor_index][0], HouseLayout.floor_height(floor_index) + 0.006, placements[floor_index][1])
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
