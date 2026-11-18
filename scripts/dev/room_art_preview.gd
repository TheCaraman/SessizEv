extends Node
## Safe outside an isolated copy (DEV-HELPER-GUARDS-001): no campaign session,
## no save or preference write; any GameState change stays in memory.
## Captures write PNGs under res:// only. Opening the campaign session scene
## or saving here would need ReviewSpots.isolated (dev_helpers_test checks).
## Isolated art preview. Never resolves a day or writes a game save.
## --room=<id>, optional --character=<id> for a guest room.
## --capture-room-art saves the real viewport and exits.

const RoomViewScript = preload("res://scripts/ui/room_view.gd")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var room_id: StringName = &"living_room"
	var character_id: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--room="):
			room_id = StringName(argument.trim_prefix("--room="))
		elif argument.begins_with("--character="):
			character_id = argument.trim_prefix("--character=")
	if HouseLayout.get_room(room_id).is_empty() or HouseLayout.WALKABLE_ROOMS.has(room_id):
		_fail("Unknown 2D room")
		return
	if not ResourceLoader.exists("res://assets/rooms/%s.png" % room_id):
		_fail("Room image missing: " + str(room_id))
		return
	if character_id != "":
		if Roster.get_npc(character_id).is_empty():
			_fail("Unknown character")
			return
		if not ResourceLoader.exists("res://assets/characters/%s/default.png" % character_id):
			_fail("Character image missing: " + character_id)
			return
		GameState.new_campaign(42)
		if not GameState.admit(character_id, str(room_id) + "_1"):
			_fail("Character previews require a guest room with a real bed")
			return
	var room_view := RoomViewScript.new()
	add_child(room_view)
	room_view.open(room_id)
	if OS.get_cmdline_user_args().has("--capture-room-art"):
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var directory: String = "res://docs/art/previews"
		var error: Error = DirAccess.make_dir_recursive_absolute(directory)
		if error == OK:
			var suffix: String = "_" + character_id if character_id != "" else ""
			error = get_viewport().get_texture().get_image().save_png(directory + "/" + str(room_id) + suffix + "_in_game.png")
		if error != OK:
			printerr("ROOM ART PREVIEW: FAILED (%d)" % error)
		else:
			print("ROOM ART PREVIEW: SAVED")
		get_tree().quit(0 if error == OK else 1)


func _fail(message: String) -> void:
	printerr("ROOM ART PREVIEW: " + message)
	get_tree().quit(1)
