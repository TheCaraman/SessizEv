extends Node
## Developer tool: renders the game from fixed viewpoints and saves PNG files
## to docs/screenshots/. Needs a real window (do not run headless).
##
## Run with:
##   godot --path . --resolution 1280x720 res://scenes/main/capture_screenshots.tscn

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const OUTPUT_DIR: String = "res://docs/screenshots"

## name, position (x, y, z), yaw in degrees (positive turns left), pitch in
## degrees. An optional "room" opens that room's 2D view for the shot.
const SHOTS: Array[Dictionary] = [
	{"name": "01_hall_from_entrance", "position": Vector3(6.0, 0.0, 9.6), "yaw": 0.0, "pitch": -4.0},
	{"name": "02_hall_looking_south", "position": Vector3(6.0, 0.0, 3.4), "yaw": 180.0, "pitch": -6.0},
	{"name": "03_living_room_door", "position": Vector3(6.4, 0.0, 6.6), "yaw": 65.0, "pitch": 0.0},
	{"name": "04_upper_corridor", "position": Vector3(6.0, 2.8, 8.2), "yaw": 0.0, "pitch": -4.0},
	{"name": "05_landing_doors", "position": Vector3(7.6, 2.8, 2.6), "yaw": 60.0, "pitch": 0.0},
	{"name": "06_room_view_placeholder", "position": Vector3(6.4, 0.0, 6.6), "yaw": 65.0, "pitch": 0.0, "room": &"kitchen"},
]


func _ready() -> void:
	var scene: Node = SCENE.instantiate()
	add_child(scene)
	var player := scene.get_node("Player") as PlayerController
	var room_view := scene.get_node("RoomView") as RoomView
	player.set_physics_process(false)
	var head := player.get_node("Head") as Node3D

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	for shot: Dictionary in SHOTS:
		room_view.close()
		player.global_position = shot["position"]
		player.rotation = Vector3(0.0, deg_to_rad(shot["yaw"]), 0.0)
		head.rotation = Vector3(deg_to_rad(shot["pitch"]), 0.0, 0.0)
		for i: int in 4:
			await get_tree().physics_frame
		if shot.has("room"):
			room_view.open(shot["room"])
		for i: int in 4:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		var path: String = "%s/%s.png" % [OUTPUT_DIR, shot["name"]]
		var error: Error = image.save_png(ProjectSettings.globalize_path(path))
		print("%s -> %s" % [path, error_string(error)])
	get_tree().quit(0)
