extends Node
## Native movie-mode review of the real production door and RoomView.
func _ready() -> void:
	if not str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")).begins_with("TheQuietHours-Tests/"):
		push_error("Use isolated QA user data")
		get_tree().quit(1)
		return
	GameState.new_campaign(42)
	GameState.day = 4
	GameState.minutes = 720
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	scene.get_node("Hud").visible = false
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	var door: RoomDoor = scene.find_child("Door_living_room", true, false)
	var room: RoomView = scene.get_node("RoomView")
	player.global_position = door.to_global(Vector3(0.0, 0.05, 1.3))
	player.global_rotation = Vector3(0.0, door.global_rotation.y, 0.0)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().create_timer(0.6).timeout
	door.interact(player)
	await get_tree().create_timer(1.1).timeout
	if not room.is_open() or room.get_room_id() != &"living_room":
		push_error("Door movie never reached living room")
		get_tree().quit(1)
		return
	room.close()
	await get_tree().create_timer(0.9).timeout
	print("SINGLE STOREY DOOR MOVIE: PASS")
	get_tree().quit(0)
