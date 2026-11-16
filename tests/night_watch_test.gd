extends Node
var checks: int = 0
var failures: int = 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
func _ready() -> void:
	for residents: int in [0, 3]:
		for sleep_after: int in [-1, 1, 3]:
			GameState.new_campaign(42)
			GameState.day = 3
			GameState.minutes = 1200
			var ids: Array[String] = ["elena_ward", "marcus_hale", "arthur_bell"]
			for index: int in residents:
				GameState.admit(ids[index], GameState.BEDS[index])
			var infections: Array[bool] = []
			for id: String in Roster.get_ids():
				infections.append(GameState.npcs[id]["infected"])
			var food: int = GameState.resources["food"]
			var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
			add_child(session)
			session.get_node("Player").set_physics_process(false)
			var director: CampaignDirector = session.get_node("CampaignDirector")
			var room: RoomView = session.get_node("RoomView")
			room.open("daniel_bedroom")
			check(room.get_action_ids().has("watch"), "watch offered in preparation")
			var before: Dictionary = GameState.to_dict()
			room.perform_action("watch")
			check(GameState.to_dict() == before, "watch first press is free confirmation")
			room.close()
			room.open("daniel_bedroom")
			room.perform_action("watch")
			check(GameState.to_dict() == before, "leaving cancels watch confirmation")
			room.perform_action("watch")
			check(GameState.night_in_progress() and GameState.minutes == 1380 and GameState.day == 3, "watch begins at 23 without day consumption")
			check(not director.power.is_powered() and not room.get_narration_text().contains("You wake up"), "awake incident has no false awakening")
			check(GameState.resources["food"] == food, "night starts without daily food cost")
			room.close()
			check(session.get_node("Player").control_enabled, "corridor movement available during watch")
			room.open("utility")
			room.perform_action("power:panel")
			check(GameState.minutes == 1390 and not GameState.evidence.is_empty(), "watch permits real investigation")
			room.close()
			room.open("daniel_bedroom")
			var waits: int = 4 if sleep_after == -1 else sleep_after
			for index: int in waits:
				room.perform_action("wait_watch")
				if GameState.day == 3:
					check(GameState.minutes == 1380 + (index + 1) * 120, "wait reaches exact boundary")
					check(GameState.resources["food"] == food, "boundary does not consume daily resources")
				var saved: Dictionary = GameState.to_dict()
				check(SaveManager.save_game("night_watch") == OK and SaveManager.load_game("night_watch"), "real scene night save/load")
				check(GameState.to_dict() == saved, "load does not reroll incident or charge energy")
			if sleep_after != -1:
				room.perform_action("sleep")
			check(GameState.day == 4 and GameState.minutes == 420, "morning reached")
			var expected_energy: int = 60 if sleep_after == -1 else (100 if sleep_after == 1 else 86)
			check(GameState.player["energy"] == expected_energy, "energy reflects actual sleep/watch minutes")
			check(GameState.resources["food"] == food - residents - 1, "one daily consumption for all residents")
			before = GameState.to_dict()
			check(not director.night.finish() and GameState.to_dict() == before, "morning cannot resolve twice")
			var after_infections: Array[bool] = []
			for id: String in Roster.get_ids():
				after_infections.append(GameState.npcs[id]["infected"])
			check(after_infections == infections, "watch never changes infection assignments")
			room.close()
			session.free()
			await get_tree().process_frame
	# A player who first slept and investigated can still choose to stay awake.
	GameState.new_campaign(42)
	GameState.day = 3
	GameState.minutes = 1200
	var late_session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(late_session)
	late_session.get_node("Player").set_physics_process(false)
	var late_room: RoomView = late_session.get_node("RoomView")
	late_room.open("daniel_bedroom")
	late_room.perform_action("sleep")
	late_room.close()
	late_room.open("utility")
	for action: String in ["power:panel", "power:access", "power:outside"]:
		late_room.perform_action(action)
	var incident_before: Dictionary = GameState.power_incident.duplicate(true)
	late_room.close()
	late_room.open("daniel_bedroom")
	check(GameState.minutes == 1400 and late_room.get_action_ids().has("watch"), "late watch offered after twenty minutes investigation")
	late_room.perform_action("watch")
	late_room.perform_action("watch")
	check(GameState.minutes == 1400 and GameState.player["energy"] == 100, "late choice adds no retroactive time or energy")
	check(GameState.night_session["start_minute"] == 1400 and GameState.power_incident == incident_before, "late watch records real start and preserves incident")
	late_room.perform_action("wait_watch")
	check(GameState.minutes == 1500 and GameState.player["energy"] == 92, "first late interval charges actual hundred minutes")
	check(SaveManager.save_game("night_watch") == OK and SaveManager.load_game("night_watch"), "late watch loads through v5 validation")
	for step: int in 3:
		late_room.perform_action("wait_watch")
	check(GameState.day == 4 and GameState.player["energy"] == 62 and GameState.resources["food"] == 11, "remaining watch resolves once without fictitious earlier fatigue")
	late_room.close()
	late_session.free()
	SaveManager.delete_save("night_watch")
	if failures == 0:
		print("NIGHT WATCH TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
