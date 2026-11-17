extends Node
## HOUSE-ACCESS-001: in the real house, Daniel can walk to every room door
## and the front door, and can use each one.
##
## A route planner works on a 0.2 m grid of the walkable areas (vestibule,
## hall, landing, corridor). A cell counts as free only when the real player
## capsule (radius and height read from player.tscn) fits there without
## touching anything, and a floor lies beneath it. Every route is then walked
## with the real PlayerController (move_forward, move_and_slide). There is no
## teleporting between doors, and the tour goes down the real stairs. At each
## door the player faces it, and the real InteractionRay must target it and
## show a prompt.
## Run only through tools/Run-Tests.ps1.

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const STEP: float = 0.2
## Where the player stands in front of a door, metres from the door plane.
const APPROACH: float = 0.75
const ARRIVE: float = 0.3
const LOOKAHEAD: float = 0.55
## A route fails if the body gains less than this over STALL_FRAMES.
const STALL_DISTANCE: float = 0.05
const STALL_FRAMES: int = 45
const STAIR_FOOT := Vector3(7.5, 0.0, 9.7)
const STAIR_TOP := Vector3(7.5, HouseLayout.STOREY_HEIGHT, 2.9)

var checks: int = 0
var failures: int = 0
var _player: PlayerController
var _ray: InteractionRay
var _radius: float
var _height: float
var _free: Array[Dictionary] = [{}, {}]
var _report: Array[String] = []


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	GameState.new_campaign(11)
	var scene: Node = SCENE.instantiate()
	add_child(scene)
	_player = scene.get_node("Player")
	_ray = _player.get_node("Head/Camera3D/InteractionRay")
	var capsule: CapsuleShape3D = (_player.get_node("CollisionShape3D") as CollisionShape3D).shape
	_radius = capsule.radius
	_height = capsule.height
	await _frames(10)
	check(_player.control_enabled, "player has control at the start")

	for floor_index: int in 2:
		_free[floor_index] = _build_grid(floor_index)
		check(_free[floor_index].size() > 100, "floor %d has walkable space (%d cells)" % [floor_index, _free[floor_index].size()])
	# Control: the planner must reject the body overlapping a wall, the
	# space under the stairs and the stairwell void upstairs.
	check(not _free[0].has(Vector2i(int(4.1 / STEP), int(7.5 / STEP))), "grid rejects the capsule against the hall wall")
	check(not _free[0].has(Vector2i(int(7.5 / STEP), int(6.0 / STEP))), "grid rejects the space under the stairs")
	check(not _free[1].has(Vector2i(int(7.5 / STEP), int(6.0 / STEP))), "grid rejects the stairwell void upstairs")

	var doors: Array[Array] = [[], []]
	for node: Node in scene.find_children("*", "RoomDoor", true, false):
		var door := node as RoomDoor
		if door.room_id == &"" and not door.is_front:
			continue
		var floor_index: int = 1 if door.global_position.y > HouseLayout.STOREY_HEIGHT * 0.5 else 0
		doors[floor_index].append(door)
	var expected: int = 0
	for wall: Dictionary in HouseLayout.WALLS:
		for opening: Dictionary in wall["openings"]:
			if opening.has("to") or opening.get("front", false):
				expected += 1
	check(doors[0].size() + doors[1].size() == expected, "every usable door in the plan exists in the house (%d)" % expected)

	# Upper floor first (the game starts on the gallery), then the stairs,
	# then the ground floor, nearest door first each time.
	var start_floor: int = 1 if _player.global_position.y > HouseLayout.STOREY_HEIGHT * 0.5 else 0
	var order: Array[int] = [start_floor, 1 - start_floor]
	for floor_index: int in order:
		if floor_index != _floor_of_player():
			var stairs_ok: bool = await _take_stairs(floor_index)
			check(stairs_ok, "real stairs carry the player to floor %d" % floor_index)
			if not stairs_ok:
				break
		var remaining: Array = doors[floor_index].duplicate()
		while not remaining.is_empty():
			remaining.sort_custom(func(a: RoomDoor, b: RoomDoor) -> bool:
				return _player.global_position.distance_to(a.global_position) < _player.global_position.distance_to(b.global_position))
			var door: RoomDoor = remaining.pop_front()
			await _visit(door, floor_index)

	for line: String in _report:
		print(line)
	if failures == 0:
		print("HOUSE ACCESS TEST: PASS (%d checks)" % checks)
	else:
		print("HOUSE ACCESS TEST: FAILED %d of %d checks" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)


func _visit(door: RoomDoor, floor_index: int) -> void:
	var label: String = "front door" if door.is_front else String(door.room_id)
	var approach: Vector3 = _approach_point(door)
	var goal: Vector2i = _nearest_free(floor_index, approach)
	if goal == Vector2i(-1, -1) or _cell_center(goal, floor_index).distance_to(approach) > 0.35:
		check(false, "%s: standing space in front of the door (%.2f, %.2f)" % [label, approach.x, approach.z])
		_report.append("%s: NO STANDING SPACE at (%.2f, %.2f)" % [label, approach.x, approach.z])
		return
	var walked: Dictionary = await _walk_to(_cell_center(goal, floor_index), floor_index)
	check(walked.ok, "%s: reachable on foot (%s)" % [label, walked.why])
	_report.append("%s: %s, %.1f m walked, %d frames, end (%.2f, %.2f, %.2f)" % [label, "ok" if walked.ok else walked.why, walked.distance, walked.frames, _player.global_position.x, _player.global_position.y, _player.global_position.z])
	if not walked.ok:
		return
	# Face the door at eye level, as a player does.
	var to_door: Vector3 = door.global_position - _player.global_position
	_player.rotation.y = atan2(-to_door.x, -to_door.z)
	_player.get_node("Head").rotation.x = 0.0
	await _frames(3)
	var target: Object = _ray.get_target()
	var hits: bool = target == door or (target is Node and door.is_ancestor_of(target))
	check(hits, "%s: interaction ray reaches the door from the corridor" % label)
	check(hits and door.get_interaction_prompt() != "", "%s: door shows a prompt" % label)


## Walks the real stairs between floors along the centre lane.
func _take_stairs(to_floor: int) -> bool:
	var from_floor: int = 1 - to_floor
	var entry: Vector3 = STAIR_TOP if from_floor == 1 else STAIR_FOOT
	var walked: Dictionary = await _walk_to(_cell_center(_nearest_free(from_floor, entry), from_floor), from_floor)
	_report.append("to stairs on floor %d: %s, %.1f m" % [from_floor, "ok" if walked.ok else walked.why, walked.distance])
	if not walked.ok:
		return false
	var exit: Vector3 = STAIR_FOOT if to_floor == 0 else STAIR_TOP
	var yaw: float = PI if to_floor == 0 else 0.0
	_player.rotation.y = yaw
	Input.action_press(&"move_forward")
	var arrived: bool = false
	for _i: int in 400:
		await get_tree().physics_frame
		var p: Vector3 = _player.global_position
		if absf(p.y - exit.y) < 0.12 and (p.z > exit.z - 0.1 if to_floor == 0 else p.z < exit.z + 0.1):
			arrived = true
			break
	Input.action_release(&"move_forward")
	await _frames(10)
	_report.append("stairs to floor %d: %s, end (%.2f, %.2f, %.2f)" % [to_floor, "ok" if arrived else "STUCK", _player.global_position.x, _player.global_position.y, _player.global_position.z])
	return arrived


## Plans a grid route from the player to [param goal] and walks it for real.
func _walk_to(goal: Vector3, floor_index: int) -> Dictionary:
	var start: Vector2i = _nearest_free(floor_index, _player.global_position)
	var target: Vector2i = _nearest_free(floor_index, goal)
	var path: Array[Vector3] = _find_path(floor_index, start, target)
	if path.is_empty():
		return {"ok": false, "why": "no route on the grid", "distance": 0.0, "frames": 0}
	path.append(goal)
	var walked: float = 0.0
	var frames: int = 0
	var index: int = 0
	var last: Vector3 = _player.global_position
	var stall_mark: Vector3 = last
	Input.action_press(&"move_forward")
	var result: Dictionary = {"ok": false, "why": "timed out", "distance": 0.0, "frames": 0}
	while frames < 1500:
		var here: Vector3 = _player.global_position
		var flat_here := Vector2(here.x, here.z)
		# Pure pursuit: aim at the first path point beyond the lookahead.
		while index < path.size() - 1 and flat_here.distance_to(Vector2(path[index].x, path[index].z)) < LOOKAHEAD:
			index += 1
		var aim: Vector3 = path[index]
		if flat_here.distance_to(Vector2(goal.x, goal.z)) < ARRIVE:
			result = {"ok": true, "why": "arrived"}
			break
		var direction := Vector2(aim.x - here.x, aim.z - here.z)
		_player.rotation.y = atan2(-direction.x, -direction.y)
		await get_tree().physics_frame
		frames += 1
		walked += _player.global_position.distance_to(last)
		last = _player.global_position
		if frames % STALL_FRAMES == 0:
			if _player.global_position.distance_to(stall_mark) < STALL_DISTANCE:
				result = {"ok": false, "why": "stuck at (%.2f, %.2f, %.2f)" % [last.x, last.y, last.z]}
				break
			stall_mark = _player.global_position
		if absf(_player.global_position.y - HouseLayout.floor_height(floor_index)) > 0.3:
			result = {"ok": false, "why": "left the floor at (%.2f, %.2f, %.2f)" % [last.x, last.y, last.z]}
			break
	Input.action_release(&"move_forward")
	await _frames(8)
	result["distance"] = walked
	result["frames"] = frames
	return result


func _approach_point(door: RoomDoor) -> Vector3:
	var normal: Vector3 = door.global_transform.basis.z.normalized()
	for side: float in [1.0, -1.0]:
		var point: Vector3 = door.global_position + normal * APPROACH * side
		var room: StringName = HouseLayout.room_at(point + Vector3(0.0, 0.1, 0.0))
		if room in HouseLayout.WALKABLE_ROOMS:
			return point
	return door.global_position + normal * APPROACH


## Free cells of one floor: inside a walkable room, the real capsule fits,
## and there is floor underneath.
func _build_grid(floor_index: int) -> Dictionary:
	var space: PhysicsDirectSpaceState3D = _player.get_world_3d().direct_space_state
	var shape := CapsuleShape3D.new()
	shape.radius = _radius
	shape.height = _height
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = shape
	query.exclude = [_player.get_rid()]
	query.collision_mask = _player.collision_mask
	var ray := PhysicsRayQueryParameters3D.new()
	ray.exclude = [_player.get_rid()]
	ray.collision_mask = _player.collision_mask
	var base: float = HouseLayout.floor_height(floor_index)
	var cells: Dictionary = {}
	for i: int in int(HouseLayout.WIDTH / STEP):
		for j: int in int(HouseLayout.DEPTH / STEP):
			var cell := Vector2i(i, j)
			var center: Vector3 = _cell_center(cell, floor_index)
			if not HouseLayout.room_at(center + Vector3(0.0, 0.1, 0.0)) in HouseLayout.WALKABLE_ROOMS:
				continue
			query.transform = Transform3D(Basis.IDENTITY, center + Vector3(0.0, _height * 0.5 + 0.06, 0.0))
			if not space.intersect_shape(query, 1).is_empty():
				continue
			ray.from = center + Vector3(0.0, 0.5, 0.0)
			ray.to = center + Vector3(0.0, -0.25, 0.0)
			var hit: Dictionary = space.intersect_ray(ray)
			if hit.is_empty() or absf(hit.position.y - base) > 0.12:
				continue
			cells[cell] = true
	return cells


func _cell_center(cell: Vector2i, floor_index: int) -> Vector3:
	return Vector3((cell.x + 0.5) * STEP, HouseLayout.floor_height(floor_index), (cell.y + 0.5) * STEP)


func _nearest_free(floor_index: int, point: Vector3) -> Vector2i:
	var best := Vector2i(-1, -1)
	var best_distance: float = INF
	for cell: Vector2i in _free[floor_index]:
		var d: float = Vector2(_cell_center(cell, floor_index).x - point.x, _cell_center(cell, floor_index).z - point.z).length()
		if d < best_distance:
			best_distance = d
			best = cell
	return best


func _find_path(floor_index: int, from: Vector2i, to: Vector2i) -> Array[Vector3]:
	var cells: Dictionary = _free[floor_index]
	var path: Array[Vector3] = []
	if not cells.has(from) or not cells.has(to):
		return path
	var came: Dictionary = {from: from}
	var queue: Array[Vector2i] = [from]
	var head: int = 0
	var steps: Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)]
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		if cell == to:
			break
		for step: Vector2i in steps:
			var next: Vector2i = cell + step
			# Diagonals only where both side cells are free (no corner cutting).
			if step.x != 0 and step.y != 0 and not (cells.has(cell + Vector2i(step.x, 0)) and cells.has(cell + Vector2i(0, step.y))):
				continue
			if cells.has(next) and not came.has(next):
				came[next] = cell
				queue.append(next)
	if not came.has(to):
		return path
	var cell: Vector2i = to
	while cell != from:
		path.push_front(_cell_center(cell, floor_index))
		cell = came[cell]
	return path


func _floor_of_player() -> int:
	return 1 if _player.global_position.y > HouseLayout.STOREY_HEIGHT * 0.5 else 0


func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().physics_frame
