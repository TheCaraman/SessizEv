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
var day_signals: int = 0
var resource_signals: int = 0
var persisted_before_signal: bool = false

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
	GameState.new_campaign(42)
	var expected: Dictionary = GameState.to_dict()
	var candidate: Dictionary = expected.duplicate(true)
	candidate["minutes"] += 15
	candidate["resources"]["repair"] -= 1
	EventBus.day_started.connect(_on_day)
	EventBus.resources_changed.connect(_on_resources.bind(path))
	for fault: String in ["write", "truncate", "publish", "rollback"]:
		writer.fault = ""
		check(writer.save_game(slot) == OK, "transaction baseline")
		writer.fault = fault
		check(writer.commit_candidate(expected, candidate, "decision-1", slot) != OK, "failed transaction " + fault)
		check(GameState.to_dict() == expected and resource_signals == 0, "no costs or signals on failure " + fault)
	writer.fault = ""
	check(writer.commit_candidate(expected, candidate, "decision-1", slot) == OK, "candidate committed")
	check(GameState.minutes == int(candidate["minutes"]) and GameState.resources["repair"] == 2, "cost and time applied once")
	check(day_signals == 0 and resource_signals == 1 and persisted_before_signal, "disk precedes notification without false day start")
	var after: Dictionary = GameState.to_dict()
	check(writer.commit_candidate(expected, candidate, "decision-1", slot) == ERR_ALREADY_EXISTS and GameState.to_dict() == after, "double click is idempotent")
	check(writer.commit_candidate(expected, candidate, "decision-2", slot) == ERR_BUSY, "stale confirmation rejected")
	check(writer.load_game(slot) and GameState.flags.has("transaction/decision-1"), "marker survives load")
	check(writer.commit_candidate(expected, candidate, "decision-1", slot) == ERR_ALREADY_EXISTS, "reloaded transaction cannot repeat")
	var current: Dictionary = GameState.to_dict()
	var infected: Dictionary = current.duplicate(true)
	infected["npcs"]["elena_ward"]["infected"] = not infected["npcs"]["elena_ward"]["infected"]
	check(writer.commit_candidate(current, infected, "bad-infection", slot) == ERR_INVALID_DATA, "judgment cannot rewrite infection")
	check(GameState.to_dict() == current, "invalid candidate leaves live state untouched")
	EventBus.day_started.disconnect(_on_day)
	EventBus.resources_changed.disconnect(_on_resources)
	writer.delete_save(slot)
	writer.free()
	if failures == 0:
		print("SAVE WRITE TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)

func _on_day(_day: int) -> void:
	day_signals += 1

func _on_resources(path: String) -> void:
	resource_signals += 1
	var payload: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	persisted_before_signal = payload is Dictionary and payload["state"]["flags"].get("transaction/decision-1", false)
