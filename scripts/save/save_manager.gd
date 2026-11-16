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
	var version: int = int(payload.get("save_version", 0))
	if version < 1 or version > GameState.SAVE_VERSION:
		return {}
	if not payload.get("state") is Dictionary:
		return {}
	return payload["state"]


func delete_save(slot: String = AUTOSAVE_SLOT) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(get_path_for(slot))
