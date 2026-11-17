class_name HouseLayout
extends RefCounted
## Compact single-storey shelter. All playable circulation is on floor zero.
const WIDTH: float = 15.0
const DEPTH: float = 12.5
const FLOOR_COUNT: int = 1
const STOREY_HEIGHT: float = 3.3
const SLAB_THICKNESS: float = 0.2
const DOOR_WIDTH: float = 1.05
const DOOR_HEIGHT: float = 2.3
const WINDOW_SILL: float = 0.9
const EXTERIOR_WALL_THICKNESS: float = 0.2
const INTERIOR_WALL_THICKNESS: float = 0.1
## Empty compatibility constants: there is no stair, gallery or floor opening.
const STAIRS: Rect2 = Rect2()
const FOYER_VOID: Rect2 = Rect2()
const VOIDS: Array[Rect2] = []
const ROOM_ALIASES: Dictionary = RoomAliases.ALIASES
static func canonical_room_id(id: StringName) -> StringName:
	return StringName(RoomAliases.canonical(id))
static func is_in_void(_point: Vector2) -> bool:
	return false
const ROOMS: Array[Dictionary] = [
	{"id": &"living_room", "name_key": "ROOM_LIVING", "floor": 0, "rects": [Rect2(0, 8, 5, 4.5)]},
	{"id": &"kitchen", "name_key": "ROOM_KITCHEN", "floor": 0, "rects": [Rect2(0, 3, 5, 5)]},
	{"id": &"utility", "name_key": "ROOM_UTILITY", "floor": 0, "rects": [Rect2(0, 0, 5, 3)]},
	{"id": &"isolation", "name_key": "ROOM_ISOLATION", "floor": 0, "rects": [Rect2(5, 0, 4, 3)]},
	{"id": &"guest_a", "name_key": "ROOM_GUEST_A", "floor": 0, "rects": [Rect2(9, 0, 3, 3)]},
	{"id": &"guest_b", "name_key": "ROOM_GUEST_B", "floor": 0, "rects": [Rect2(12, 0, 3, 3)]},
	{"id": &"multipurpose", "name_key": "ROOM_MULTIPURPOSE", "floor": 0, "rects": [Rect2(9, 5.5, 3, 3.5)]},
	{"id": &"bathroom_upper", "name_key": "ROOM_BATHROOM_UPPER", "floor": 0, "rects": [Rect2(12, 5.5, 3, 2.5)]},
	{"id": &"storage", "name_key": "ROOM_STORAGE", "floor": 0, "rects": [Rect2(12, 8, 3, 1)]},
	{"id": &"daniel_bedroom", "name_key": "ROOM_DANIEL", "floor": 0, "rects": [Rect2(9, 9, 6, 3.5)]},
	{"id": &"vestibule", "name_key": "ROOM_VESTIBULE", "floor": 0, "rects": [Rect2(5, 10, 4, 2.5)]},
	{"id": &"hall", "name_key": "ROOM_HALL", "floor": 0, "rects": [Rect2(5, 5.5, 4, 4.5)]},
	{"id": &"landing", "name_key": "ROOM_HALL", "floor": 0, "rects": [Rect2(5, 3, 4, 2.5)]},
	{"id": &"corridor", "name_key": "ROOM_CORRIDOR", "floor": 0, "rects": [Rect2(9, 3, 6, 2.5)]},
]
const WALKABLE_ROOMS: Array[StringName] = [&"vestibule", &"hall", &"landing", &"corridor"]
const ROOM_LINKS: Dictionary = {
	&"living_room": [&"kitchen"], &"kitchen": [&"living_room", &"utility"],
	&"utility": [&"kitchen"], &"bathroom_upper": [&"storage"], &"storage": [&"bathroom_upper"]
}
const WALLS: Array[Dictionary] = [
	{"floor": 0, "axis": "x", "at": 0, "from": -0.125, "to": 15.125, "openings": [{"pos": 2.5, "sealed": true, "id": &"rear_door"}], "exterior": true},
	{"floor": 0, "axis": "x", "at": 12.5, "from": -0.125, "to": 15.125, "openings": [{"pos": 6.0, "width": 1.0, "window": true}, {"pos": 7.5, "sealed": true, "id": &"main_door", "front": true}], "exterior": true},
	{"floor": 0, "axis": "z", "at": 0, "from": 0, "to": 12.5, "openings": [], "exterior": true},
	{"floor": 0, "axis": "z", "at": 15, "from": 0, "to": 12.5, "openings": [{"pos": 4.25, "width": 1.55, "window": true}], "exterior": true},
	{"floor": 0, "axis": "z", "at": 5, "from": 0, "to": 12.5, "openings": [{"pos": 6.5, "to": &"kitchen"}, {"pos": 10.2, "to": &"living_room"}]},
	{"floor": 0, "axis": "x", "at": 3, "from": 0, "to": 15, "openings": [{"pos": 2.5}, {"pos": 7, "to": &"isolation"}, {"pos": 10.5, "to": &"guest_a"}, {"pos": 13.5, "to": &"guest_b"}]},
	{"floor": 0, "axis": "x", "at": 8, "from": 0, "to": 5, "openings": []},
	{"floor": 0, "axis": "z", "at": 9, "from": 0, "to": 3, "openings": []},
	{"floor": 0, "axis": "z", "at": 12, "from": 0, "to": 3, "openings": []},
	{"floor": 0, "axis": "z", "at": 9, "from": 5.5, "to": 12.5, "openings": [{"pos": 10.75, "to": &"daniel_bedroom"}]},
	{"floor": 0, "axis": "x", "at": 5.5, "from": 9, "to": 15, "openings": [{"pos": 10.5, "to": &"multipurpose"}, {"pos": 13.5, "to": &"bathroom_upper"}]},
	{"floor": 0, "axis": "z", "at": 12, "from": 5.5, "to": 9, "openings": []},
	{"floor": 0, "axis": "x", "at": 9, "from": 9, "to": 15, "openings": []},
	{"floor": 0, "axis": "x", "at": 8, "from": 12, "to": 15, "openings": [{"pos": 13.5, "width": 1.05}]},
]
static func floor_height(floor_index: int) -> float:
	return floor_index * STOREY_HEIGHT
static func room_at(world_position: Vector3) -> StringName:
	if world_position.y >= STOREY_HEIGHT - 0.1 or world_position.y < -0.5:
		return &""
	var point := Vector2(world_position.x, world_position.z)
	for room: Dictionary in ROOMS:
		for rect: Rect2 in room["rects"]:
			if rect.has_point(point):
				return room["id"]
	return &""
static func get_room(id: StringName) -> Dictionary:
	var canonical: StringName = canonical_room_id(id)
	for room: Dictionary in ROOMS:
		if room["id"] == canonical:
			return room
	return {}
static func room_center(id: StringName) -> Vector3:
	var room: Dictionary = get_room(id)
	if room.is_empty():
		return Vector3.ZERO
	var rect: Rect2 = room["rects"][0]
	var center: Vector2 = rect.get_center()
	return Vector3(center.x, 0.0, center.y)
