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
	var path: String = get_path_for(slot)
	if not FileAccess.file_exists(path):
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary:
		push_warning("SaveManager: %s is not a valid save" % path)
		return false
	var payload: Dictionary = parsed
	var version: int = int(payload.get("save_version", 0))
	if version < 1 or version > GameState.SAVE_VERSION:
		push_warning("SaveManager: %s has unsupported version %d" % [path, version])
		return false
	if not payload.get("state") is Dictionary:
		return false
	GameState.from_dict(payload["state"])
	return true


func delete_save(slot: String = AUTOSAVE_SLOT) -> void:
	if has_save(slot):
		DirAccess.remove_absolute(get_path_for(slot))
