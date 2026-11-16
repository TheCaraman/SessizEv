extends Node
func _ready() -> void:
	GameState.new_campaign(15)
	GameState.minutes = 540
	var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(session)
	session.get_node("Player").set_physics_process(false)
	var room: RoomView = session.get_node("RoomView")
	room.open("living_room")
	for frame: int in 30:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/first-room-approved.png")
	print("FIRST ROOM CAPTURE: " + str(result))
	get_tree().quit(0 if result == OK else 1)
