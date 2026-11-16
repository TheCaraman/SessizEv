extends Node
func _ready() -> void:
	TranslationServer.set_locale("tr")
	GameState.new_campaign(42)
	GameState.day = 3
	GameState.minutes = 1200
	var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(session)
	var player: Node3D = session.get_node("Player")
	player.set_physics_process(false)
	player.position = Vector3(6, 0, 9.5)
	player.rotation.y = 0
	var room: RoomView = session.get_node("RoomView")
	room.open("daniel_bedroom")
	room.perform_action("watch")
	room.perform_action("watch")
	room.perform_action("wait_watch")
	await shot("night-watch-01-actions")
	room.close()
	room.open("living_room")
	await shot("night-watch-01-living")
	room.close()
	await shot("night-watch-01-corridor")
	get_tree().quit()
func shot(id: String) -> void:
	for frame: int in 60:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + id + ".png")
	print("NIGHT WATCH CAPTURE: %s %d" % [id, result])
