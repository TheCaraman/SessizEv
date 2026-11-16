extends Node
func _ready() -> void:
	TranslationServer.set_locale("tr")
	GameState.new_campaign(42)
	GameState.day = 3
	GameState.minutes = 1200
	var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(session)
	session.get_node("Player").set_physics_process(false)
	var room: RoomView = session.get_node("RoomView")
	room.open("daniel_bedroom")
	room.perform_action("watch")
	room.perform_action("watch")
	room.perform_action("wait_watch")
	await shot("night-pipes-heard")
	room.close()
	room.open("bathroom_upper")
	room.perform_action("inspect_pipes")
	await shot("night-pipes-source")
	room.close()
	session._journal.open()
	session._update_control()
	await shot("night-pipes-journal")
	get_tree().quit()
func shot(id: String) -> void:
	for frame: int in 6:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + id + ".png")
	print("HOUSE NIGHT CAPTURE: %s %d" % [id, result])
