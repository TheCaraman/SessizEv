extends Node
## Real UI capture; allowed only in an isolated QA user directory.
func _ready() -> void:
	if not str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")).begins_with("TheQuietHours-Tests/"):
		push_error("Elena review requires isolated QA user data")
		get_tree().quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://docs/qa/elena-graphic")
	GameState.new_campaign(42)
	GameState.minutes = 1080
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	var front: RoomDoor
	for body: Node in scene.find_children("*", "StaticBody3D", true, false):
		if body is RoomDoor and body.is_front:
			front = body
	player.global_position = front.to_global(Vector3(0.0, 0.05, -1.2))
	player.get_node("Head/Camera3D").look_at(front.to_global(Vector3(0.0, 1.48, 0.0)), Vector3.UP)
	GameState.visitor = "elena_ward"
	var target: PeepholeInteraction = front.get_node("Peephole")
	target.interact(player)
	await _capture("doorstep")
	target.view.close()
	var runner: DialogueRunner = scene.get_node("DialogueRunner")
	runner.start("elena_arrival")
	runner.choose(0)
	await _capture("greeting")
	runner.choose(0)
	await _capture("questions")
	if not runner.choose_by_id("admit"):
		push_error("Review failed to admit via real authored dialogue")
		get_tree().quit(1)
		return
	while runner.is_active():
		runner.choose(0)
	scene.get_node("RoomView").open(&"guest_a")
	await _capture("resident")
	scene.get_node("RoomView").perform_action("talk:elena_ward")
	await _capture("resident-dialogue")
	print("ELENA REVIEW: PASS (5 actual UI captures)")
	get_tree().quit()

func _capture(label: String) -> void:
	for frame: int in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png("res://docs/qa/elena-graphic/%s.png" % label) != OK:
		push_error("Capture failed " + label)
		get_tree().quit(1)
