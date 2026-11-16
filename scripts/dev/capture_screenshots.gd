extends Node
## Developer tool: renders the house blockout from fixed viewpoints and saves
## PNG files to docs/screenshots/. Needs a real window (do not run headless).
##
## Run with:
##   godot --path . --resolution 1280x720 res://scenes/main/capture_screenshots.tscn

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const OUTPUT_DIR: String = "res://docs/screenshots"

## name, position (x, y, z), yaw in degrees (positive turns left), pitch in degrees.
const SHOTS: Array[Dictionary] = [
	{"name": "01_vestibule_to_hall", "position": Vector3(6.0, 0.0, 9.6), "yaw": 0.0, "pitch": 0.0},
	{"name": "02_living_room", "position": Vector3(4.4, 0.0, 9.4), "yaw": 40.0, "pitch": -5.0},
	{"name": "03_dining_to_kitchen", "position": Vector3(0.8, 0.0, 0.8), "yaw": -100.0, "pitch": -5.0},
	{"name": "04_stairs_from_foot", "position": Vector3(7.6, 0.0, 8.3), "yaw": 0.0, "pitch": 20.0},
	{"name": "05_upper_corridor", "position": Vector3(6.0, 2.8, 8.2), "yaw": 0.0, "pitch": 0.0},
	{"name": "06_multipurpose_room", "position": Vector3(11.4, 2.8, 6.0), "yaw": 25.0, "pitch": -5.0},
]


func _ready() -> void:
	var scene: Node = SCENE.instantiate()
	add_child(scene)
	var player := scene.get_node("Player") as PlayerController
	player.control_enabled = false
	player.set_physics_process(false)
	var head := player.get_node("Head") as Node3D

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	for shot: Dictionary in SHOTS:
		player.global_position = shot["position"]
		player.rotation = Vector3(0.0, deg_to_rad(shot["yaw"]), 0.0)
		head.rotation = Vector3(deg_to_rad(shot["pitch"]), 0.0, 0.0)
		for i: int in 4:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		var image: Image = get_viewport().get_texture().get_image()
		var path: String = "%s/%s.png" % [OUTPUT_DIR, shot["name"]]
		var error: Error = image.save_png(ProjectSettings.globalize_path(path))
		print("%s -> %s" % [path, error_string(error)])
	get_tree().quit(0)
