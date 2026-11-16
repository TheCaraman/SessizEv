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
	var route: Variant = rules["routes"].get(str(steps[0].get("room", "")), [])
	if route.is_empty() or route.size() != steps.size():
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

static func whole(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and floorf(float(value)) == float(value)
