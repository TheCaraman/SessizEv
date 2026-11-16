extends Node
var checks: int = 0
var failures: int = 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _ready() -> void:
	GameState.new_campaign(42)
	GameState.day = 3
	GameState.minutes = 1200
	GameState.admit("elena_ward", "guest_a_1")
	GameState.admit("marcus_hale", "guest_b_1")
	for id: String in Roster.get_ids():
		GameState.npcs[id]["infected"] = false
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	viewport.add_child(session)
	session.get_node("Player").set_physics_process(false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var director: CampaignDirector = session.get_node("CampaignDirector")
	var room: RoomView = session.get_node("RoomView")
	var witness: NightWitness = director.night.witness
	room.open("daniel_bedroom")
	room.perform_action("watch")
	room.perform_action("watch")
	check(GameState.get_flag(NightWitness.PROTOCOL) == true, "fresh night opts in")
	check(witness.propose(1500).is_empty(), "no witness before pipe event")
	room.perform_action("wait_watch")
	check(GameState.minutes == 1500 and GameState.get_flag("night_pipes_day3_heard"), "real pipe event precedes wake")
	var before: Dictionary = GameState.to_dict()
	var proposal: Dictionary = witness.propose(1620)
	check(not proposal.is_empty() and NightObservation.valid_completed(proposal), "actual house route produces trip")
	if proposal.is_empty():
		get_tree().quit(1)
		return
	check(GameState.to_dict() == before, "proposal never mutates state")
	check(witness.propose(1502).is_empty(), "whole trip must fit wait")
	check(NightWitness.new().propose(1620).is_empty(), "unwired producer cannot invent access")
	GameState.flags.erase(NightWitness.PROTOCOL)
	check(witness.propose(1620).is_empty(), "legacy night not backfilled")
	GameState.set_flag(NightWitness.PROTOCOL, true)
	room.close()
	check(witness.propose(1620).is_empty(), "visible corridor blocks offscreen trip")
	room.open("daniel_bedroom")
	for flag: String in ["isolated", "absent", "injured", "incapacitated", "busy"]:
		GameState.npcs["marcus_hale"][flag] = true
		check(witness.propose(1620).is_empty(), "unavailable participant " + flag)
		GameState.npcs["marcus_hale"].erase(flag)
	for status: String in ["dead", "expelled", "unknown", "left"]:
		GameState.npcs["marcus_hale"]["status"] = status
		check(witness.propose(1620).is_empty(), "missing participant " + status)
	GameState.npcs["elena_ward"]["status"] = "unknown"
	check(witness.propose(1620).is_empty(), "empty shelter cannot invent participants")
	GameState.npcs["elena_ward"]["status"] = "resident"
	GameState.npcs["marcus_hale"]["status"] = "resident"
	GameState.npcs["marcus_hale"]["blocked_rooms"] = ["bathroom_upper"]
	check(witness.propose(1620).is_empty(), "resident access restriction respected")
	GameState.npcs["marcus_hale"].erase("blocked_rooms")
	GameState.jobs["marcus_hale"] = {"job": "night_watch", "day": 3, "start": 1200, "end": 1200, "room": ""}
	check(witness.propose(1620).is_empty(), "watcher not simultaneously a sleeper")
	GameState.jobs.clear()
	var bathroom: RoomDoor = session.find_child("Door_bathroom_upper", true, false)
	bathroom.locked = true
	check(witness.propose(1620).is_empty(), "actual locked door blocks route")
	bathroom.locked = false
	var obstacle := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(3.0, 2.5, 0.4)
	collider.shape = shape
	obstacle.add_child(collider)
	obstacle.position = Vector3(7.5, 4.55, 6.5)
	session.add_child(obstacle)
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(witness.propose(1620).is_empty(), "real obstacle blocks route or sight")
	obstacle.free()
	await get_tree().physics_frame
	var healthy: Dictionary = witness.propose(1620)
	GameState.player["infection"] = "infected"
	check(witness.propose(1620) == healthy, "player infection never changes witness event")
	GameState.player["infection"] = "healthy"
	GameState.npcs["elena_ward"]["infected"] = true
	check(witness.propose(1620) == healthy, "infection never changes trip")
	GameState.npcs["elena_ward"]["infected"] = false
	var people: Dictionary = GameState.npcs.duplicate(true)
	room.perform_action("wait_watch")
	var record: Dictionary = GameState.get_flag(NightWitness.RECORD, {})
	check(record == healthy, "live wait publishes actual measured record")
	check(GameState.npcs == people, "everyone returns without infection change")
	check(GameState.evidence.size() == before["evidence"].size(), "private witness is not Daniel knowledge")
	check(witness.propose(1740).is_empty(), "record cannot reroll")
	var saved: Dictionary = GameState.to_dict()
	check(SaveManager.save_game("witness") == OK and SaveManager.load_game("witness"), "real save and load")
	check(GameState.to_dict() == saved, "exact record and timeline survive load")
	var malformed: Dictionary = saved.duplicate(true)
	malformed["evidence"].append({"id": "bad", "args": "bad"})
	check(not SaveManager._valid_state_shape(malformed), "save rejects non-dictionary evidence formatting args")
	malformed = saved.duplicate(true)
	malformed["flags"]["night_pipes_day3_minute"] = 1859
	check(not SaveManager._valid_state_shape(malformed), "observer cannot awaken before cause exists")
	for field: String in ["observer_steps", "snapshot", "observation"]:
		var broken: Dictionary = record.duplicate(true)
		broken[field] = [] if field == "observer_steps" else {}
		check(not NightObservation.valid_completed(broken), "production proof rejected " + field)
		var candidate: Dictionary = saved.duplicate(true)
		candidate["flags"][NightWitness.RECORD] = broken
		check(not SaveManager._valid_state_shape(candidate), "save rejects broken record " + field)
	room.perform_action("sleep")
	check(GameState.day == 4, "night reaches next morning")
	check(GameState.get_flag(NightWitness.RECORD) == record, "morning retains history")
	var observer: String = record["observer"]
	var subject: String = record["subject"]
	room.close()
	room.open(GameState.get_location(observer))
	check(room.get_action_ids().has("witness:observer"), "observer interview in actual room")
	check(not room.get_action_ids().has("witness:clarify"), "clarification needs both accounts")
	var expected: Dictionary = GameState.to_dict()
	var pending: String = SaveManager.get_path_for(SaveManager.AUTOSAVE_SLOT) + ".pending"
	check(DirAccess.make_dir_absolute(pending) == OK, "owned write failure fixture")
	witness.interview(GameState.get_location(observer), "observer")
	check(GameState.to_dict() == expected, "failed save adds no cost or claim")
	check(DirAccess.remove_absolute(pending) == OK, "remove owned failure fixture")
	room.perform_action("witness:observer")
	check(GameState.minutes == expected["minutes"] + 10 and GameState.get_flag("witness_interview_observer"), "interview costs ten minutes once")
	check(EvidenceManager.journal_text().contains(Roster.get_display_name(subject)), "journal formats named claim")
	check(GameState.evidence[-1]["kind"] == "claim", "testimony is claim not proof")
	var minute: int = GameState.minutes
	room.perform_action("witness:observer")
	check(GameState.minutes == minute, "reread free")
	room.close()
	room.open(GameState.get_location(subject))
	room.perform_action("witness:subject")
	check(room.get_action_ids().has("witness:clarify"), "conflicting accounts unlock clarification")
	room.perform_action("witness:clarify")
	check(GameState.get_flag("witness_interview_clarify") and GameState.evidence[-1]["key"] == "WITNESS_CLARIFY", "fear explanation saved as claim")
	for locale: String in ["en", "tr"]:
		Settings.set_language(locale)
		room.close()
		room.open(GameState.get_location(subject))
		room.perform_action("witness:clarify")
		check(not room.get_narration_text().contains("{subject}") and not room.get_narration_text().contains("WITNESS_CLARIFY"), "localized account " + locale)
		check(not str(witness.actions(GameState.get_location(subject))).contains("10.0"), "whole minute labels " + locale)
		for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]:
			viewport.size = resolution
			for frame: int in 3:
				await get_tree().process_frame
			var bounds := Rect2(Vector2.ZERO, Vector2(resolution))
			check(bounds.encloses(room._narration_panel.get_global_rect()), "narration fits " + locale + str(resolution))
			for button: Control in room._actions.get_children():
				check(bounds.encloses(button.get_global_rect()), "action fits " + locale + str(resolution))
			if "--capture-witness" in OS.get_cmdline_user_args() and resolution == Vector2i(1920, 1080):
				await RenderingServer.frame_post_draw
				check(viewport.get_texture().get_image().save_png("res://docs/qa/witness-%s.png" % locale) == OK, "capture " + locale)
	GameState.remove_npc(observer, "expelled")
	check(witness.actions(GameState.get_location(observer)).is_empty(), "expelled observer cannot speak")
	check(GameState.get_flag(NightWitness.RECORD) == record, "expulsion retains history")
	check(SaveManager.save_game("witness_after") == OK, "historical absence does not break save")
	room.close()
	viewport.free()
	Settings.set_language("en")
	await get_tree().process_frame
	if failures == 0:
		print("NIGHT WITNESS TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
