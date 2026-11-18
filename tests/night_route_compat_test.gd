extends Node
## NIGHT-ROUTE-COMPAT-001: night observation routes follow the single-storey
## plan, while night_witness_record saves made under the two-storey plan
## (routes through the stair landing) stay valid. Run only through Run-Tests.

var checks: int = 0
var failures: int = 0
var _rules: Dictionary


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	_rules = JSON.parse_string(FileAccess.get_file_as_string(NightObservation.RULES))
	_test_routes_follow_the_plan()
	_test_records()
	_test_completed_records()
	if failures == 0:
		print("NIGHT ROUTE COMPAT TEST: PASS (%d checks)" % checks)
	else:
		print("NIGHT ROUTE COMPAT TEST: FAILED %d of %d checks" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)


## Every step between a room and a walkable area goes through that room's own
## door, and the door opens onto exactly that area. This is what the old
## landing step broke.
func _test_routes_follow_the_plan() -> void:
	var opens_onto: Dictionary = {}
	for wall: Dictionary in HouseLayout.WALLS:
		for opening: Dictionary in wall["openings"]:
			if not opening.has("to"):
				continue
			for side: float in [-1.0, 1.0]:
				var point: Vector3
				if wall["axis"] == "x":
					point = Vector3(float(opening["pos"]), 0.1, float(wall["at"]) + side * 0.6)
				else:
					point = Vector3(float(wall["at"]) + side * 0.6, 0.1, float(opening["pos"]))
				var area: StringName = HouseLayout.room_at(point)
				if area in HouseLayout.WALKABLE_ROOMS:
					opens_onto[str(opening["to"])] = str(area)
	for origin: String in _rules["routes"]:
		var route: Array = _rules["routes"][origin]
		check(route[0] == origin and route[-1] == origin and route.has("bathroom_upper"), "%s route goes to the bathroom and back" % origin)
		for i: int in route.size() - 1:
			var a: String = route[i]
			var b: String = route[i + 1]
			var a_walk: bool = StringName(a) in HouseLayout.WALKABLE_ROOMS
			var b_walk: bool = StringName(b) in HouseLayout.WALKABLE_ROOMS
			if a_walk and b_walk:
				check(_areas_touch(a, b), "%s route: %s and %s are connected areas" % [origin, a, b])
			elif a_walk != b_walk:
				var room: String = b if a_walk else a
				var area: String = a if a_walk else b
				check(opens_onto.get(room, "") == area, "%s route: %s's door opens onto %s (it opens onto %s)" % [origin, room, area, opens_onto.get(room, "nothing")])
			else:
				check(false, "%s route jumps from room %s straight into room %s" % [origin, a, b])
	check(not (_rules["routes"]["guest_b"] as Array).has("landing") and not (_rules["routes"]["multipurpose"] as Array).has("landing"), "current routes no longer cross the old stair landing")


## Two walkable areas share an edge (no wall listed between them is required:
## they are open circulation in this plan).
func _areas_touch(a: String, b: String) -> bool:
	for ra: Rect2 in HouseLayout.get_room(StringName(a))["rects"]:
		for rb: Rect2 in HouseLayout.get_room(StringName(b))["rects"]:
			if ra.grow(0.01).intersects(rb):
				return true
	return false


func _record(route: Array, observer_route: Array = []) -> Dictionary:
	var steps: Array = []
	var minute: int = 1501
	for room: String in route:
		steps.append({"room": room, "minute": minute})
		minute += 2
	var seen: int = 1501 + 2 * route.find("corridor") + 1
	var record: Dictionary = {"day": 3, "start": 1501, "end": minute - 2, "seen_at": seen,
		"subject": "elena_ward", "observer": "marcus_hale", "subject_reason": _rules["subject_reason"], "observer_reason": _rules["observer_reason"], "denial_reason": _rules["denial_reason"],
		"steps": steps, "snapshot": {"elena_ward": {"status": "resident", "route_access": true, "room": route[0]}, "marcus_hale": {"status": "resident", "route_access": true, "room": observer_route[0] if not observer_route.is_empty() else "guest_a"}},
		"observation": {"room": "corridor", "minute": seen, "awake": true, "sightline": true}}
	return record


func _test_records() -> void:
	for origin: String in ["guest_b", "multipurpose"]:
		check(NightObservation.valid(_record(_rules["routes"][origin])), "current %s record valid" % origin)
		check(NightObservation.valid(_record(_rules["legacy_routes"][origin])), "two-storey %s record from an old save still valid" % origin)
		check(NightObservation.valid(JSON.parse_string(JSON.stringify(_record(_rules["legacy_routes"][origin])))), "old record through JSON still valid (%s)" % origin)
	check(NightObservation.route_variants(_rules, "guest_a").size() == 1, "guest_a never changed, no legacy variant")
	# A made-up route is still refused, legacy or not.
	check(not NightObservation.valid(_record(["guest_a", "landing", "corridor", "bathroom_upper", "corridor", "landing", "guest_a"])), "landing detour never valid for guest_a")
	var mixed: Array = (_rules["legacy_routes"]["guest_b"] as Array).duplicate()
	mixed[-2] = "corridor"
	check(not NightObservation.valid(_record(mixed)), "half-old, half-new route refused")
	var reversed_minutes: Dictionary = _record(_rules["legacy_routes"]["guest_b"])
	reversed_minutes["steps"][2]["minute"] = 1501
	check(not NightObservation.valid(reversed_minutes), "legacy record with out-of-order minutes refused")


## Completed production records: the observer's trace may also follow either
## the current or the legacy route.
func _test_completed_records() -> void:
	for observer_origin: String in ["guest_b", "multipurpose"]:
		for which: String in ["routes", "legacy_routes"]:
			var observer_route: Array = _rules[which][observer_origin]
			var record: Dictionary = _record(_rules["routes"]["guest_a"], observer_route)
			var outward: Array = []
			for room: String in observer_route:
				outward.append(room)
				if room == "corridor":
					break
			var trace: Array = []
			for index: int in outward.size():
				trace.append({"room": outward[index], "minute": 1501 + index})
			var seen: int = int(record["seen_at"])
			for index: int in range(outward.size() - 2, -1, -1):
				trace.append({"room": outward[index], "minute": seen + outward.size() - index})
			record["observer_steps"] = trace
			record["observer_returned_at"] = trace[-1]["minute"]
			record["observation"].merge({"awake_from": 1501, "awake_until": trace[-1]["minute"], "positions": {"route_access": true, "sightline": true, "observer_position_mm": [12000, 1350, 4250], "subject_position_mm": [11000, 1350, 4250]}}, true)
			check(NightObservation.valid_completed(record), "completed record with %s observer trace (%s) valid" % [observer_origin, which])
			var bent: Dictionary = record.duplicate(true)
			bent["observer_steps"][1]["room"] = "hall"
			check(not NightObservation.valid_completed(bent), "observer trace through the wrong area refused (%s, %s)" % [observer_origin, which])
