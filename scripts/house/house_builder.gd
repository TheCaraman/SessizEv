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
const LAMP_COLOR := Color(0.88, 0.91, 0.78)
const RUNNER_WIDTH: float = 1.1
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

	var dressing := CorridorDressing.new()
	dressing.name = "CorridorDressing"
	add_child(dressing)


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
		elif opening.get("window", false):
			# Wall below the sill, then the window itself.
			_add_wall_piece(holder, wall, start, end, base_y, HouseLayout.WINDOW_SILL, thickness)
			_add_window(holder, wall, opening, base_y, thickness)
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
	var along_x: bool = wall["axis"] == "x"
	var center := Vector3(mid, center_y, wall["at"]) if along_x else Vector3(wall["at"], center_y, mid)
	var size := Vector3(length, height, thickness) if along_x else Vector3(thickness, height, length)
	var piece: StaticBody3D = _add_box(parent, center, size, &"wallpaper")

	# Full-height pieces get a skirting board and a dark rail under the ceiling,
	# both standing proud of the wall on either side.
	if is_equal_approx(height, WALL_HEIGHT):
		var lower_center := center
		lower_center.y = bottom_y + 0.40
		var lower_size := size
		lower_size.y = 0.80
		if along_x:
			lower_size.z += 0.018
		else:
			lower_size.x += 0.018
		_add_mesh(parent, lower_center, lower_size, &"wainscot")
		lower_center.y = bottom_y + 0.81
		lower_size.y = 0.025
		_add_mesh(parent, lower_center, lower_size, &"trim_dark")
		var trims: Array[Array] = [
			[SKIRTING_HEIGHT * 0.5, SKIRTING_HEIGHT, 0.036, &"frame_paint"],
			[SKIRTING_HEIGHT + 0.012, 0.024, 0.05, &"frame_paint"],
			[WALL_HEIGHT - CEILING_RAIL_HEIGHT * 0.5, CEILING_RAIL_HEIGHT, 0.04, &"frame_paint"],
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
	var count: int = 16
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
			_add_ceiling_panel(ceilings, rect, base_y + WALL_HEIGHT)
	_add_ceiling_panel(ceilings, HouseLayout.STAIRS, HouseLayout.STOREY_HEIGHT + WALL_HEIGHT)


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

	# Bright overcast sky behind the glass. It must not block the daylight.
	var sky: MeshInstance3D = _add_mesh(
		window, Vector3(0.0, middle, out * (wall_thickness * 0.5 + 0.02)),
		Vector3(width + 0.3, height + 0.3, 0.01), &"window_sky"
	)
	sky.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	sky.add_to_group("window_backdrops")

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

	# Curtain rail and two curtains leaving an off-centre gap.
	var curtain_z: float = inner - out * 0.07
	var curtain_top: float = sill + height + 0.16
	var curtain_bottom: float = sill - 0.28
	var curtain_height: float = curtain_top - curtain_bottom
	var curtain_middle: float = (curtain_top + curtain_bottom) * 0.5
	var left_edge: float = -width * 0.5 - 0.12
	var right_edge: float = width * 0.5 + 0.12
	var gap_left: float = -0.10
	var gap_right: float = 0.30
	_add_mesh(window, Vector3(0.0, curtain_top + 0.02, curtain_z), Vector3(width + 0.36, 0.022, 0.022), &"brass")
	_add_curtain(window, left_edge, gap_left, curtain_bottom, curtain_height, curtain_z)
	_add_curtain(window, gap_right, right_edge, curtain_bottom, curtain_height, curtain_z)

	# Daylight: a spot outside, aimed through the window and down the corridor.
	var from := Vector3(0.12, sill + height + 0.5, out * 1.8)
	var toward := Vector3(0.12, 0.2, -out * 4.5)
	var daylight := SpotLight3D.new()
	daylight.name = "Daylight"
	daylight.add_to_group("window_lights")
	daylight.transform = Transform3D(Basis.looking_at(toward - from, Vector3.UP), from)
	daylight.light_color = Color(0.92, 0.95, 1.0)
	daylight.light_energy = 3.0
	daylight.spot_range = 11.0
	daylight.spot_angle = 22.0
	daylight.spot_angle_attenuation = 0.5
	daylight.spot_attenuation = 0.6
	daylight.shadow_enabled = true
	daylight.shadow_blur = 1.5
	daylight.light_volumetric_fog_energy = 2.2
	window.add_child(daylight)

## A hanging curtain between two X positions, built from narrow vertical
## strips that alternate in depth so it reads as folded cloth, not a board.
func _add_curtain(
	window: Node3D, from_x: float, to_x: float, bottom: float, height: float, z: float
) -> void:
	var strip: float = 0.055
	var count: int = maxi(int(round((to_x - from_x) / strip)), 1)
	var step: float = (to_x - from_x) / float(count)
	for i: int in count:
		var fold: float = 0.014 if i % 2 == 0 else -0.014
		# Hems hang at slightly different lengths.
		var drop: float = 0.02 * float((i * 7) % 3)
		_add_mesh(
			window,
			Vector3(from_x + step * (float(i) + 0.5), bottom + (height - drop) * 0.5 + drop, z + fold),
			Vector3(step + 0.004, height - drop, 0.02),
			&"curtain"
		)


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
		runner.position = Vector3(5.5, HouseLayout.floor_height(floor_index) + 0.006, 5.75)
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
