extends Node
## Developer tool: renders the game from viewpoints derived from the current
## HouseLayout (SINGLE-STOREY-AUDIT-001) and saves PNG files to
## docs/screenshots/. Needs a real window (do not run headless).
##
## It starts campaigns and answers the door, so it runs ONLY in an isolated
## project copy (tools/Run-Tests.ps1 -KeepProjectCopy, then
##   godot --path <copy>/project --resolution 1280x720 res://scenes/main/capture_screenshots.tscn
## ); against the real project it refuses and quits.

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const OUTPUT_DIR: String = "res://docs/screenshots"

## name, position, yaw (radians), pitch in degrees. An optional "room" opens
## that room's 2D view for the shot. The old stair and upper-corridor shots
## were retired with the single-storey plan.
static func shots() -> Array[Dictionary]:
	var entrance: Vector3 = ReviewSpots.inside_front_door(0.9)
	var door: Dictionary = ReviewSpots.front_door()
	var door_point := Vector3(float(door["x"]), 0.05, float(door["z"]))
	var hall: Vector3 = ReviewSpots.room_spot(&"hall")
	var landing: Vector3 = ReviewSpots.room_spot(&"landing")
	var corridor: Vector3 = ReviewSpots.room_spot(&"corridor")
	var window_point := Vector3(door_point.x - 1.5, 0.05, door_point.z)
	for wall: Dictionary in HouseLayout.WALLS:
		if wall["axis"] == "x" and is_equal_approx(float(wall["at"]), door_point.z):
			for opening: Dictionary in wall["openings"]:
				if opening.get("window", false):
					window_point = Vector3(float(opening["pos"]), 0.05, door_point.z)
	var at_door: Vector3 = ReviewSpots.inside_front_door(0.75)
	return [
		{"name": "01_hall_from_entrance", "position": entrance, "yaw": ReviewSpots.yaw_toward(entrance, hall), "pitch": -4.0},
		{"name": "02_entrance_window", "position": ReviewSpots.inside_front_door(1.6), "yaw": ReviewSpots.yaw_toward(ReviewSpots.inside_front_door(1.6), window_point), "pitch": -4.0},
		{"name": "03_hall_from_landing", "position": landing, "yaw": ReviewSpots.yaw_toward(landing, hall), "pitch": -10.0},
		{"name": "04_corridor_from_landing", "position": landing, "yaw": ReviewSpots.yaw_toward(landing, corridor), "pitch": -6.0},
		{"name": "06_living_room_actions", "position": hall, "yaw": 0.0, "pitch": 0.0, "room": &"living_room", "action": "watch_tv"},
		{"name": "07_elena_at_the_door", "position": at_door, "yaw": ReviewSpots.yaw_toward(at_door, door_point), "pitch": 0.0, "answer_door": true},
		{"name": "09_marcus_bed_choice", "position": at_door, "yaw": ReviewSpots.yaw_toward(at_door, door_point), "pitch": 0.0, "day2_bed_choice": true},
	]


func _ready() -> void:
	if not ReviewSpots.isolated(get_tree()):
		return
	var scene: Node = SCENE.instantiate()
	add_child(scene)
	var player := scene.get_node("Player") as PlayerController
	var room_view := scene.get_node("RoomView") as RoomView
	player.set_physics_process(false)
	var head := player.get_node("Head") as Node3D

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	for shot: Dictionary in shots():
		room_view.close()
		(scene.get_node("DialogueRunner") as DialogueRunner).cancel()
		player.global_position = shot["position"]
		player.rotation = Vector3(0.0, shot["yaw"], 0.0)
		head.rotation = Vector3(deg_to_rad(shot["pitch"]), 0.0, 0.0)
		for i: int in 4:
			await get_tree().physics_frame
		if shot.has("room"):
			room_view.open(shot["room"])
			if shot.has("action"):
				room_view.perform_action(shot["action"])
		if shot.get("answer_door", false):
			# Jump to the evening so Elena knocks, open the door, hear her out.
			GameState.advance_minutes(GameState.EVENING_START - GameState.minutes + 5)
			EventBus.front_door_used.emit()
			var runner := scene.get_node("DialogueRunner") as DialogueRunner
			runner.choose(0)
			runner.choose(0)
		if shot.get("day2_bed_choice", false):
			# Day 2 with Elena already living here: let Marcus in and reach the bed list.
			GameState.new_campaign(7)
			GameState.admit("elena_ward", "guest_a_1")
			GameState.start_next_day()
			GameState.advance_minutes(3 * 60)
			EventBus.front_door_used.emit()
			var day2_runner := scene.get_node("DialogueRunner") as DialogueRunner
			day2_runner.choose(0)
			day2_runner.choose(0)
			day2_runner.choose_by_id("admit")
		for i: int in 4:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		var path: String = "%s/%s.png" % [OUTPUT_DIR, shot["name"]]
		var error: Error = image.save_png(ProjectSettings.globalize_path(path))
		print("%s -> %s" % [path, error_string(error)])

	# Finally the title screen, on its own.
	scene.queue_free()
	var menu: Node = (load("res://scenes/main/main_menu.tscn") as PackedScene).instantiate()
	add_child(menu)
	for i: int in 4:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var menu_path: String = "%s/08_main_menu.png" % OUTPUT_DIR
	var menu_error: Error = get_viewport().get_texture().get_image().save_png(
		ProjectSettings.globalize_path(menu_path)
	)
	print("%s -> %s" % [menu_path, error_string(menu_error)])
	get_tree().quit(0)
