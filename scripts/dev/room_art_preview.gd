extends Node
## Isolated art preview. Does not start a campaign, resolve days or save.
## Pass -- --capture-room-art to save a real viewport image and exit.

const RoomViewScript = preload("res://scripts/ui/room_view.gd")

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var room_view := RoomViewScript.new()
	add_child(room_view)
	room_view.open(&"living_room")
	if OS.get_cmdline_user_args().has("--capture-room-art"):
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var directory: String = "res://docs/art/previews"
		var error: Error = DirAccess.make_dir_recursive_absolute(directory)
		if error == OK:
			error = get_viewport().get_texture().get_image().save_png(directory + "/living_room_in_game.png")
		if error != OK:
			printerr("ROOM ART PREVIEW: FAILED (%d)" % error)
		else:
			print("ROOM ART PREVIEW: SAVED")
		get_tree().quit(0 if error == OK else 1)
