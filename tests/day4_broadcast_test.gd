extends Node
var checks: int = 0
var failures: int = 0
var viewport: SubViewport
var scene: Node
var room: RoomView
var director: CampaignDirector
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)
func build(residents: int = 0) -> void:
	GameState.new_campaign(42)
	GameState.day = 4
	var ids: Array[String] = ["elena_ward", "marcus_hale", "arthur_bell"]
	for index: int in residents:
		GameState.admit(ids[index], GameState.BEDS[index])
	scene = load("res://scenes/main/house_blockout.tscn").instantiate()
	viewport.add_child(scene)
	scene.get_node("Player").set_physics_process(false)
	room = scene.get_node("RoomView")
	director = scene.get_node("CampaignDirector")
func dispose() -> void:
	room.close()
	scene.free()
func _ready() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	for residents: int in [0, 3]:
		for outage: bool in [false, true]:
			for memory_known: bool in [false, true]:
				for infection: String in ["healthy", "infected"]:
					build(residents)
					GameState.player["infection"] = infection
					if outage:
						GameState.power_incident = {"state": "outage", "cause": "grid_loss", "inspected": []}
					if memory_known:
						GameState.flags["heard_memory_loss_report"] = true
						GameState.flags["radio_day_4"] = true
					var before: Dictionary = GameState.to_dict()
					check(not Day4Review.summary().contains(tr("RADIO_D4_EVACUATION_CLAIM")), "unheard broadcast is not invented in summary")
					check(director.day4_broadcast.duration() == 15, "legacy radio flag does not skip new report")
					room.open("living_room")
					room.perform_action("radio")
					check(GameState.minutes == 435 and GameState.day == 4, "actual radio action costs fifteen minutes")
					check(GameState.npcs == before["npcs"] and GameState.resources == before["resources"] and GameState.player == before["player"], "no person supplies energy or infection changed")
					check(room.get_narration_text().contains(tr("RADIO_D4_EVACUATION")), "evacuation fragment received even without power or residents")
					check(room.get_narration_text().contains(tr("RADIO_D2_MEMORY_LOSS")) == not memory_known, "missed memory-loss report retains alternative path")
					check(GameState.get_flag("heard_memory_loss_report") and GameState.get_flag(Day4Broadcast.HEARD), "both learned reports recorded")
					check(GameState.evidence.size() == 1 and GameState.evidence[0]["kind"] == "claim", "broadcast content is claim not verified destination")
					check(GameState.get_flag(Day4Broadcast.AT) == 435 and Day4Review.summary().contains(tr("RADIO_D4_EVACUATION_CLAIM")), "summary knows only after actual receipt")
					check(Accusation.basis(GameState.to_dict()).is_empty(), "evacuation message is not person-specific accusation basis")
					var saved: Dictionary = GameState.to_dict()
					room.perform_action("radio")
					check(GameState.to_dict() == saved and room.get_narration_text().begins_with(tr("RADIO_D4_NOTES")), "notes reread is free and not a new transmission")
					check(SaveManager.save_game("radio4") == OK and SaveManager.load_game("radio4"), "actual radio save load")
					check(GameState.to_dict() == saved and director.day4_broadcast.duration() == 0, "reload preserves learned content and cost")
					dispose()
					await get_tree().process_frame
	build(3)
	room.open("living_room")
	var before: Dictionary = GameState.to_dict()
	var pending: String = SaveManager.get_path_for(SaveManager.AUTOSAVE_SLOT) + ".pending"
	check(DirAccess.make_dir_absolute(pending) == OK, "owned failure fixture")
	room.perform_action("radio")
	check(GameState.to_dict() == before and room.get_narration_text() == tr("NARR_SAVE_FAILED"), "failed save costs nothing and teaches no broadcast")
	check(DirAccess.remove_absolute(pending) == OK, "remove owned fixture")
	GameState.jobs["elena_ward"] = {"job": "inventory", "day": 4, "start": 420, "end": 425, "room": "pantry"}
	room.perform_action("radio")
	check(GameState.reports.size() == 1 and GameState.reports[0]["minutes"] == 425 and not GameState.jobs.has("elena_ward"), "other job completion saved with listening")
	var saved: Dictionary = GameState.to_dict()
	for patch: Dictionary in [{"day4_evacuation_heard": "yes"}, {"day4_evacuation_heard_at": "435"}, {"day4_evacuation_heard_at": 1900}, {"day4_evacuation_heard_at": 430}, {"day4_radio_included_memory": "yes"}, {"heard_memory_loss_report": false}]:
		var broken: Dictionary = saved.duplicate(true)
		broken["flags"].merge(patch, true)
		check(not SaveManager._valid_state_shape(broken), "corrupt report state rejected " + str(patch))
	check(is_same(Day4Broadcast._rules(), Day4Broadcast._rules()) and Day4Broadcast._rules() == JSON.parse_string(FileAccess.get_file_as_string(Day4Broadcast.RULES)), "radio rules read once into class cache and match data file")
	check(saved["flags"][Day4Broadcast.AT] == GameState.DAY_START + 15 and SaveManager._valid_state_shape(saved), "earliest report minute measured from day start is valid")
	var orphan: Dictionary = saved.duplicate(true)
	orphan["flags"].erase(Day4Broadcast.HEARD)
	check(not SaveManager._valid_state_shape(orphan), "orphan claim rejected")
	orphan = saved.duplicate(true)
	orphan["evidence"].clear()
	check(not SaveManager._valid_state_shape(orphan), "heard flag requires real stored claim")
	for locale: String in ["en", "tr"]:
		Settings.set_language(locale)
		room.close()
		room.open("living_room")
		room.perform_action("radio")
		check(room._title.text == tr("ROOM_LIVING") and room._hint.text.contains(tr("ROOMVIEW_LEAVE").get_slice("—", 1).strip_edges()), "localized room heading and leave hint " + locale)
		for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]:
			viewport.size = resolution
			for frame: int in 3:
				await get_tree().process_frame
			var bounds := Rect2(Vector2.ZERO, Vector2(resolution))
			check(bounds.encloses(room._narration_panel.get_global_rect()), "radio narration fits " + locale + str(resolution))
			for button: Control in room._actions.get_children():
				check(bounds.encloses(button.get_global_rect()), "radio action fits " + locale + str(resolution))
			if "--capture-radio4" in OS.get_cmdline_user_args() and resolution == Vector2i(1920, 1080):
				await RenderingServer.frame_post_draw
				check(viewport.get_texture().get_image().save_png("res://docs/qa/day4-radio-%s.png" % locale) == OK, "radio capture " + locale)
	dispose()
	await get_tree().process_frame
	build()
	GameState.minutes = 1430
	before = GameState.to_dict()
	room.open("living_room")
	room.perform_action("radio")
	check(GameState.to_dict() == before, "insufficient time never gives partial knowledge")
	GameState.minutes = 1200
	Day4Review.record_open()
	room.close()
	room.open("daniel_bedroom")
	room.perform_action("day4:complete")
	room.perform_action("day4:complete")
	check(GameState.get_flag("day4_review_completed") and not GameState.get_flag(Day4Broadcast.HEARD, false), "missed radio never blocks closure")
	scene.get("_journal").close()
	room.open("living_room")
	room.perform_action("radio")
	check(GameState.get_flag("day4_review_completed_at") == 1200 and GameState.get_flag(Day4Broadcast.HEARD), "optional discovery still possible after review closure")
	dispose()
	await get_tree().process_frame
	build()
	GameState.day = 3
	GameState.minutes = 1200
	room.open("daniel_bedroom")
	room.perform_action("sleep")
	room.perform_action("sleep")
	check(GameState.day == 4 and not room.get_narration_text().contains(tr("NARR_END_OF_BUILD")), "real Day3 transition no longer falsely ends before Day4")
	check(room.get_narration_text().contains(tr("RADIO_D4_MORNING_GUIDE")), "morning points to authored review and radio")
	room.close()
	room.open("living_room")
	room.perform_action("radio")
	check(GameState.get_flag(Day4Broadcast.HEARD), "fresh campaign radio path reached after actual night")
	room.close()
	room.open("daniel_bedroom")
	room.perform_action("review_last_night")
	scene.get("_journal").close()
	room.open("daniel_bedroom")
	room.perform_action("day4:wait")
	room.perform_action("day4:wait")
	room.perform_action("day4:complete")
	room.perform_action("day4:complete")
	check(GameState.day == 4 and GameState.get_flag("day4_review_completed"), "real night radio review wait closure form a reachable chain")
	scene.get("_journal").close()
	dispose()
	viewport.free()
	Settings.set_language("en")
	await get_tree().process_frame
	if failures == 0:
		print("DAY4 RADIO TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
