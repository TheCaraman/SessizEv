class_name NightRouteAccess
extends RefCounted
## Scene-local proof of a real off-screen route and supported observation points.
var session: Node3D
func _init(owner: Node3D) -> void:
	session = owner

func measure(subject_room: String, observer_room: String) -> Dictionary:
	var doors: Dictionary = {}
	var excluded: Array[RID] = []
	for node: Node in session.find_children("*", "StaticBody3D", true, false):
		if node is RoomDoor:
			doors[str(node.room_id)] = node
			excluded.append(node.get_rid())
	var player: CollisionObject3D = session.get_node("Player")
	excluded.append(player.get_rid())
	subject_room = RoomAliases.canonical(subject_room)
	observer_room = RoomAliases.canonical(observer_room)
	for room: String in [subject_room, observer_room, "bathroom_upper"]:
		if not doors.has(room) or doors[room].locked:
			return {}
	var subject_path: Array[Vector3] = _path(doors[subject_room], doors["bathroom_upper"], excluded)
	var observer_path: Array[Vector3] = _path(doors[observer_room], doors["bathroom_upper"], excluded)
	if subject_path.is_empty() or observer_path.is_empty():
		return {}
	var eye: Vector3 = HouseLayout.room_center(&"corridor") + Vector3.UP * 1.35
	var toward: Vector3 = HouseLayout.room_center(&"landing") + Vector3.UP * 1.35
	var seen: Vector3 = eye.move_toward(toward, 1.0)
	if eye.distance_to(seen) < 0.3 or not _clear([eye, seen], excluded):
		return {}
	if not _supported(eye, excluded) or not _supported(seen, excluded):
		return {}
	return {"route_access": true, "sightline": true,
		"observer_position_mm": [roundi(eye.x * 1000), roundi(eye.y * 1000), roundi(eye.z * 1000)],
		"subject_position_mm": [roundi(seen.x * 1000), roundi(seen.y * 1000), roundi(seen.z * 1000)]}

func _corridor_side(door: RoomDoor) -> Vector3:
	for side: float in [1.0, -1.0]:
		var floor_point: Vector3 = door.to_global(Vector3(0.0, 0.05, side * 0.75))
		if HouseLayout.WALKABLE_ROOMS.has(HouseLayout.room_at(floor_point)):
			return floor_point + Vector3.UP * 1.3
	return Vector3(INF, INF, INF)

func _path(origin: RoomDoor, bathroom: RoomDoor, excluded: Array[RID]) -> Array[Vector3]:
	var start: Vector3 = _corridor_side(origin)
	var destination: Vector3 = _corridor_side(bathroom)
	if not start.is_finite() or not destination.is_finite():
		return []
	var nodes: Array[Vector3] = [start, destination]
	for room_id: StringName in HouseLayout.WALKABLE_ROOMS:
		var waypoint: Vector3 = HouseLayout.room_center(room_id) + Vector3.UP * 1.35
		if _supported(waypoint, excluded):
			nodes.append(waypoint)
	var parents: Dictionary = {0: -1}
	var queue: Array[int] = [0]
	while not queue.is_empty():
		var current: int = queue.pop_front()
		if current == 1:
			var result: Array[Vector3] = []
			var cursor: int = 1
			while cursor >= 0:
				result.push_front(nodes[cursor])
				cursor = parents[cursor]
			return result
		for next: int in nodes.size():
			if parents.has(next) or absf(nodes[current].y - nodes[next].y) > 0.2:
				continue
			if _clear([nodes[current], nodes[next]], excluded):
				parents[next] = current
				queue.append(next)
	return []

func _supported(eye: Vector3, excluded: Array[RID]) -> bool:
	var query := PhysicsRayQueryParameters3D.create(eye, eye - Vector3.UP * 1.6, 1, excluded)
	query.hit_from_inside = true
	var hit: Dictionary = session.get_world_3d().direct_space_state.intersect_ray(query)
	return not hit.is_empty() and absf(float(hit["position"].y) - (eye.y - 1.35)) < 0.1

func _clear(points: Array[Vector3], excluded: Array[RID]) -> bool:
	var space: PhysicsDirectSpaceState3D = session.get_world_3d().direct_space_state
	for index: int in points.size() - 1:
		if points[index].is_equal_approx(points[index + 1]):
			continue
		var query := PhysicsRayQueryParameters3D.create(points[index], points[index + 1], 1, excluded)
		query.hit_from_inside = true
		if not space.intersect_ray(query).is_empty():
			return false
	return true
