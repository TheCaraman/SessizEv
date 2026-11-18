class_name NightObservation
extends RefCounted
## Validates a completed, authored off-screen observation. It does not invent
## awake witnesses or run movement. The director must supply the actual record.

const RULES: String = "res://resources/events/night_observation.json"

static func valid(record: Dictionary) -> bool:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	for key: String in ["day", "start", "end", "seen_at"]:
		if not whole(record.get(key)):
			return false
	if record["day"] != rules["day"] or record["start"] < rules["earliest"] or record["end"] > rules["latest"] or record["start"] >= record["end"]:
		return false
	var subject: Variant = record.get("subject")
	var observer: Variant = record.get("observer")
	if subject == observer or subject not in rules["allowed_adults"] or observer not in rules["allowed_adults"]:
		return false
	if record.get("subject_reason") != rules["subject_reason"] or record.get("observer_reason") != rules["observer_reason"] or record.get("denial_reason") != rules["denial_reason"]:
		return false
	var steps: Variant = record.get("steps")
	if not steps is Array or steps.is_empty() or not steps[0] is Dictionary:
		return false
	var route: Array = []
	for variant: Array in route_variants(rules, str(steps[0].get("room", ""))):
		if _rooms_match(steps, variant):
			route = variant
			break
	if route.is_empty():
		return false
	var previous: int = -1
	var seen_in_corridor: bool = false
	for i: int in steps.size():
		var step: Variant = steps[i]
		if not step is Dictionary or step.get("room") != route[i] or not whole(step.get("minute")):
			return false
		var minute: int = int(step["minute"])
		if minute <= previous or minute < record["start"] or minute > record["end"]:
			return false
		previous = minute
		if i + 1 < steps.size() and step["room"] == "corridor":
			var next: Variant = steps[i + 1]
			if next is Dictionary and whole(next.get("minute")) and minute <= record["seen_at"] and record["seen_at"] < next["minute"]:
				seen_in_corridor = true
	if steps[0]["minute"] != record["start"] or steps[-1]["minute"] != record["end"] or not seen_in_corridor:
		return false
	var snapshot: Variant = record.get("snapshot")
	if not snapshot is Dictionary:
		return false
	for id: String in [subject, observer]:
		var person: Variant = snapshot.get(id)
		if not person is Dictionary or person.get("status") != "resident":
			return false
		for flag: String in ["isolated", "absent", "injured", "incapacitated", "busy"]:
			if person.get(flag, false) != false:
				return false
		if not person.get("route_access") is bool or not person["route_access"]:
			return false
	var sight: Variant = record.get("observation")
	if not sight is Dictionary or sight.get("room") != "corridor" or sight.get("awake") != true or sight.get("sightline") != true:
		return false
	if not whole(sight.get("minute")) or sight["minute"] != record["seen_at"]:
		return false
	return true

## Routes that a record starting in [param room] may follow: the current plan's
## route first, then any legacy route (NIGHT-ROUTE-COMPAT-001). Records saved
## under an older house plan stay valid; new records use the current route.
static func route_variants(rules: Dictionary, room: String) -> Array:
	var variants: Array = []
	var current: Variant = rules["routes"].get(room)
	if current is Array and not current.is_empty():
		variants.append(current)
	var legacy: Variant = rules.get("legacy_routes", {}).get(room)
	if legacy is Array and not legacy.is_empty() and legacy != current:
		variants.append(legacy)
	return variants


static func _rooms_match(steps: Array, route: Array) -> bool:
	if steps.size() != route.size():
		return false
	for i: int in steps.size():
		if not steps[i] is Dictionary or steps[i].get("room") != route[i]:
			return false
	return true


static func _observer_trace_rooms(route: Array) -> Array:
	var outward: Array = []
	for room: String in route:
		outward.append(room)
		if room == "corridor":
			break
	var expected: Array = outward.duplicate()
	for index: int in range(outward.size() - 2, -1, -1):
		expected.append(outward[index])
	return expected


static func whole(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and floorf(float(value)) == float(value)

## Production records additionally prove the observer's timed return and wake interval.
static func valid_completed(record: Dictionary) -> bool:
	if not valid(record) or not whole(record.get("observer_returned_at")):
		return false
	var trace: Variant = record.get("observer_steps")
	var snapshot: Dictionary = record["snapshot"]
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	var subject_room: Variant = snapshot[record["subject"]].get("room")
	var observer_room: Variant = snapshot[record["observer"]].get("room")
	if subject_room != record["steps"][0]["room"] or not rules["routes"].has(observer_room):
		return false
	if not trace is Array:
		return false
	var expected: Array = []
	for variant: Array in route_variants(rules, str(observer_room)):
		var rooms: Array = _observer_trace_rooms(variant)
		if _rooms_match(trace, rooms):
			expected = rooms
			break
	if expected.is_empty():
		return false
	var previous: int = -1
	var observing: bool = false
	for index: int in trace.size():
		var step: Variant = trace[index]
		if not step is Dictionary or step.get("room") != expected[index] or not whole(step.get("minute")):
			return false
		var minute: int = int(step["minute"])
		if minute <= previous or minute < record["start"] or minute > 1859:
			return false
		previous = minute
		if step["room"] == "corridor" and index + 1 < trace.size():
			var next: Variant = trace[index + 1]
			if next is Dictionary and whole(next.get("minute")):
				observing = minute <= record["seen_at"] and record["seen_at"] < next["minute"]
	var sight: Dictionary = record["observation"]
	if not observing or trace[0]["minute"] != record["start"] or trace[-1]["minute"] != record["observer_returned_at"]:
		return false
	if not whole(sight.get("awake_from")) or not whole(sight.get("awake_until")) or sight["awake_from"] != record["start"] or sight["awake_until"] != record["observer_returned_at"]:
		return false
	var positions: Variant = sight.get("positions")
	if not positions is Dictionary or positions.get("route_access") != true or positions.get("sightline") != true:
		return false
	for key: String in ["observer_position_mm", "subject_position_mm"]:
		var point: Variant = positions.get(key)
		if not point is Array or point.size() != 3:
			return false
		for axis: Variant in point:
			if not whole(axis):
				return false
	return true
