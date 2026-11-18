extends Node
## DOOR-REFERENCE-003 review: real rendered frames of opening the living-room
## door, about every 70 ms from the key press to the room view. Top rows have
## camera motion on; the last row has it off (dissolve). Writes no save; it
## changes camera_motion only inside an isolated project copy and restores it.
## Run only in an isolated copy.  --out=NAME.png (under res://docs/qa/)

const COLUMNS: int = 4
const SCALE: float = 0.4
const INTERVAL: float = 0.07


func _ready() -> void:
	if not ReviewSpots.isolated(get_tree()):
		return
	GameState.new_campaign(42)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	var room: RoomView = scene.get_node("RoomView")
	var door: RoomDoor = scene.find_child("Door_living_room", true, false)
	var out: String = "door-reference/door-transition.png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	while not player.control_enabled:
		await get_tree().process_frame
	var motion: float = Settings.get_number("camera_motion")
	var frames: Array[Image] = []
	for reduced: bool in [false, true]:
		Settings.set_number("camera_motion", 0.0 if reduced else 1.0)
		player.global_position = door.to_global(Vector3(0.0, 0.05, 1.3))
		player.global_rotation = Vector3(0.0, door.global_rotation.y, 0.0)
		player.get_node("Head").rotation.x = 0.0
		await get_tree().create_timer(0.5).timeout
		frames.append(await _grab())
		door.interact(player)
		var shots: int = 7 if not reduced else 7
		for _i: int in shots:
			await get_tree().create_timer(INTERVAL).timeout
			frames.append(await _grab())
		await get_tree().create_timer(0.3).timeout
		room.close()
		await get_tree().create_timer(RoomDoor.CLOSE_SECONDS + 0.2).timeout
	Settings.set_number("camera_motion", motion)

	var w: int = int(frames[0].get_width() * SCALE)
	var h: int = int(frames[0].get_height() * SCALE)
	var rows: int = ceili(frames.size() / float(COLUMNS))
	var sheet := Image.create(w * COLUMNS, h * rows, false, Image.FORMAT_RGB8)
	for i: int in frames.size():
		var frame: Image = frames[i]
		frame.convert(Image.FORMAT_RGB8)
		frame.resize(w, h, Image.INTERPOLATE_BILINEAR)
		sheet.blit_rect(frame, Rect2i(0, 0, w, h), Vector2i((i % COLUMNS) * w, (i / COLUMNS) * h))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/qa/" + out.get_base_dir()))
	var error: Error = sheet.save_png("res://docs/qa/" + out)
	print("DOOR REVIEW: SAVED" if error == OK else "FAIL: door capture")
	get_tree().quit(0 if error == OK else 1)


func _grab() -> Image:
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()
