extends Node
var checks: int = 0
var failures: int = 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _ready() -> void:
	GameState.new_campaign(42)
	TranslationServer.set_locale("tr")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	viewport.add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	player.position = Vector3(6.4, 0.05, 7.5)
	player.rotation.y = deg_to_rad(90.0)
	var room: RoomView = scene.get_node("RoomView")
	var door: RoomDoor = scene.find_child("Door_living_room", true, false)
	check(door != null and door.has_node("Hinge/DoorLeaf"), "real hinged leaf")
	var before: Dictionary = GameState.to_dict()
	var camera: Camera3D = player.get_node("Head/Camera3D")
	var camera_before: Transform3D = camera.global_transform
	door.interact(player)
	door.interact(player)
	check(not player.control_enabled and not room.is_open(), "opening locks control before showing room")
	await get_tree().create_timer(0.3).timeout
	check(absf(door.get_node("Hinge").rotation.y) > 0.1 and not room.is_open(), "door visibly rotates before room")
	var threshold: MeshInstance3D = door.get_node("RoomThreshold")
	check(threshold.visible and threshold.material_override is ShaderMaterial, "physical opening uses screen-matched room preview")
	var preview_texture: Texture2D = threshold.material_override.get_shader_parameter("room_image")
	check(preview_texture != null and preview_texture.resource_path == RoomVisuals.new().resolve("living_room", GameState.minutes, true)["path"], "opening shows the actual room variant before fullscreen handoff")
	if "--capture-door" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png("res://docs/qa/door-opening.png") == OK, "opening image saved")
	await get_tree().create_timer(0.35).timeout
	if "--capture-door" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png("res://docs/qa/door-approaching.png") == OK, "approach image saved")
	await get_tree().create_timer(0.35).timeout
	check(room.is_open() and room.get_room_id() == "living_room" and not player.control_enabled, "opening resolves to correct room")
	check(camera.global_position.distance_to(camera_before.origin) < 0.001, "camera returns to original corridor position behind room view")
	check(not room._transition_cover.visible, "handoff adds no second black cover")
	if "--capture-door" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png("res://docs/qa/door-entered.png") == OK, "room handoff image saved")
	check(is_equal_approx(room._root.modulate.a, 1.0), "room fade finishes")
	var open_angle: float = absf(door.get_node("Hinge").rotation.y)
	room.close()
	check(player.control_enabled, "leaving the room returns control at once")
	check(door.is_closing() and absf(door.get_node("Hinge").rotation.y) > open_angle * 0.9, "door is still open when the corridor reappears")
	check(door.get_node("RoomThreshold").visible, "dark recess stays behind the open leaf while it closes")
	door.interact(player)
	check(not room.is_open() and player.control_enabled, "a closing door cannot be reopened mid-swing")
	await get_tree().create_timer(0.2).timeout
	var mid: float = absf(door.get_node("Hinge").rotation.y)
	check(mid > 0.01 and mid < open_angle, "leaf visibly swings shut")
	await get_tree().create_timer(RoomDoor.CLOSE_SECONDS).timeout
	check(not door.is_closing() and is_zero_approx(door.get_node("Hinge").rotation.y), "leaf ends fully closed")
	check(not door.get_node("RoomThreshold").visible and GameState.to_dict() == before, "threshold hides and transition consumes no campaign time")
	door.interact(player)
	check(not player.control_enabled, "a closed door can be opened again")
	await get_tree().create_timer(1.0).timeout
	check(room.is_open() and room.get_room_id() == "living_room", "reopening reaches the same room")
	room.close()
	await get_tree().create_timer(RoomDoor.CLOSE_SECONDS + 0.05).timeout
	door.interact(player)
	var escape := InputEventAction.new()
	escape.action = &"pause"
	escape.pressed = true
	door._unhandled_input(escape)
	check(player.control_enabled and not room.is_open() and not threshold.visible, "Escape cancels an opening without entering the room")
	await get_tree().create_timer(RoomDoor.OPEN_SECONDS + RoomDoor.APPROACH_SECONDS + 0.05).timeout
	check(not room.is_open() and camera.global_position.distance_to(camera_before.origin) < 0.001, "cancelled tween never enters room or leaves displaced camera")
	var motion: float = Settings.get_number("camera_motion")
	check(Settings.set_number("camera_motion", 0.0) == OK, "reduced motion preference persists")
	door.interact(player)
	await get_tree().create_timer(RoomDoor.OPEN_SECONDS + 0.1).timeout
	check(room.is_open() and camera.global_position.distance_to(camera_before.origin) < 0.001, "reduced motion opens room without moving camera")
	room.close()
	check(Settings.set_number("camera_motion", motion) == OK, "motion preference restored for other checks")
	scene.free()
	await get_tree().process_frame
	if failures == 0:
		print("DOOR TRANSITION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
