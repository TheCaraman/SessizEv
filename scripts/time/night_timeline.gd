class_name NightTimeline
extends RefCounted
## Pure night accounting. Never changes GameState or resolves household supplies.
const RULES_PATH: String = "res://resources/events/night_watch.json"
var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES_PATH))
var _state: Dictionary = {}

func begin(day: int, energy: int) -> bool:
	if not _state.is_empty() or day != int(rules["day"]) or energy < 0 or energy > 100:
		return false
	_state = {"day": day, "state": "awake", "start_minute": int(rules["start"]), "cursor_minute": int(rules["start"]), "awake_minutes": 0, "asleep_minutes": 0, "initial_energy": energy, "resolved_boundaries": [], "morning_resolved": false}
	return true

func to_dict() -> Dictionary:
	return _state.duplicate(true)

func from_dict(data: Dictionary) -> bool:
	if not valid(data):
		return false
	_state = data.duplicate(true)
	for key: String in ["day", "start_minute", "cursor_minute", "awake_minutes", "asleep_minutes", "initial_energy"]:
		_state[key] = int(_state[key])
	var boundaries: Array = []
	for value: Variant in _state["resolved_boundaries"]:
		boundaries.append(int(value))
	_state["resolved_boundaries"] = boundaries
	return true

func next_boundary() -> int:
	if _state.is_empty():
		return int(rules["start"])
	var cursor: int = _state["cursor_minute"]
	var start: int = rules["start"]
	var step: int = rules["boundary_minutes"]
	return mini(start + (int((cursor - start) / step) + 1) * step, int(rules["end"]))

## Returns newly crossed boundaries only. Backward/repeated time costs nothing.
func advance_to(target: int, sleeping: bool = false) -> Array[int]:
	var crossed: Array[int] = []
	if _state.is_empty() or _state["state"] == "resolved":
		return crossed
	var cursor: int = _state["cursor_minute"]
	var end: int = mini(target, int(rules["end"]))
	if end <= cursor:
		return crossed
	_state["asleep_minutes" if sleeping else "awake_minutes"] += end - cursor
	_state["cursor_minute"] = end
	_state["state"] = "sleeping" if sleeping else "awake"
	var boundary: int = int(rules["start"]) + int(rules["boundary_minutes"])
	while boundary <= int(rules["end"]):
		if boundary > cursor and boundary <= end:
			_state["resolved_boundaries"].append(boundary)
			crossed.append(boundary)
		boundary += int(rules["boundary_minutes"])
	if end == int(rules["end"]):
		_state["state"] = "resolved"
	return crossed

func energy() -> int:
	if _state.is_empty():
		return 0
	var delta: float = (float(_state["asleep_minutes"]) * float(rules["sleep_energy_per_hour"]) - float(_state["awake_minutes"]) * float(rules["awake_energy_per_hour"])) / 60.0
	return clampi(roundi(float(_state["initial_energy"]) + delta), 0, 100)

## The owning campaign controller may consume supplies only when this succeeds.
func claim_morning() -> bool:
	if _state.is_empty() or _state["state"] != "resolved" or _state["morning_resolved"]:
		return false
	_state["morning_resolved"] = true
	return true

func valid(data: Dictionary) -> bool:
	for key: String in ["day", "start_minute", "cursor_minute", "awake_minutes", "asleep_minutes", "initial_energy"]:
		var value: Variant = data.get(key)
		if not (value is int or value is float) or not is_finite(float(value)) or float(value) != floorf(float(value)):
			return false
	if int(data["day"]) != int(rules["day"]) or int(data["start_minute"]) != int(rules["start"]):
		return false
	var cursor: int = int(data["cursor_minute"])
	if cursor < int(rules["start"]) or cursor > int(rules["end"]):
		return false
	if int(data["initial_energy"]) < 0 or int(data["initial_energy"]) > 100 or int(data["awake_minutes"]) < 0 or int(data["asleep_minutes"]) < 0:
		return false
	if int(data["awake_minutes"]) + int(data["asleep_minutes"]) != cursor - int(rules["start"]):
		return false
	if data.get("state") not in ["awake", "sleeping", "resolved"] or not data.get("morning_resolved") is bool or not data.get("resolved_boundaries") is Array:
		return false
	if (data["state"] == "resolved") != (cursor == int(rules["end"])) or (data["morning_resolved"] and data["state"] != "resolved"):
		return false
	var expected: Array = []
	var boundary: int = int(rules["start"]) + int(rules["boundary_minutes"])
	while boundary <= cursor:
		expected.append(boundary)
		boundary += int(rules["boundary_minutes"])
	var actual: Array = data["resolved_boundaries"]
	if actual.size() != expected.size():
		return false
	for index: int in expected.size():
		var value: Variant = actual[index]
		if not (value is int or value is float) or float(value) != float(expected[index]):
			return false
	return true
