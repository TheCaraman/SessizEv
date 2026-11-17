extends Node
## Art-only porch camera (IMMERSION I-05): looks out from just outside the main
## door, roughly where the peephole is, with a wide lens. No campaign save.
##   --time=HHMM     clock (default 1100)
##   --outage        household power off
##   --fov=DEG       field of view (default 110)
##   --out=NAME.png  file under res://docs/qa/

func _ready() -> void:
	GameState.new_campaign(42)
	GameState.minutes = 660
	var file: String = "porch-review.png"
	var fov: float = 110.0
	var outage: bool = false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--time="):
			var hhmm: int = int(arg.trim_prefix("--time="))
			GameState.minutes = (hhmm / 100) * 60 + hhmm % 100
		elif arg.begins_with("--fov="):
			fov = float(arg.trim_prefix("--fov="))
		elif arg.begins_with("--out="):
			file = arg.trim_prefix("--out=")
		elif arg == "--outage":
			outage = true
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	player.control_enabled = false
	scene.get_node("Hud").visible = false
	var camera := Camera3D.new()
	camera.fov = fov
	camera.near = 0.03
	camera.position = Vector3(7.5, 1.55, 12.62)
	camera.rotation.y = PI
	camera.rotation.x = deg_to_rad(-6.0)
	add_child(camera)
	camera.make_current()
	if outage:
		GameState.power_incident = {"state": "outage", "cause": "grid_loss", "inspected": []}
		EventBus.time_changed.emit(GameState.day, GameState.minutes)
	await get_tree().create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	var error: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + file)
	print("PORCH REVIEW: SAVED" if error == OK else "FAIL: porch capture")
	get_tree().quit(0 if error == OK else 1)
