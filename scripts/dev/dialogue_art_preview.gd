extends Node
## Safe outside an isolated copy (DEV-HELPER-GUARDS-001): no campaign session,
## no save or preference write; any GameState change stays in memory.
## Captures write PNGs under res:// only. Opening the campaign session scene
## or saving here would need ReviewSpots.isolated (dev_helpers_test checks).
## Art-only conversation preview using the real authored dialogue UI/runner.
## Does not create a campaign scene or write saves.

const CONVERSATIONS: Dictionary = {
	"elena_ward": "elena_arrival", "marcus_hale": "marcus_arrival", "arthur_bell": "arthur_arrival",
}

func _ready() -> void:
	var character_id: String = "elena_ward"
	var candidate_path: String = ""
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--character="):
			character_id = argument.trim_prefix("--character=")
		elif argument.begins_with("--candidate-image="):
			candidate_path = argument.trim_prefix("--candidate-image=")
	if not CONVERSATIONS.has(character_id) or not ResourceLoader.exists(
		"res://assets/characters/%s/default.png" % character_id
	):
		printerr("DIALOGUE ART PREVIEW: missing/unknown character")
		get_tree().quit(1)
		return
	if candidate_path != "" and (not candidate_path.begins_with("res://assets/characters/") or not ResourceLoader.exists(candidate_path)):
		printerr("DIALOGUE ART PREVIEW: missing/invalid candidate image")
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
	if candidate_path != "":
		var source: Texture2D = load(candidate_path)
		var portrait := AtlasTexture.new()
		portrait.atlas = source
		portrait.region = Rect2(float(source.get_width()) * 0.12, 0.0, float(source.get_width()) * 0.76, float(source.get_height()) * 0.62)
		view._figure.texture = portrait
		var banner := CanvasLayer.new()
		banner.layer = 30
		add_child(banner)
		var caption := Label.new()
		caption.position = Vector2(40, 24)
		caption.text = "Character style study — candidate"
		caption.add_theme_font_size_override("font_size", 26)
		banner.add_child(caption)
	if OS.get_cmdline_user_args().has("--capture-dialogue-art"):
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var directory: String = "res://docs/art/previews"
		var error: Error = DirAccess.make_dir_recursive_absolute(directory)
		if error == OK:
			error = get_viewport().get_texture().get_image().save_png(
				directory + "/" + character_id + ("_candidate" if candidate_path != "" else "") + "_dialogue.png"
			)
		print("DIALOGUE ART PREVIEW: SAVED" if error == OK else "DIALOGUE ART PREVIEW: FAILED")
		get_tree().quit(0 if error == OK else 1)
