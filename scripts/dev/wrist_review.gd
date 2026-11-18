extends Node
## Capture of the I-08 wrist readout as the player sees it (placeholder panel
## until Codex's arm art lands in WristView.art_slot). No save or settings
## write. Run only in an isolated copy.  --out=NAME.png (under res://docs/qa/)

func _ready() -> void:
	if not str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")).begins_with("TheQuietHours-Tests/"):
		push_error("wrist_review runs only in an isolated project copy (tools/Run-Tests.ps1 -KeepProjectCopy).")
		get_tree().quit(1)
		return
	GameState.new_campaign(42)
	GameState.day = 3
	GameState.minutes = 21 * 60 + 40
	GameState.player["energy"] = 38
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	player.position = Vector3(6.875, 0.05, 9.0)
	var out: String = "wrist-review.png"
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	Input.action_press(&"wrist")
	while not player.control_enabled:
		await get_tree().process_frame
	await get_tree().create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	var error: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + out)
	print("WRIST REVIEW: SAVED" if error == OK else "FAIL: wrist capture")
	get_tree().quit(0 if error == OK else 1)
