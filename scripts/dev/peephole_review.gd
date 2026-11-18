extends Node
## Art-only capture of the real peephole view (IMMERSION I-05). No save, no
## settings write. Opens the entrance door's PeepholeView exactly as the
## player does and saves the screen.
##   --time=HHMM    clock (default 1100)
##   --visitor=ID   who waits at the door (default nobody)
##   --outage       household power off
##   --out=NAME.png file under res://docs/qa/

## Runs the full campaign session (CampaignDirector, power, arrivals), whose
## time and power paths can autosave, so it runs ONLY in an isolated project
## copy (tools/Run-Tests.ps1 -KeepProjectCopy) and refuses otherwise
## (DEV-HELPER-GUARDS-001).
func _ready() -> void:
	if not ReviewSpots.isolated(get_tree()):
		return
	GameState.new_campaign(42)
	GameState.minutes = 660
	var file: String = "peephole-review.png"
	var outage: bool = false
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--time="):
			var hhmm: int = int(arg.trim_prefix("--time="))
			GameState.minutes = (hhmm / 100) * 60 + hhmm % 100
		elif arg.begins_with("--visitor="):
			GameState.visitor = arg.trim_prefix("--visitor=")
		elif arg.begins_with("--out="):
			file = arg.trim_prefix("--out=")
		elif arg == "--outage":
			outage = true
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	scene.get_node("Hud").visible = false
	if outage:
		GameState.power_incident = {"state": "outage", "cause": "grid_loss", "inspected": []}
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	var front: RoomDoor
	for body: Node in scene.find_children("*", "StaticBody3D", true, false):
		if body is RoomDoor and body.is_front:
			front = body
	await get_tree().process_frame
	(front.get_node("Peephole") as PeepholeInteraction).interact(player)
	await get_tree().create_timer(0.8).timeout
	await RenderingServer.frame_post_draw
	var error: Error = get_viewport().get_texture().get_image().save_png("res://docs/qa/" + file)
	print("PEEPHOLE REVIEW: SAVED" if error == OK else "FAIL: peephole capture")
	get_tree().quit(0 if error == OK else 1)
