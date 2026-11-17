extends Node
## CAMERA-CLIP-001 capture: stand with the back pressed into a wall corner at
## the stairs, widest FOV, and save what the walking camera sees. Art-free,
## no save or settings write. Run only in an isolated copy.
##   --spot=x,z,yaw_deg,pitch_deg,floor   push-back point (floor 0/1)
##   --fov=95  --out=NAME.png (under res://docs/qa/)

func _ready() -> void:
	GameState.new_campaign(42)
	GameState.minutes = 660
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	player.control_enabled = false
	scene.get_node("Hud").visible = false
	var camera: Camera3D = player.get_node("Head/Camera3D")
	var out: String = "camera-corner.png"
	var spot := PackedStringArray(["9.5", "6.0", "90", "0", "0"])
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--spot="):
			spot = arg.trim_prefix("--spot=").split(",")
		elif arg.begins_with("--out="):
			out = arg.trim_prefix("--out=")
	await get_tree().physics_frame
	await get_tree().physics_frame
	var yaw: float = deg_to_rad(float(spot[2]))
	player.rotation.y = yaw
	(player.get_node("Head") as Node3D).rotation.x = deg_to_rad(float(spot[3]))
	var floor_y: float = HouseLayout.floor_height(int(spot[4]))
	var here := Vector2(float(spot[0]), float(spot[1]))
	var lift: float = 0.5
	if int(spot[4]) == 0 and HouseLayout.STAIRS.has_point(here):
		lift += HouseLayout.STOREY_HEIGHT * (HouseLayout.STAIRS.end.y - here.y) / HouseLayout.STAIRS.size.y
	player.global_position = Vector3(here.x, floor_y + lift, here.y)
	player.move_and_collide(Vector3.DOWN * 1.0)
	# Walk backwards into the wall behind, then keep pressing.
	var back := Vector3(sin(yaw), 0.0, cos(yaw))
	for step: int in 90:
		player.velocity = back * player.fast_speed
		player.move_and_slide()
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--fov="):
			camera.fov = float(arg.trim_prefix("--fov="))
	print("CORNER camera at %s fov %.0f" % [camera.global_position, camera.fov])
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--door="):
			var wanted: StringName = StringName(arg.trim_prefix("--door="))
			for body: Node in scene.find_children("*", "StaticBody3D", true, false):
				if body is RoomDoor and (body as RoomDoor).room_id == wanted:
					(body as RoomDoor).interact(player)
			for shot: int in 6:
				await get_tree().create_timer(0.13).timeout
				await RenderingServer.frame_post_draw
				get_viewport().get_texture().get_image().save_png("res://docs/qa/" + out.trim_suffix(".png") + "-%d.png" % shot)
				print("CORNER door frame %d camera %s" % [shot, camera.global_position])
			get_tree().quit(0)
			return
	await get_tree().create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	var error: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + out)
	print("CORNER REVIEW: SAVED" if error == OK else "FAIL: corner capture")
	get_tree().quit(0 if error == OK else 1)
