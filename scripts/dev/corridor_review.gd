extends Node
## Art-only real corridor camera. No campaign save or day resolution.

func _ready() -> void:
	GameState.new_campaign(42)
	GameState.minutes = 660
	var upper: bool = "--upper" in OS.get_cmdline_user_args()
	if "--night" in OS.get_cmdline_user_args():
		GameState.minutes = 1350
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	player.control_enabled = false
	player.position = Vector3(5.5, 2.85, 7.7) if upper else Vector3(5.5, 0.05, 8.2)
	player.rotation.y = 0.0
	if "--foyer" in OS.get_cmdline_user_args():
		player.position = Vector3(5.4, 0.05, 7.7)
		player.rotation.y = PI
	scene.get_node("Hud").visible = false
	if "--capture-corridor" in OS.get_cmdline_user_args():
		await get_tree().create_timer(0.6).timeout
		await RenderingServer.frame_post_draw
		var name: String = "corridor-%s-%s.png" % ["upper" if upper else "ground", "night" if GameState.minutes > 1200 else "day"]
		if "--foyer" in OS.get_cmdline_user_args():
			name = "foyer-%s.png" % ("night" if GameState.minutes > 1200 else "day")
		var error: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + name)
		print("CORRIDOR REVIEW: SAVED" if error == OK else "FAIL: corridor capture")
		get_tree().quit(0 if error == OK else 1)
