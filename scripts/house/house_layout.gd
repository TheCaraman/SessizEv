class_name HouseLayout
extends RefCounted
## Authoritative data for the house floor plan (docs/HousePlan.md).
##
## Plan coordinates map directly to world space: plan x = world X (west to
## east, 0..15), plan z = world Z (north/back to south/front, 0..12.5).
## Floor 0 is the ground floor, floor 1 the upper floor.
##
## This file is data only. HouseBuilder turns it into geometry; gameplay code
## uses room_at() to ask which room a position is in.

const WIDTH: float = 15.0
const DEPTH: float = 12.5
## Vertical distance between the two walkable floors.
const STOREY_HEIGHT: float = 3.3
## Thickness of floor slabs; ceilings are therefore 3.1 m high.
const SLAB_THICKNESS: float = 0.2
const DOOR_WIDTH: float = 0.9
const DOOR_HEIGHT: float = 2.3
const WINDOW_SILL: float = 0.9
const EXTERIOR_WALL_THICKNESS: float = 0.2
const INTERIOR_WALL_THICKNESS: float = 0.1

## Footprint of the staircase. The bottom is at the south edge (max z) on
## floor 0, the top at the north edge (min z) on floor 1.
const STAIRS: Rect2 = Rect2(8.75, 3.75, 1.5, 5.625)

## Double-height entry gives the corridor a view of daylight and the lower hall.
## Bedroom access and the full 3.75m upper passage remain outside this opening.
const FOYER_VOID: Rect2 = Rect2(5.0, 10.625, 3.5, 1.875)
const VOIDS: Array[Rect2] = [STAIRS, FOYER_VOID]


## True if the plan point lies over an upper-floor opening.
static func is_in_void(point: Vector2) -> bool:
	for opening: Rect2 in VOIDS:
		if opening.has_point(point):
			return true
	return false

## Rooms. "rects" lists one or more plan rectangles (x, z, width, depth);
## the first rectangle is the room's main area.
const ROOMS: Array[Dictionary] = [
	{"id": &"dining", "name_key": "ROOM_DINING", "floor": 0, "rects": [Rect2(0.0, 0.0, 5.0, 5.625)]},
	{"id": &"living_room", "name_key": "ROOM_LIVING", "floor": 0, "rects": [Rect2(0.0, 5.625, 5.0, 6.875)]},
	{"id": &"kitchen", "name_key": "ROOM_KITCHEN", "floor": 0, "rects": [Rect2(5.0, 0.0, 6.875, 3.75)]},
	{"id": &"pantry", "name_key": "ROOM_PANTRY", "floor": 0, "rects": [Rect2(11.875, 0.0, 3.125, 3.75)]},
	{"id": &"hall", "name_key": "ROOM_HALL", "floor": 0, "rects": [Rect2(5.0, 3.75, 3.75, 6.875), Rect2(8.75, 9.375, 1.5, 1.25)]},
	{"id": &"vestibule", "name_key": "ROOM_VESTIBULE", "floor": 0, "rects": [Rect2(5.0, 10.625, 5.25, 1.875)]},
	{"id": &"utility", "name_key": "ROOM_UTILITY", "floor": 0, "rects": [Rect2(10.25, 3.75, 4.75, 5.625)]},
	{"id": &"bathroom_ground", "name_key": "ROOM_BATHROOM_GROUND", "floor": 0, "rects": [Rect2(10.25, 9.375, 4.75, 3.125)]},
	{"id": &"guest_b", "name_key": "ROOM_GUEST_B", "floor": 1, "rects": [Rect2(0.0, 0.0, 5.0, 3.75)]},
	{"id": &"guest_a", "name_key": "ROOM_GUEST_A", "floor": 1, "rects": [Rect2(0.0, 3.75, 5.0, 3.75)]},
	{"id": &"daniel_bedroom", "name_key": "ROOM_DANIEL", "floor": 1, "rects": [Rect2(0.0, 7.5, 5.0, 5.0)]},
	{"id": &"isolation", "name_key": "ROOM_ISOLATION", "floor": 1, "rects": [Rect2(5.0, 0.0, 5.25, 2.25)]},
	{"id": &"landing", "name_key": "ROOM_LANDING", "floor": 1, "rects": [Rect2(5.0, 2.25, 5.25, 1.5)]},
	{"id": &"corridor", "name_key": "ROOM_CORRIDOR", "floor": 1, "rects": [Rect2(5.0, 3.75, 3.75, 6.875), Rect2(8.75, 9.375, 1.5, 1.25)]},
	{"id": &"multipurpose", "name_key": "ROOM_MULTIPURPOSE", "floor": 1, "rects": [Rect2(10.25, 0.0, 4.75, 8.125)]},
	{"id": &"bathroom_upper", "name_key": "ROOM_BATHROOM_UPPER", "floor": 1, "rects": [Rect2(10.25, 8.125, 4.75, 4.375)]},
	{"id": &"storage", "name_key": "ROOM_STORAGE", "floor": 1, "rects": [Rect2(8.5, 10.625, 1.75, 1.875)]},
]

## Rooms the player walks through in 3D. Every other room is shown as a 2D
## scene when its door is used (docs/DecisionLog.md, K-011).
const WALKABLE_ROOMS: Array[StringName] = [&"vestibule", &"hall", &"landing", &"corridor"]

## Passages between 2D rooms that have no corridor door of their own.
const ROOM_LINKS: Dictionary = {
	&"living_room": [&"dining"],
	&"dining": [&"living_room", &"kitchen"],
	&"kitchen": [&"dining", &"pantry", &"utility"],
	&"pantry": [&"kitchen"],
	&"utility": [&"kitchen"],
}

## Walls. "axis" is the direction the wall runs: "x" walls sit at z = "at" and
## span x from "from" to "to"; "z" walls sit at x = "at" and span z.
## "openings" are door-height gaps: "pos" is the centre along the wall,
## "width" defaults to DOOR_WIDTH, and "sealed" fills the gap with a locked
## exterior door, and "to" names the 2D room a corridor door opens.
## "window" makes the opening a curtained window from WINDOW_SILL up to
## DOOR_HEIGHT; daylight comes in through it.
const WALLS: Array[Dictionary] = [
	# --- Ground floor, exterior ---
	{"floor": 0, "axis": "x", "at": 0.0, "from": -0.125, "to": 15.125, "exterior": true,
		"openings": [{"pos": 9.0625, "sealed": true, "id": &"rear_door"}]},
	{"floor": 0, "axis": "x", "at": 12.5, "from": -0.125, "to": 15.125, "exterior": true,
		"openings": [{"pos": 7.5, "sealed": true, "id": &"main_door", "front": true}, {"pos": 9.3125, "width": 1.125, "window": true}, {"pos": 5.9375, "width": 1.25, "window": true}]},
	{"floor": 0, "axis": "z", "at": 0.0, "from": 0.0, "to": 12.5, "exterior": true, "openings": []},
	{"floor": 0, "axis": "z", "at": 15.0, "from": 0.0, "to": 12.5, "exterior": true, "openings": []},
	# --- Ground floor, interior ---
	# Dining / living room: wide open archway.
	{"floor": 0, "axis": "x", "at": 5.625, "from": 0.0, "to": 5.0, "openings": [{"pos": 2.5, "width": 3.25}]},
	# West side of hall and vestibule; the kitchen (z < 3) stays open to dining.
	{"floor": 0, "axis": "z", "at": 5.0, "from": 3.75, "to": 12.5, "openings": [{"pos": 7.5, "to": &"living_room"}]},
	# South wall of kitchen and pantry: doors to the hall and the utility room.
	{"floor": 0, "axis": "x", "at": 3.75, "from": 5.0, "to": 15.0, "openings": [{"pos": 7.5, "to": &"kitchen"}, {"pos": 11.125}]},
	# Kitchen / pantry.
	{"floor": 0, "axis": "z", "at": 11.875, "from": 0.0, "to": 3.75, "openings": [{"pos": 1.875}]},
	# Hall / staircase.
	{"floor": 0, "axis": "z", "at": 8.75, "from": 3.75, "to": 9.375, "guard": true, "openings": []},
	# Staircase / utility, then the bathroom door off the stair-foot nook.
	{"floor": 0, "axis": "z", "at": 10.25, "from": 3.75, "to": 12.5, "openings": [{"pos": 10.0, "to": &"bathroom_ground"}]},
	# Utility / bathroom.
	{"floor": 0, "axis": "x", "at": 9.375, "from": 10.25, "to": 15.0, "openings": []},
	# Hall and entry are one open volume; no low lintel cuts off the tall foyer.
	{"floor": 0, "axis": "x", "at": 10.625, "from": 8.875, "to": 10.25, "openings": []},
	# --- Upper floor, exterior ---
	{"floor": 1, "axis": "x", "at": 0.0, "from": -0.125, "to": 15.125, "exterior": true, "openings": []},
	{"floor": 1, "axis": "x", "at": 12.5, "from": -0.125, "to": 15.125, "exterior": true, "openings": [{"pos": 6.625, "width": 1.875, "window": true}]},
	{"floor": 1, "axis": "z", "at": 0.0, "from": 0.0, "to": 12.5, "exterior": true, "openings": []},
	{"floor": 1, "axis": "z", "at": 15.0, "from": 0.0, "to": 12.5, "exterior": true, "openings": []},
	# --- Upper floor, interior ---
	# West bedrooms: Guest B, Guest A, Daniel.
	{"floor": 1, "axis": "z", "at": 5.0, "from": 0.0, "to": 12.5,
		"openings": [{"pos": 3.0, "to": &"guest_b"}, {"pos": 5.625, "to": &"guest_a"}, {"pos": 8.75, "to": &"daniel_bedroom"}]},
	{"floor": 1, "axis": "x", "at": 3.75, "from": 0.0, "to": 5.0, "openings": []},
	{"floor": 1, "axis": "x", "at": 7.5, "from": 0.0, "to": 5.0, "openings": []},
	# Isolation room south wall.
	{"floor": 1, "axis": "x", "at": 2.25, "from": 5.0, "to": 10.25, "openings": [{"pos": 7.5, "to": &"isolation"}]},
	# East rooms: multipurpose door off the landing, bathroom door off the corridor.
	{"floor": 1, "axis": "z", "at": 10.25, "from": 0.0, "to": 12.5, "openings": [{"pos": 3.0, "to": &"multipurpose"}, {"pos": 10.0, "to": &"bathroom_upper"}]},
	{"floor": 1, "axis": "x", "at": 8.125, "from": 10.25, "to": 15.0, "openings": []},
	# Stairwell enclosure (open at the north end, where the stairs arrive).
	# Parapet along the open stairwell and its south end.
	{"floor": 1, "axis": "z", "at": 8.75, "from": 3.75, "to": 9.375, "guard": true, "openings": []},
	{"floor": 1, "axis": "x", "at": 9.375, "from": 8.75, "to": 10.25, "guard": true, "openings": []},
	# Open gallery edge at the double-height entry. All doors stay on solid floor.
	{"floor": 1, "axis": "x", "at": 10.625, "from": 5.0, "to": 8.5, "guard": true, "openings": []},
	# Storage closet north wall.
	{"floor": 1, "axis": "x", "at": 10.625, "from": 8.5, "to": 10.25, "openings": [{"pos": 9.375, "to": &"storage"}]},
	{"floor": 1, "axis": "z", "at": 8.5, "from": 10.625, "to": 12.5, "openings": []},
]


## Height of the walkable surface of [param floor_index].
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
