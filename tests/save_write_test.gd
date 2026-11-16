extends Node

class FaultyWriter extends "res://scripts/save/save_manager.gd":
	var fault: String = ""
	func _write_text(path: String, text: String) -> Error:
		if fault == "write":
			return ERR_FILE_CANT_WRITE
		if fault == "truncate":
			return super._write_text(path, "{")
		return super._write_text(path, text)
	func _move_file(from: String, to: String) -> Error:
		if fault == "rotate" and to.ends_with(".backup"):
			return ERR_FILE_CANT_WRITE
		if fault in ["publish", "rollback"] and from.ends_with(".pending"):
			return ERR_FILE_CANT_WRITE
		if fault == "rollback" and from.ends_with(".backup"):
			return ERR_FILE_CANT_WRITE
		return super._move_file(from, to)

var checks: int = 0
var failures: int = 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _ready() -> void:
	var writer := FaultyWriter.new()
	add_child(writer)
	var slot: String = "safe_write_test"
	var path: String = writer.get_path_for(slot)
	writer.delete_save(slot)
	GameState.new_campaign(42)
	check(writer.save_game(slot) == OK, "first publication")
	var original: String = FileAccess.get_file_as_string(path)
	for fault: String in ["write", "truncate", "rotate", "publish", "rollback"]:
		writer.fault = ""
		GameState.new_campaign(42)
		check(writer.save_game(slot) == OK, "restore committed baseline")
		GameState.player["energy"] = 45
		var live: Dictionary = GameState.to_dict().duplicate(true)
		writer.fault = fault
		check(writer.save_game(slot) != OK, "failure reported " + fault)
		check(GameState.to_dict() == live, "writer never mutates campaign " + fault)
		check(writer.has_save(slot) and writer.load_game(slot), "old save remains loadable " + fault)
		check(GameState.player["energy"] == 100, "uncommitted decision not loaded " + fault)
		var committed: String = path if FileAccess.file_exists(path) else path + ".backup"
		check(FileAccess.get_file_as_string(committed) == original, "previous bytes preserved " + fault)
	writer.fault = ""
	GameState.player["energy"] = 55
	check(writer.save_game(slot) == OK and writer.load_game(slot), "retry after failed rollback")
	check(GameState.player["energy"] == 55, "retry commits new state")
	GameState.minutes = -1
	check(writer.save_game(slot) == ERR_INVALID_DATA, "invalid candidate rejected before write")
	check(writer.load_game(slot) and GameState.player["energy"] == 55, "invalid candidate preserves last save")
	check(writer.save_game("../escape") == ERR_INVALID_PARAMETER, "invalid slot refused")
	writer.delete_save(slot)
	check(not writer.has_save(slot) and not FileAccess.file_exists(path + ".pending"), "delete also removes recovery files")
	writer.free()
	if failures == 0:
		print("SAVE WRITE TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
