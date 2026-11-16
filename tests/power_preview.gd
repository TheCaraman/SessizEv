extends Node
func _ready() -> void:
	TranslationServer.set_locale("tr")
	GameState.new_campaign(15)
	GameState.day = 3
	GameState.minutes = 1370
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: Node3D = scene.get_node("Player")
	player.set_physics_process(false)
	player.position = Vector3(6, 0, 9.5)
	player.rotation.y = 0
	for i: int in 8:
		await get_tree().process_frame
	await shot("DAY3-001-before")
	GameState.advance_minutes(30)
	for i: int in 8:
		await get_tree().physics_frame
	await shot("DAY3-001-outage")
	var view: RoomView = scene.get_node("RoomView")
	view.open("utility")
	view.perform_action("power:panel")
	await shot("DAY3-001-evidence")
	view.close()
	scene._journal.open()
	scene._update_control()
	await shot("DAY3-001-journal")
	get_tree().quit()
func shot(id: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://docs/qa/" + id + ".png")
	print("WINDOW CAPTURE: " + id)
