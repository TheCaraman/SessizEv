class_name NpcRoutes
extends RefCounted
## NPC-ACTOR-3D-001: floor routes between the rooms of the house, built only
## from HouseLayout (no scene, no physics). A route goes from a room's centre
## through each doorway it uses and across the hall rooms to the target room's
## centre, as a list of floor points an NPC can walk.
##
## Two rooms are joined when
##   - a wall opening has one room on each side (a doorway), or
##   - two walkable rooms (vestibule, hall, landing, corridor) share an edge.
## The joint is the doorway point, or the middle of the shared edge. Every
## doorway contributes three points (a step inside, the doorway, a step
## outside) so a walker passes straight through the opening, never cutting
## the wall's corner.

## How far from the wall plane the points beside a doorway lie.
const DOOR_APPROACH: float = 0.7
## Resolution for deciding which room lies on a side of an opening.
const SIDE_PROBE: float = 0.4
const _MIN_OVERLAP: float = 0.3

static var _edges_cache: Dictionary = {}


## Floor points (y = floor height) from the centre of [param from_room] to the
## centre of [param to_room], or an empty array when unknown or unreachable.
static func route(from_room: StringName, to_room: StringName) -> Array[Vector3]:
	from_room = HouseLayout.canonical_room_id(from_room)
	to_room = HouseLayout.canonical_room_id(to_room)
	var result: Array[Vector3] = []
	if HouseLayout.get_room(from_room).is_empty() or HouseLayout.get_room(to_room).is_empty():
		return result
	result.append(_centre(from_room))
	if from_room == to_room:
		return result
	var steps: Array[Dictionary] = _search(from_room, to_room)
	if steps.is_empty():
		result.clear()
		return result
	for step: Dictionary in steps:
		for point: Vector3 in step["points"]:
			result.append(point)
	result.append(_centre(to_room))
	return result


## Total walking distance of a route, metres.
static func length(points: Array[Vector3]) -> float:
	var total: float = 0.0
	for index: int in range(points.size() - 1):
		total += points[index].distance_to(points[index + 1])
	return total


## Every room joined to [param room], with the joint's points ordered from
## [param room] outward: [{"to": StringName, "points": Array[Vector3]}].
static func neighbours(room: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for edge: Dictionary in _edges():
		if edge["a"] == room:
			result.append({"to": edge["b"], "points": edge["points"]})
		elif edge["b"] == room:
			var back: Array[Vector3] = []
			var points: Array[Vector3] = edge["points"]
			for index: int in range(points.size() - 1, -1, -1):
				back.append(points[index])
			result.append({"to": edge["a"], "points": back})
	return result


static func _search(from_room: StringName, to_room: StringName) -> Array[Dictionary]:
	var parent: Dictionary = {from_room: null}
	var queue: Array[StringName] = [from_room]
	while not queue.is_empty():
		var current: StringName = queue.pop_front()
		if current == to_room:
			break
		for step: Dictionary in neighbours(current):
			var next: StringName = step["to"]
			if not parent.has(next):
				parent[next] = {"from": current, "points": step["points"]}
				queue.append(next)
	var path: Array[Dictionary] = []
	if not parent.has(to_room):
		return path
	var cursor: StringName = to_room
	while parent[cursor] != null:
		path.push_front({"to": cursor, "points": parent[cursor]["points"]})
		cursor = parent[cursor]["from"]
	return path


static func _edges() -> Array[Dictionary]:
	if _edges_cache.has("edges"):
		return _edges_cache["edges"]
	var edges: Array[Dictionary] = []
	# Doorways: an opening with a different room on each side.
	for wall: Dictionary in HouseLayout.WALLS:
		var axis: String = wall["axis"]
		var at: float = float(wall["at"])
		for opening: Dictionary in wall["openings"]:
			if opening.get("window", false) or opening.get("sealed", false):
				continue
			var pos: float = float(opening["pos"])
			var door: Vector2 = Vector2(at, pos) if axis == "z" else Vector2(pos, at)
			var normal: Vector2 = Vector2(1.0, 0.0) if axis == "z" else Vector2(0.0, 1.0)
			# "normal" is the normal of the wall plane: x for a wall at a fixed x.
			var side_a: Vector2 = door - normal * SIDE_PROBE
			var side_b: Vector2 = door + normal * SIDE_PROBE
			var room_a: StringName = _room_at(side_a)
			var room_b: StringName = _room_at(side_b)
			if room_a == &"" or room_b == &"" or room_a == room_b:
				continue
			var points: Array[Vector3] = [_flat(door - normal * DOOR_APPROACH), _flat(door), _flat(door + normal * DOOR_APPROACH)]
			edges.append({"a": room_a, "b": room_b, "points": points})
	# Walkable rooms that touch each other along an edge.
	var walkable: Array[StringName] = HouseLayout.WALKABLE_ROOMS
	for first: int in walkable.size():
		for second: int in range(first + 1, walkable.size()):
			var joint: Variant = _shared_edge(walkable[first], walkable[second])
			if joint != null:
				var middle: Vector2 = joint
				var points: Array[Vector3] = [_flat(middle)]
				edges.append({"a": walkable[first], "b": walkable[second], "points": points})
	_edges_cache["edges"] = edges
	return edges


## The middle of the edge two rooms share (at least _MIN_OVERLAP long), or
## null when they do not touch.
static func _shared_edge(first: StringName, second: StringName) -> Variant:
	var rect_a: Rect2 = HouseLayout.get_room(first)["rects"][0]
	var rect_b: Rect2 = HouseLayout.get_room(second)["rects"][0]
	var best: Variant = null
	var best_length: float = _MIN_OVERLAP
	# Vertical shared edge (rooms side by side along x).
	for gap: float in [rect_a.end.x - rect_b.position.x, rect_b.end.x - rect_a.position.x]:
		if absf(gap) < 0.001:
			var low: float = maxf(rect_a.position.y, rect_b.position.y)
			var high: float = minf(rect_a.end.y, rect_b.end.y)
			if high - low > best_length:
				var x: float = rect_a.end.x if absf(rect_a.end.x - rect_b.position.x) < 0.001 else rect_a.position.x
				best = Vector2(x, (low + high) * 0.5)
				best_length = high - low
	# Horizontal shared edge (rooms one above the other along z).
	for gap: float in [rect_a.end.y - rect_b.position.y, rect_b.end.y - rect_a.position.y]:
		if absf(gap) < 0.001:
			var low: float = maxf(rect_a.position.x, rect_b.position.x)
			var high: float = minf(rect_a.end.x, rect_b.end.x)
			if high - low > best_length:
				var z: float = rect_a.end.y if absf(rect_a.end.y - rect_b.position.y) < 0.001 else rect_a.position.y
				best = Vector2((low + high) * 0.5, z)
				best_length = high - low
	return best


static func _room_at(point: Vector2) -> StringName:
	return HouseLayout.room_at(Vector3(point.x, 0.1, point.y))


static func _flat(point: Vector2) -> Vector3:
	return Vector3(point.x, 0.0, point.y)


static func _centre(room: StringName) -> Vector3:
	return HouseLayout.room_center(room)
