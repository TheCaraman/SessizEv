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
	player.position = Vector3(6.1, 0.05, 6.0)
	player.rotation.y = deg_to_rad(90.0)
	var room: RoomView = scene.get_node("RoomView")
	var door: RoomDoor = scene.find_child("Door_living_room", true, false)
	check(door != null and door.has_node("Hinge/DoorLeaf"), "real hinged leaf")
	var before: Dictionary = GameState.to_dict()
	door.interact(player)
	door.interact(player)
	check(not player.control_enabled and not room.is_open(), "opening locks control before showing room")
	await get_tree().create_timer(0.3).timeout
	check(absf(door.get_node("Hinge").rotation.y) > 0.1 and not room.is_open(), "door visibly rotates before room")
	check(door.get_node("RoomThreshold").visible, "threshold has actual room image")
	if "--capture-door" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png("res://docs/qa/door-opening.png") == OK, "opening image saved")
	await get_tree().create_timer(0.7).timeout
	check(room.is_open() and room.get_room_id() == "living_room" and not player.control_enabled, "opening resolves to correct room")
	check(is_equal_approx(room._root.modulate.a, 1.0), "room fade finishes")
	room.close()
	check(player.control_enabled and is_zero_approx(door.get_node("Hinge").rotation.y), "close returns control and resets leaf")
	check(not door.get_node("RoomThreshold").visible and GameState.to_dict() == before, "threshold hides and transition consumes no campaign time")
	scene.free()
	await get_tree().process_frame
	if failures == 0:
		print("DOOR TRANSITION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
