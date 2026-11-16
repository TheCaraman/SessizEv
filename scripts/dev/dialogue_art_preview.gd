extends Node
## Art-only conversation preview using the real authored dialogue UI/runner.
## Does not create a campaign scene or write saves.

const CONVERSATIONS: Dictionary = {
	"elena_ward": "elena_arrival", "marcus_hale": "marcus_arrival", "arthur_bell": "arthur_arrival",
}

func _ready() -> void:
	var character_id: String = "elena_ward"
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--character="):
			character_id = argument.trim_prefix("--character=")
	if not CONVERSATIONS.has(character_id) or not ResourceLoader.exists(
		"res://assets/characters/%s/default.png" % character_id
	):
		printerr("DIALOGUE ART PREVIEW: missing/unknown character")
		get_tree().quit(1)
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	GameState.new_campaign(42)
	var room := RoomView.new()
	add_child(room)
	room.open(&"living_room")
	var runner := DialogueRunner.new()
	add_child(runner)
	var view := DialogueView.new()
	add_child(view)
	view.setup(runner)
	runner.start(CONVERSATIONS[character_id])
	runner.choose(0)
	runner.choose(0)
	if OS.get_cmdline_user_args().has("--capture-dialogue-art"):
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var directory: String = "res://docs/art/previews"
		var error: Error = DirAccess.make_dir_recursive_absolute(directory)
		if error == OK:
			error = get_viewport().get_texture().get_image().save_png(
				directory + "/" + character_id + "_dialogue.png"
			)
		print("DIALOGUE ART PREVIEW: SAVED" if error == OK else "DIALOGUE ART PREVIEW: FAILED")
		get_tree().quit(0 if error == OK else 1)
