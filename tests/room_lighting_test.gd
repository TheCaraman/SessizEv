extends Node
var checks: int = 0
var failures: int = 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
func _ready() -> void:
	GameState.new_campaign(42)
	GameState.day = 4
	GameState.minutes = 720
	var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(session)
	session.get_node("Player").set_physics_process(false)
	var room: RoomView = session.get_node("RoomView")
	var director: CampaignDirector = session.get_node("CampaignDirector")
	var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RoomVisuals.DATA_PATH))["living_room"]
	var cases: Array[Dictionary] = [{"variant": "day", "minutes": 720, "powered": true}, {"variant": "night", "minutes": 1380, "powered": true}, {"variant": "outage_day", "minutes": 720, "powered": false}, {"variant": "outage_night", "minutes": 1380, "powered": false}]
	for state: Dictionary in cases:
		GameState.minutes = state["minutes"]
		GameState.power_incident = {} if state["powered"] else {"state": "outage", "cause": "loose_connection", "inspected": []}
		room.open("living_room")
		EventBus.time_changed.emit(GameState.day, GameState.minutes)
		for frame: int in 4:
			await get_tree().process_frame
		check(room.get_visual_variant() == state["variant"], "authored variant " + state["variant"])
		check(room._background.texture.resource_path == definition[state["variant"]], "correct image selected")
		check(room._background.modulate == Color.WHITE, "authored lighting not darkened twice")
		check(room._title.modulate == Color.WHITE, "lighting never tints UI")
		check(room._background.texture.get_size() == Vector2(1672, 941), "matching source framing dimensions")
		check((room.get_prop_layer() as RoomProps).get_prop_ids().has("media_console"), "prop survives variant swap")
		var tint: Color = room.get_prop_layer().modulate
		EventBus.time_changed.emit(GameState.day, GameState.minutes)
		check(room.get_prop_layer().modulate == tint, "repeat event cannot compound tint")
		if "--capture-room-lighting" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			check(get_viewport().get_texture().get_image().save_png("res://docs/qa/living-lighting-%s.png" % state["variant"]) == OK, "capture saved")
	director.power.repair(true)
	check(room.get_visual_variant() == "night", "repair refreshes open room to powered night")
	var visuals := RoomVisuals.new()
	check(visuals.resolve("living_room", 1500, true)["variant"] == "night", "01:00 uses night variant")
	check(visuals.resolve("living_room", 1860, false)["variant"] == "outage_day", "07:00 unresolved outage uses daytime variant")
	room.open("utility")
	check(room.get_visual_variant() == "fallback", "unconverted rooms retain existing assets")
	check(room._background.modulate == room.get_prop_layer().modulate, "fallback keeps old world layer tint")
	session.free()
	if failures == 0:
		print("ROOM LIGHTING TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
