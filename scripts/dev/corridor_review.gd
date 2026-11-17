extends Node
## Art-only real corridor camera. No campaign save or day resolution.
## Run only in an isolated project copy (ReviewSpots.isolated).
##   default        just inside the front door, facing into the house
##   --foyer        the entrance seen from the hall, facing the front door
##   --upper        retired: the single-storey plan has no upper floor
##   --night        21:30 instead of 11:00
##   --view=x,y,z,yaw_deg,pitch_deg,file_name   free camera (y = body height)
##   --capture-corridor   save under res://docs/qa/ and quit

func _ready() -> void:
	if not ReviewSpots.isolated(get_tree()):
		return
	if "--upper" in OS.get_cmdline_user_args() and not ReviewSpots.has_floor(1):
		get_tree().quit(1)
		return
	GameState.new_campaign(42)
	GameState.minutes = 660
	if "--night" in OS.get_cmdline_user_args():
		GameState.minutes = 1350
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	player.control_enabled = false
	var entrance: Vector3 = ReviewSpots.inside_front_door(1.0)
	player.position = entrance
	player.rotation.y = ReviewSpots.yaw_toward(entrance, ReviewSpots.room_spot(&"hall"))
	if "--foyer" in OS.get_cmdline_user_args():
		var hall: Vector3 = ReviewSpots.room_spot(&"hall")
		player.position = hall
		player.rotation.y = ReviewSpots.yaw_toward(hall, entrance)
	scene.get_node("Hud").visible = false
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
		var name: String = "corridor-ground-%s.png" % ("night" if GameState.minutes > 1200 else "day")
		if "--foyer" in OS.get_cmdline_user_args():
			name = "foyer-%s.png" % ("night" if GameState.minutes > 1200 else "day")
		if custom_name != "":
			name = custom_name
		var error: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + name)
		print("CORRIDOR REVIEW: SAVED" if error == OK else "FAIL: corridor capture")
		get_tree().quit(0 if error == OK else 1)
