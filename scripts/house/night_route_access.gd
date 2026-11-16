class_name NightRouteAccess
extends RefCounted
## Scene-local checks for an entirely off-screen round trip, never visible teleportation.
var session: Node3D

func _init(owner: Node3D) -> void:
	session = owner

func measure(subject_room: String, observer_room: String) -> Dictionary:
	var doors: Dictionary = {}
	var excluded: Array[RID] = []
	for node: Node in session.find_children("*", "StaticBody3D", true, false):
		if not node is RoomDoor:
			continue
		var door: RoomDoor = node
		doors[str(door.room_id)] = door
		excluded.append(door.get_rid())
	var player: CollisionObject3D = session.get_node("Player")
	excluded.append(player.get_rid())
	for room: String in [subject_room, observer_room, "bathroom_upper"]:
		if not doors.has(room) or doors[room].locked:
			return {}
	var subject_path: Array[Vector3] = _path(doors[subject_room], doors["bathroom_upper"])
	var observer_path: Array[Vector3] = _path(doors[observer_room], doors["bathroom_upper"])
	if not _clear(subject_path, excluded) or not _clear(observer_path, excluded):
		return {}
	var eye := Vector3(7.5, HouseLayout.STOREY_HEIGHT + 1.35, 6.0)
	var seen := Vector3(7.5, eye.y, 7.0)
	if not _clear([eye, seen], excluded):
		return {}
	# Millimetres avoid Vector3 float32 -> JSON decimal round-trip drift.
	return {"route_access": true, "sightline": true, "observer_position_mm": [roundi(eye.x * 1000), roundi(eye.y * 1000), roundi(eye.z * 1000)], "subject_position_mm": [roundi(seen.x * 1000), roundi(seen.y * 1000), roundi(seen.z * 1000)]}

func _path(origin: RoomDoor, bathroom: RoomDoor) -> Array[Vector3]:
	var height: float = HouseLayout.STOREY_HEIGHT + 1.35
	var start := Vector3(origin.global_position.x, height, origin.global_position.z)
	start.x += 0.65 if start.x < 7.5 else -0.65
	var destination := Vector3(bathroom.global_position.x - 0.65, height, bathroom.global_position.z)
	return [start, Vector3(7.5, height, start.z), Vector3(7.5, height, 6.0), Vector3(7.5, height, 10.0), destination]

func _clear(points: Array[Vector3], excluded: Array[RID]) -> bool:
	var space: PhysicsDirectSpaceState3D = session.get_world_3d().direct_space_state
	for index: int in points.size() - 1:
		if points[index].is_equal_approx(points[index + 1]):
			continue
		var query := PhysicsRayQueryParameters3D.create(points[index], points[index + 1], 1, excluded)
		if not space.intersect_ray(query).is_empty():
			return false
	return true
