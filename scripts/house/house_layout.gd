class_name HouseLayout
extends RefCounted
## Central staircase, two circulation wings and a full-width entrance hall.
const WIDTH: float = 15.0
const DEPTH: float = 12.5
const STOREY_HEIGHT: float = 3.3
const SLAB_THICKNESS: float = 0.2
const DOOR_WIDTH: float = 1.05
const DOOR_HEIGHT: float = 2.3
const WINDOW_SILL: float = 0.9
const EXTERIOR_WALL_THICKNESS: float = 0.2
const INTERIOR_WALL_THICKNESS: float = 0.1
const STAIRS: Rect2 = Rect2(6.35, 3.5, 2.3, 5.5)
## Legacy name retained; the new foyer has a solid upper gallery.
const FOYER_VOID: Rect2 = Rect2(4.0, 9.0, 7.0, 3.5)
const VOIDS: Array[Rect2] = [STAIRS]
static func is_in_void(point: Vector2) -> bool:
	for opening: Rect2 in VOIDS:
		if opening.has_point(point):
			return true
	return false
const ROOMS: Array[Dictionary] = [
	{"id": &"dining", "name_key": "ROOM_DINING", "floor": 0, "rects": [Rect2(0, 0, 4, 4)]},
	{"id": &"living_room", "name_key": "ROOM_LIVING", "floor": 0, "rects": [Rect2(0, 4, 4, 8.5)]},
	{"id": &"kitchen", "name_key": "ROOM_KITCHEN", "floor": 0, "rects": [Rect2(4, 0, 7, 2)]},
	{"id": &"pantry", "name_key": "ROOM_PANTRY", "floor": 0, "rects": [Rect2(11, 0, 4, 3.5)]},
	{"id": &"hall", "name_key": "ROOM_HALL", "floor": 0, "rects": [Rect2(4, 2, 7, 1.5), Rect2(4, 3.5, 2.35, 5.5), Rect2(8.65, 3.5, 2.35, 5.5)]},
	{"id": &"vestibule", "name_key": "ROOM_VESTIBULE", "floor": 0, "rects": [Rect2(4, 9, 7, 3.5)]},
	{"id": &"utility", "name_key": "ROOM_UTILITY", "floor": 0, "rects": [Rect2(11, 3.5, 4, 5.5)]},
	{"id": &"bathroom_ground", "name_key": "ROOM_BATHROOM_GROUND", "floor": 0, "rects": [Rect2(11, 9, 4, 3.5)]},
	{"id": &"guest_b", "name_key": "ROOM_GUEST_B", "floor": 1, "rects": [Rect2(0, 0, 4, 4)]},
	{"id": &"guest_a", "name_key": "ROOM_GUEST_A", "floor": 1, "rects": [Rect2(0, 4, 4, 4)]},
	{"id": &"daniel_bedroom", "name_key": "ROOM_DANIEL", "floor": 1, "rects": [Rect2(0, 8, 4, 4.5)]},
	{"id": &"isolation", "name_key": "ROOM_ISOLATION", "floor": 1, "rects": [Rect2(4, 0, 7, 2)]},
	{"id": &"landing", "name_key": "ROOM_LANDING", "floor": 1, "rects": [Rect2(4, 2, 7, 1.5)]},
	{"id": &"corridor", "name_key": "ROOM_CORRIDOR", "floor": 1, "rects": [Rect2(4, 3.5, 2.35, 5.5), Rect2(8.65, 3.5, 2.35, 5.5), Rect2(4, 9, 7, 3.5)]},
	{"id": &"multipurpose", "name_key": "ROOM_MULTIPURPOSE", "floor": 1, "rects": [Rect2(11, 0, 4, 7)]},
	{"id": &"bathroom_upper", "name_key": "ROOM_BATHROOM_UPPER", "floor": 1, "rects": [Rect2(11, 7, 4, 3.5)]},
	{"id": &"storage", "name_key": "ROOM_STORAGE", "floor": 1, "rects": [Rect2(11, 10.5, 4, 2)]},
]
const WALKABLE_ROOMS: Array[StringName] = [&"vestibule", &"hall", &"landing", &"corridor"]
const ROOM_LINKS: Dictionary = {
	&"living_room": [&"dining"], &"dining": [&"living_room", &"kitchen"],
	&"kitchen": [&"dining", &"pantry", &"utility"], &"pantry": [&"kitchen"], &"utility": [&"kitchen"]
}
const WALLS: Array[Dictionary] = [
	{"floor": 0, "axis": "x", "at": 0, "from": -0.125, "to": 15.125, "openings": [{"pos": 7.5, "sealed": true, "id": &"rear_door"}], "exterior": true},
	{"floor": 0, "axis": "x", "at": 12.5, "from": -0.125, "to": 15.125, "openings": [{"pos": 5.35, "width": 1.5, "window": true}, {"pos": 9.65, "width": 1.5, "window": true}, {"pos": 7.5, "sealed": true, "id": &"main_door", "front": true}], "exterior": true},
	{"floor": 0, "axis": "z", "at": 0, "from": 0, "to": 12.5, "openings": [], "exterior": true},
	{"floor": 0, "axis": "z", "at": 15, "from": 0, "to": 12.5, "openings": [], "exterior": true},
	{"floor": 0, "axis": "z", "at": 4, "from": 2, "to": 12.5, "openings": [{"pos": 7, "to": &"living_room"}, {"pos": 3, "to": &"dining"}]},
	{"floor": 0, "axis": "z", "at": 11, "from": 2, "to": 12.5, "openings": [{"pos": 2.75, "to": &"pantry"}, {"pos": 6, "to": &"utility"}, {"pos": 10.75, "to": &"bathroom_ground"}]},
	{"floor": 0, "axis": "x", "at": 2, "from": 4, "to": 11, "openings": [{"pos": 7.5, "to": &"kitchen"}]},
	{"floor": 0, "axis": "x", "at": 4, "from": 0, "to": 4, "openings": [{"pos": 2, "width": 2}]},
	{"floor": 0, "axis": "x", "at": 3.5, "from": 11, "to": 15, "openings": []},
	{"floor": 0, "axis": "x", "at": 9, "from": 11, "to": 15, "openings": []},
	{"floor": 1, "axis": "x", "at": 0, "from": -0.125, "to": 15.125, "openings": [], "exterior": true},
	{"floor": 1, "axis": "x", "at": 12.5, "from": -0.125, "to": 15.125, "openings": [{"pos": 5.35, "width": 1.5, "window": true}, {"pos": 9.65, "width": 1.5, "window": true}, {"pos": 7.5, "width": 1.5, "window": true}], "exterior": true},
	{"floor": 1, "axis": "z", "at": 0, "from": 0, "to": 12.5, "openings": [], "exterior": true},
	{"floor": 1, "axis": "z", "at": 15, "from": 0, "to": 12.5, "openings": [], "exterior": true},
	{"floor": 1, "axis": "z", "at": 4, "from": 0, "to": 12.5, "openings": [{"pos": 3, "to": &"guest_b"}, {"pos": 6, "to": &"guest_a"}, {"pos": 10, "to": &"daniel_bedroom"}]},
	{"floor": 1, "axis": "z", "at": 11, "from": 0, "to": 12.5, "openings": [{"pos": 3, "to": &"multipurpose"}, {"pos": 8.25, "to": &"bathroom_upper"}, {"pos": 11.5, "to": &"storage"}]},
	{"floor": 1, "axis": "x", "at": 2, "from": 4, "to": 11, "openings": [{"pos": 7.5, "to": &"isolation"}]},
	{"floor": 1, "axis": "x", "at": 4, "from": 0, "to": 4, "openings": []},
	{"floor": 1, "axis": "x", "at": 8, "from": 0, "to": 4, "openings": []},
	{"floor": 1, "axis": "x", "at": 7, "from": 11, "to": 15, "openings": []},
	{"floor": 1, "axis": "x", "at": 10.5, "from": 11, "to": 15, "openings": []},
	{"floor": 1, "axis": "z", "at": 6.35, "from": 3.5, "to": 9, "openings": [], "guard": true},
	{"floor": 1, "axis": "z", "at": 8.65, "from": 3.5, "to": 9, "openings": [], "guard": true},
	{"floor": 1, "axis": "x", "at": 9, "from": 6.35, "to": 8.65, "openings": [], "guard": true},
]


static func floor_height(floor_index: int) -> float:
	return floor_index * STOREY_HEIGHT


## Returns the id of the room containing [param world_position], &"stairs" on
## the staircase, or an empty StringName outside the house.
static func room_at(world_position: Vector3) -> StringName:
	var point := Vector2(world_position.x, world_position.z)
	var on_upper_floor: bool = world_position.y >= STOREY_HEIGHT - 0.1
	if STAIRS.has_point(point) and world_position.y > 0.05 and not on_upper_floor:
		return &"stairs"
	var floor_index: int = 1 if on_upper_floor else 0
	if floor_index == 1 and STAIRS.has_point(point):
		return &"stairs"
	for room: Dictionary in ROOMS:
		if room["floor"] != floor_index:
			continue
		for rect: Rect2 in room["rects"]:
			if rect.has_point(point):
				return room["id"]
	return &""


## Returns the room dictionary for [param id], or an empty dictionary.
static func get_room(id: StringName) -> Dictionary:
	for room: Dictionary in ROOMS:
		if room["id"] == id:
			return room
	return {}


## World-space centre of a room's main area, at floor level.
static func room_center(id: StringName) -> Vector3:
	var room: Dictionary = get_room(id)
	if room.is_empty():
		return Vector3.ZERO
	var rect: Rect2 = room["rects"][0]
	var center: Vector2 = rect.get_center()
	return Vector3(center.x, floor_height(room["floor"]), center.y)
