extends SceneTree

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	if not str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")).begins_with("TheQuietHours-Tests/"):
		push_error("Use an isolated QA project/user directory")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/qa/lighting-review"))
	var state: Node = root.get_node("GameState")
	state.call("new_campaign", 42)
	state.set("day", 4)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	root.add_child(scene)
	current_scene = scene
	var player: Node3D = scene.get_node("Player")
	player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for child: Node in scene.get_children():
		if child.get_script() == load("res://scripts/ui/hud.gd"):
			child.hide()
	DisplayServer.window_set_size(Vector2i(1280, 720))
	var cases: Array[Dictionary] = [{"name": "morning", "time": 420, "power": true}, {"name": "day", "time": 720, "power": true}, {"name": "night", "time": 1380, "power": true}, {"name": "outage", "time": 1380, "power": false}]
	for point: String in ["entrance", "upper", "hall"]:
		player.position = Vector3(7.5, 3.35, 8.75) if point == "upper" else Vector3(7.25, 0.05, 9.3)
		player.rotation = Vector3(0.0, PI if point == "entrance" else 0.0, 0.0)
		player.get_node("Head").rotation.x = deg_to_rad(-4.0)
		for entry: Dictionary in cases:
			state.set("minutes", entry.time)
			state.set("power_incident", {} if entry.power else {"state": "outage", "cause": "grid_loss", "inspected": []})
			root.get_node("EventBus").emit_signal("time_changed", 4, entry.time)
			for frame: int in 12:
				await process_frame
			await RenderingServer.frame_post_draw
			var path: String = "res://docs/qa/lighting-review/light-%s-%s.png" % [point, entry.name]
			if root.get_texture().get_image().save_png(path) != OK:
				push_error("Capture failed: " + path)
				quit(1)
				return
	scene.queue_free()
	await process_frame
	await process_frame
	print("LIGHTING CAPTURE: PASS")
	quit()
