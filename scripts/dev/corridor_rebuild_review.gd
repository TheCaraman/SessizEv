extends Node
## Actual house review from four standard player-camera positions.
func _ready() -> void:
	if not str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")).begins_with("TheQuietHours-Tests/"):
		push_error("Use isolated QA user data")
		get_tree().quit(1)
		return
	DirAccess.make_dir_recursive_absolute("res://docs/qa/single-storey")
	GameState.new_campaign(42)
	GameState.day = 4
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scene.get_node("Hud").visible = false
	# Prove the actual main-scene opening orientation, before any review camera move.
	for frame: int in 12:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if get_viewport().get_texture().get_image().save_png("res://docs/qa/single-storey/opening-view-morning.png") != OK:
		push_error("Opening view capture failed")
		get_tree().quit(1)
		return
	var points: Array[Dictionary] = [
		{"id": "entry", "at": Vector3(7.0, 0.05, 11.0), "yaw": 0.0, "pitch": 0.0},
		{"id": "living-door", "at": Vector3(7.1, 0.05, 10.2), "yaw": 90.0, "pitch": 0.0},
		{"id": "corner", "at": Vector3(7.0, 0.05, 4.25), "yaw": -90.0, "pitch": 0.0},
		{"id": "quiet-wing", "at": Vector3(14.0, 0.05, 4.25), "yaw": 90.0, "pitch": 0.0}
	]
	var cases: Array[Dictionary] = [
		{"id": "day", "time": 720, "power": true},
		{"id": "night", "time": 1380, "power": true},
		{"id": "outage", "time": 1380, "power": false}
	]
	for point: Dictionary in points:
		player.global_position = point["at"]
		player.rotation.y = deg_to_rad(point["yaw"])
		player.get_node("Head").rotation.x = deg_to_rad(point["pitch"])
		for state: Dictionary in cases:
			GameState.minutes = state["time"]
			GameState.power_incident = {} if state["power"] else {"state": "outage", "cause": "grid_outage", "inspected": []}
			EventBus.time_changed.emit(GameState.day, GameState.minutes)
			for frame: int in 12:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var path: String = "res://docs/qa/single-storey/%s-%s.png" % [point["id"], state["id"]]
			if get_viewport().get_texture().get_image().save_png(path) != OK:
				push_error("Capture failed: " + path)
				get_tree().quit(1)
				return
	print("CORRIDOR REBUILD REVIEW: PASS (13 actual camera captures)")
	get_tree().quit()
