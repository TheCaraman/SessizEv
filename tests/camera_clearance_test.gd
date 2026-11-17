extends Node
## CAMERA-CLIP-001: the walking camera must never come close enough to any
## visible surface for its near plane to cut into it. Every visible mesh in the
## house gets a probe-only trimesh copy on its own layer (the player never
## touches it); the player is pushed against walls from a grid of points in
## every walkable room, and a sphere the size of the near plane's reach is
## tested at the camera.

const PROBE_LAYER: int = 1 << 19
const STEP: float = 0.5

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	GameState.new_campaign(5)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	var camera: Camera3D = player.get_node("Head/Camera3D")
	var probes: int = _add_probes(scene, player)
	check(probes > 100, "probe copies of visible house meshes (%d)" % probes)
	for frame: int in 2:
		await get_tree().physics_frame

	# Near-plane corner reach at the widest allowed field of view, 16:9.
	var fov: float = deg_to_rad(Settings.LIMITS["fov"].y)
	var half_h: float = camera.near * tan(fov * 0.5)
	var reach: float = Vector3(camera.near, half_h, half_h * 16.0 / 9.0).length()
	var sphere := SphereShape3D.new()
	sphere.radius = reach + 0.01
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.collision_mask = PROBE_LAYER
	var space: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state

	var body_query := PhysicsShapeQueryParameters3D.new()
	body_query.shape = (player.get_node("CollisionShape3D") as CollisionShape3D).shape
	body_query.collision_mask = player.collision_mask
	body_query.exclude = [player.get_rid()]

	# Control: a sphere on a known wall face must register, or the probe is blind.
	query.transform = Transform3D(Basis.IDENTITY, Vector3(5.0 + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5 + reach * 0.5, 1.6, 6.2))
	check(not space.intersect_shape(query, 1).is_empty(), "probe sees the hall wall it touches")

	var tested: int = 0
	var offenders: Dictionary = {}
	for room_id: StringName in HouseLayout.WALKABLE_ROOMS:
		var room: Dictionary = HouseLayout.get_room(room_id)
		var floor_y: float = HouseLayout.floor_height(int(room["floor"]))
		for rect: Rect2 in room["rects"]:
			var x: float = rect.position.x + 0.35
			while x < rect.end.x - 0.3:
				var z: float = rect.position.y + 0.35
				while z < rect.end.y - 0.3:
					var start := Vector3(x, floor_y + 0.05, z)
					if int(room["floor"]) == 1 and HouseLayout.is_in_void(Vector2(x, z)):
						z += STEP
						continue
					body_query.transform = Transform3D(Basis.IDENTITY, start + Vector3(0.0, 0.875, 0.0))
					if space.intersect_shape(body_query, 1).is_empty():
						for i: int in 16:
							# Walk fast into the wall at this heading and keep pushing,
							# so the body slides along it over every seam and corner.
							var angle: float = TAU * float(i) / 16.0
							player.global_position = start
							for step: int in 45:
								player.velocity = Vector3(cos(angle), 0.0, sin(angle)) * player.fast_speed
								player.move_and_slide()
								tested += 1
								_probe(space, query, camera, scene, offenders)
					z += STEP
				x += STEP
	# Seams: walk straight at the exact edge where a door or window box meets
	# the wall beside it. Physics casts must not slip between the two boxes.
	var seams: int = 0
	var leaks: Array[String] = []
	for body: Node in scene.find_children("*", "StaticBody3D", true, false):
		if not (body is RoomDoor or str(body.name).begins_with("Window")):
			continue
		var node3d := body as Node3D
		var shapes: Array[Node] = body.find_children("*", "CollisionShape3D", false, false)
		if shapes.is_empty() or not (shapes[0] as CollisionShape3D).shape is BoxShape3D:
			continue
		var half: float = ((shapes[0] as CollisionShape3D).shape as BoxShape3D).size.x * 0.5
		for edge: float in [-half - 0.002, -half, -half + 0.002, half - 0.002, half, half + 0.002]:
			for side: float in [1.0, -1.0, 0.725 / 0.75, -0.6 / 0.75, 0.9 / 0.75, -1.1]:
				var from: Vector3 = node3d.to_global(Vector3(edge, 0.05, side * 0.75))
				if node3d.global_position.y > 1.0:
					from.y = node3d.global_position.y + 0.05
				body_query.transform = Transform3D(Basis.IDENTITY, from + Vector3(0.0, 0.875, 0.0))
				if not space.intersect_shape(body_query, 1).is_empty():
					continue
				player.global_position = from
				player.move_and_collide(node3d.global_basis.z * -signf(side) * 1.5)
				seams += 1
				var left: float = absf(node3d.to_local(player.global_position).z)
				if left < 0.3:
					leaks.append("%s edge %.2f side %d stopped %.2f m from the plane" % [scene.get_path_to(body), edge, int(side), left])
	check(seams >= 20, "door and window seams probed (%d)" % seams)
	check(leaks.is_empty(), "no slipping through seams: %s" % "; ".join(leaks.slice(0, 6)))

	# Up and down the stairs: drop onto the ramp, then push into each side.
	var run: float = HouseLayout.STAIRS.size.y
	var z_stairs: float = HouseLayout.STAIRS.position.y + 0.2
	while z_stairs < HouseLayout.STAIRS.end.y - 0.1:
		var rise_here: float = HouseLayout.STOREY_HEIGHT * (HouseLayout.STAIRS.end.y - z_stairs) / run
		for x_stairs: float in [9.1, 9.5, 9.9]:
			for i: int in 8:
				var angle: float = TAU * float(i) / 8.0
				player.global_position = Vector3(x_stairs, rise_here + 0.4, z_stairs)
				player.move_and_collide(Vector3.DOWN * 1.0)
				player.move_and_collide(Vector3(cos(angle), 0.0, sin(angle)) * 1.5)
				tested += 1
				_probe(space, query, camera, scene, offenders)
		z_stairs += 0.4
	check(tested > 300, "camera tested against walls from many places (%d)" % tested)

	# Door transitions: the camera glides into the doorway; start from beside
	# the door as well as in front of it.
	var doors: int = 0
	for body: Node in scene.find_children("*", "StaticBody3D", true, false):
		var door := body as RoomDoor
		if door == null or door.is_front or door.locked or door.room_id == &"":
			continue
		for side: float in [1.0, -1.0]:
			for lateral: float in [-0.75, -0.4, 0.0, 0.4, 0.75]:
				for depth: float in [0.35, 0.6]:
					var start: Vector3 = door.to_global(Vector3(lateral, 0.05, side * depth))
					if not HouseLayout.WALKABLE_ROOMS.has(HouseLayout.room_at(start + Vector3(0.0, 0.5, 0.0))):
						continue
					body_query.transform = Transform3D(Basis.IDENTITY, start + Vector3(0.0, 0.875, 0.0))
					if not space.intersect_shape(body_query, 1).is_empty():
						continue
					player.global_position = start
					camera.look_at(door.to_global(Vector3(0.0, 1.5, 0.0)), Vector3.UP)
					var resting: Transform3D = camera.global_transform
					door.interact(player)
					doors += 1
					var began: int = Time.get_ticks_msec()
					while Time.get_ticks_msec() - began < int((RoomDoor.OPEN_SECONDS + RoomDoor.APPROACH_SECONDS - 0.03) * 1000.0):
						await get_tree().physics_frame
						_probe(space, query, camera, scene, offenders, "door %s: " % door.room_id)
					var abort := InputEventAction.new()
					abort.action = &"pause"
					abort.pressed = true
					door._unhandled_input(abort)
					camera.global_transform = resting
					await get_tree().physics_frame
	check(doors >= 6, "door transitions probed (%d)" % doors)
	var listed: Array = offenders.values()
	listed.sort()
	for line: String in listed:
		print("CLIP: ", line)
	check(offenders.is_empty(), "no visible surface inside the near plane (%d meshes; reach %.3f m)" % [offenders.size(), reach])
	scene.queue_free()
	await get_tree().process_frame
	if failures == 0:
		print("CAMERA CLEARANCE TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)


func _probe(space: PhysicsDirectSpaceState3D, query: PhysicsShapeQueryParameters3D, camera: Camera3D, scene: Node, offenders: Dictionary, label: String = "") -> void:
	query.transform = Transform3D(Basis.IDENTITY, camera.global_position)
	for hit: Dictionary in space.intersect_shape(query, 4):
		var mesh: Node = (hit["collider"] as Node).get_parent()
		var key: String = label + str(scene.get_path_to(mesh))
		if not offenders.has(key):
			offenders[key] = "%s at %s" % [key, str(camera.global_position.snapped(Vector3(0.01, 0.01, 0.01)))]


## A static trimesh copy of every visible mesh outside the player, on a layer
## only the probe sphere looks at.
func _add_probes(scene: Node, player: Node) -> int:
	var count: int = 0
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var part := node as MeshInstance3D
		if part.mesh == null or not part.is_visible_in_tree() or player.is_ancestor_of(part):
			continue
		var shape: ConcavePolygonShape3D = part.mesh.create_trimesh_shape()
		if shape == null:
			continue
		shape.backface_collision = true
		var body := StaticBody3D.new()
		body.collision_layer = PROBE_LAYER
		body.collision_mask = 0
		var collision := CollisionShape3D.new()
		collision.shape = shape
		body.add_child(collision)
		part.add_child(body)
		count += 1
	return count
