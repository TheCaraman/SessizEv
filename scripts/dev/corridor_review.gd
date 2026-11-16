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
	player.position = Vector3(6.875, 3.35, 9.6) if upper else Vector3(6.875, 0.05, 10.25)
	player.rotation.y = 0.0
	if "--foyer" in OS.get_cmdline_user_args():
		player.position = Vector3(6.75, 0.05, 9.6)
		player.rotation.y = PI
	scene.get_node("Hud").visible = false
	# Optional free camera for close-ups of props:
	#   --view=x,y,z,yaw_deg,pitch_deg,file_name   (y is eye height above the floor plane)
	var custom_name: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--view="):
			var parts: PackedStringArray = arg.trim_prefix("--view=").split(",")
			player.position = Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
			player.rotation.y = deg_to_rad(float(parts[3]))
			(player.get_node("Head") as Node3D).rotation.x = deg_to_rad(float(parts[4]))
			custom_name = parts[5]
	if "--capture-corridor" in OS.get_cmdline_user_args():
		await get_tree().create_timer(0.6).timeout
		await RenderingServer.frame_post_draw
		var name: String = "corridor-%s-%s.png" % ["upper" if upper else "ground", "night" if GameState.minutes > 1200 else "day"]
		if "--foyer" in OS.get_cmdline_user_args():
			name = "foyer-%s.png" % ("night" if GameState.minutes > 1200 else "day")
		if custom_name != "":
			name = custom_name
		var error: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + name)
		print("CORRIDOR REVIEW: SAVED" if error == OK else "FAIL: corridor capture")
		get_tree().quit(0 if error == OK else 1)
