extends Node
## BODYCAM-002 review: a contact sheet of real rendered frames while Daniel
## walks and turns in the house (top row: standing, then walking; bottom row:
## walking, then turning right, then settled). Writes no save or settings.
## Run only in an isolated project copy.  --out=NAME.png (under res://docs/qa/)

const COLUMNS: int = 3
const SCALE: float = 0.5


func _ready() -> void:
	GameState.new_campaign(42)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	var out: String = "bodycam/bodycam-review.png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	while not player.control_enabled:
		await get_tree().process_frame
	await get_tree().create_timer(0.6).timeout
	var frames: Array[Image] = []
	frames.append(await _grab())
	Input.action_press(&"move_forward")
	await get_tree().create_timer(0.45).timeout
	for _i: int in 3:
		frames.append(await _grab())
		await get_tree().create_timer(0.16).timeout
	Input.action_release(&"move_forward")
	for _i: int in 18:
		player.rotate_y(-0.045)
		await get_tree().process_frame
	frames.append(await _grab())
	await get_tree().create_timer(1.2).timeout
	frames.append(await _grab())

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
	print("BODYCAM REVIEW: SAVED" if error == OK else "FAIL: bodycam capture")
	get_tree().quit(0 if error == OK else 1)


func _grab() -> Image:
	await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()
