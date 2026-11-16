extends Node
## Writes and reads campaign saves (autoload: SaveManager).
##
## A save is a JSON file under user://saves/ holding a version number and the
## dictionary from GameState.to_dict(). The version exists so later builds can
## migrate older saves instead of rejecting them.

const SAVE_DIR: String = "user://saves"
const AUTOSAVE_SLOT: String = "autosave"


func get_path_for(slot: String) -> String:
	return "%s/%s.json" % [SAVE_DIR, slot]


func has_save(slot: String = AUTOSAVE_SLOT) -> bool:
	return FileAccess.file_exists(get_path_for(slot))


## Saves the current campaign. Returns OK or the error that stopped it.
func save_game(slot: String = AUTOSAVE_SLOT) -> Error:
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if dir_error != OK:
		return dir_error
	var file := FileAccess.open(get_path_for(slot), FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	var payload: Dictionary = {
		"save_version": GameState.SAVE_VERSION,
		"state": GameState.to_dict(),
	}
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	return OK


## Loads a campaign into GameState. Returns false if the file is missing,
## unreadable, or from a newer version of the game.
func load_game(slot: String = AUTOSAVE_SLOT) -> bool:
	var state: Dictionary = _read_state(slot)
	if state.is_empty():
		return false
	GameState.from_dict(state)
	return true


## A few facts about a save for menus, without loading it: {"day", "minutes"}.
## Returns an empty dictionary if there is no usable save in the slot.
func get_summary(slot: String = AUTOSAVE_SLOT) -> Dictionary:
	var state: Dictionary = _read_state(slot)
	if state.is_empty():
		return {}
	return {"day": int(state.get("day", 1)), "minutes": int(state.get("minutes", 0))}


## Reads and validates a save, returning its state dictionary, or an empty
## dictionary if the file is missing, damaged or from a newer version.
## A damaged file is an expected situation, not a program error, so it is
## handled quietly.
func _read_state(slot: String) -> Dictionary:
	var path: String = get_path_for(slot)
	if not FileAccess.file_exists(path):
		return {}
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK or not json.data is Dictionary:
		return {}
	var payload: Dictionary = json.data
	if not _whole_number(payload.get("save_version")):
		return {}
	var version: int = int(payload.get("save_version", 0))
	if version < 1 or version > GameState.SAVE_VERSION:
		return {}
	if not payload.get("state") is Dictionary:
		return {}
	var state: Dictionary = payload["state"]
	return state if _valid_state_shape(state) else {}


## Validate before from_dict can mutate live state. Older optional fields remain
## optional so version 1–3 migrations continue to preserve their original data.
func _valid_state_shape(state: Dictionary) -> bool:
	for key: String in ["campaign_seed", "day", "minutes"]:
		if not _whole_number(state.get(key)):
			return false
	if int(state["day"]) < 1 or int(state["minutes"]) < 0:
		return false
	var night: Variant = state.get("night_session", {})
	if not night is Dictionary:
		return false
	var extended_night: bool = false
	if not night.is_empty():
		var timeline := NightTimeline.new()
		if not timeline.valid(night):
			return false
		var night_day: int = int(night["day"])
		if night["morning_resolved"]:
			if int(state["day"]) <= night_day:
				return false
		else:
			if int(state["day"]) != night_day or int(state["minutes"]) != int(night["cursor_minute"]):
				return false
			extended_night = true
	if int(state["minutes"]) > (1860 if extended_night else 1439):
		return false
	for key: String in ["flags", "resources", "player", "npcs"]:
		if not state.get(key) is Dictionary:
			return false
	for key: String in ["beds", "jobs", "power_incident"]:
		if state.has(key) and not state[key] is Dictionary:
			return false
	for key: String in ["resolved_arrivals", "completed_jobs", "reports", "evidence"]:
		if state.has(key) and not state[key] is Array:
			return false
	for value: Variant in state["resources"].values():
		if not _whole_number(value) or float(value) < 0:
			return false
	for key: String in GameState.STARTING_RESOURCES:
		if not state["resources"].has(key):
			return false
	for id: String in Roster.get_ids():
		if not state["npcs"].has(id):
			return false
	for key: String in ["energy", "stress"]:
		if not _whole_number(state["player"].get(key)):
			return false
	for entry: Variant in state["npcs"].values():
		if not entry is Dictionary:
			return false
		if not entry.get("infected") is bool or not _whole_number(entry.get("trust")):
			return false
		for key: String in ["status", "room"]:
			if not entry.get(key) is String:
				return false
	for entry: Variant in state.get("jobs", {}).values():
		if not entry is Dictionary:
			return false
		for key: String in ["day", "start", "end"]:
			if not _whole_number(entry.get(key)):
				return false
	for entry: Variant in state.get("reports", []):
		if not entry is Dictionary or not entry.get("args", {}) is Dictionary:
			return false
	for entry: Variant in state.get("evidence", []):
		if not entry is Dictionary:
			return false
	return true


func _whole_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))


func delete_save(slot: String = AUTOSAVE_SLOT) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(get_path_for(slot))
