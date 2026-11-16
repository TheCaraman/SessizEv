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
	return FileAccess.file_exists(get_path_for(slot)) or FileAccess.file_exists(get_path_for(slot) + ".backup")


## Saves the current campaign. Returns OK or the error that stopped it.
func save_game(slot: String = AUTOSAVE_SLOT) -> Error:
	return _save_state(GameState.to_dict(), slot)


## A caller builds the candidate without touching live GameState. No await or
## signals occur until persistence succeeds. A stale quote must be rebuilt.
func commit_candidate(expected: Dictionary, candidate: Dictionary, transaction_id: String, slot: String = AUTOSAVE_SLOT) -> Error:
	if not GameState.active or transaction_id.is_empty() or not transaction_id.is_valid_filename() or transaction_id.contains("."):
		return ERR_INVALID_PARAMETER
	var marker: String = "transaction/" + transaction_id
	if GameState.flags.has(marker):
		return ERR_ALREADY_EXISTS
	if GameState.to_dict() != expected:
		return ERR_BUSY
	if not _valid_state_shape(candidate) or candidate.size() != expected.size():
		return ERR_INVALID_DATA
	for key: String in expected:
		if not candidate.has(key):
			return ERR_INVALID_DATA
	# A shelter judgment cannot silently replace the campaign or its infection
	# assignments. Player exposure is a separate authored system, not this API.
	if candidate["day"] != expected["day"] or candidate["minutes"] < expected["minutes"] or candidate["campaign_seed"] != expected["campaign_seed"] or candidate["player"].get("infection") != expected["player"].get("infection"):
		return ERR_INVALID_DATA
	for id: String in expected["npcs"]:
		if candidate["npcs"][id]["infected"] != expected["npcs"][id]["infected"]:
			return ERR_INVALID_DATA
	if candidate["flags"].has(marker):
		return ERR_INVALID_DATA
	var committed: Dictionary = candidate.duplicate(true)
	committed["flags"][marker] = true
	var result: Error = _save_state(committed, slot)
	if result != OK:
		return result
	GameState.from_dict(committed, false)
	return OK


func _save_state(state: Dictionary, slot: String) -> Error:
	if slot.is_empty() or not slot.is_valid_filename() or slot.contains("."):
		return ERR_INVALID_PARAMETER
	if not _valid_state_shape(state):
		return ERR_INVALID_DATA
	var dir_error: Error = DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	if dir_error != OK:
		return dir_error
	var path: String = get_path_for(slot)
	var pending: String = path + ".pending"
	var backup: String = path + ".backup"
	var text: String = JSON.stringify({"save_version": GameState.SAVE_VERSION, "state": state}, "\t")
	var result: Error = _write_text(pending, text)
	if result != OK:
		return result
	if FileAccess.get_file_as_string(pending) != text or _read_state_path(pending).is_empty():
		return ERR_FILE_CORRUPT
	# Windows Godot rename deletes an existing destination before moving. Never
	# publish over an existing file: rotate it first and retain a recovery copy.
	if FileAccess.file_exists(path):
		if FileAccess.file_exists(backup):
			result = DirAccess.remove_absolute(backup)
			if result != OK:
				return result
		result = _move_file(path, backup)
		if result != OK:
			return result
	result = _move_file(pending, path)
	if result != OK and not FileAccess.file_exists(path) and FileAccess.file_exists(backup):
		_move_file(backup, path)
	return result


func _write_text(path: String, text: String) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(text)
	file.flush()
	var result: Error = file.get_error()
	file.close()
	return result


func _move_file(from: String, to: String) -> Error:
	return DirAccess.rename_absolute(from, to)


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
	# An interrupted publish can leave only the previous committed file. Never
	# promote .pending: its decision was not committed.
	if not FileAccess.file_exists(path):
		path += ".backup"
	return _read_state_path(path)


func _read_state_path(path: String) -> Dictionary:
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
		if not entry is Dictionary or not entry.get("args", {}) is Dictionary:
			return false
	var isolated_count: int = 0
	for id: String in state["npcs"]:
		var person: Dictionary = state["npcs"][id]
		if person.has("isolated") and not person["isolated"] is bool:
			return false
		if not person.get("isolated", false):
			continue
		isolated_count += 1
		if person["status"] != "resident" or state.get("jobs", {}).has(id) or not state["flags"].get("isolation_ready", false):
			return false
		var reserved: bool = false
		for bed: String in state.get("beds", {}):
			if state["beds"][bed] == id and bed in GameState.BEDS and GameState.bed_room(bed) == person["room"]:
				reserved = true
		if not reserved:
			return false
	if isolated_count > 1:
		return false
	if not Accusation.valid_state(state):
		return false
	for key: String in ["day4_review_deferred", "day4_review_completed"]:
		if state["flags"].has(key) and not state["flags"][key] is bool:
			return false
		if state["flags"].get(key, false) and (int(state["day"]) < 4 or state["flags"].get("day4_reviewed") != true):
			return false
	if state["flags"].has("day4_review_completed_at"):
		var at: Variant = state["flags"]["day4_review_completed_at"]
		if state["flags"].get("day4_review_completed") != true or not _whole_number(at) or float(at) < 1200 or float(at) > 1439:
			return false
		if int(state["day"]) == 4 and int(at) > int(state["minutes"]):
			return false
	elif state["flags"].get("day4_review_completed", false):
		return false
	if state["flags"].has("night_witness_enabled") and not state["flags"]["night_witness_enabled"] is bool:
		return false
	if state["flags"].has("night_witness_record"):
		var record: Variant = state["flags"]["night_witness_record"]
		if not record is Dictionary or not NightObservation.valid_completed(record):
			return false
		if state["flags"].get("night_witness_enabled") != true or int(state["day"]) < 3:
			return false
		if state["flags"].get("night_pipes_day3_heard") != true:
			return false
		if not _whole_number(state["flags"].get("night_pipes_day3_minute")) or int(state["flags"]["night_pipes_day3_minute"]) > int(record["start"]):
			return false
		if int(state["day"]) == 3 and maxi(int(record["end"]), int(record["observer_returned_at"])) > int(state["minutes"]):
			return false
	return true


func _whole_number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and float(value) == floorf(float(value))


func delete_save(slot: String = AUTOSAVE_SLOT) -> void:
	for suffix: String in ["", ".backup", ".pending"]:
		var path: String = get_path_for(slot) + suffix
		if FileAccess.file_exists(path):
			DirAccess.remove_absolute(path)
