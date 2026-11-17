extends Node
var checks: int = 0
var failures: int = 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _ready() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	for mask: int in 8:
		GameState.new_campaign(42 + mask)
		GameState.day = 4
		var ids: Array[String] = ["elena_ward", "marcus_hale", "arthur_bell"]
		for index: int in 3:
			if mask & (1 << index):
				GameState.admit(ids[index], GameState.BEDS[index])
		GameState.resources["food"] = 0
		GameState.resources["water"] = 0
		GameState.resources["repair"] = 0
		var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
		viewport.add_child(scene)
		scene.get_node("Player").set_physics_process(false)
		var director: CampaignDirector = scene.get_node("CampaignDirector")
		var closure: Day4Closure = director.closure
		var view: RoomView = scene.get_node("RoomView")
		var journal: JournalView = scene.get("_journal")
		view.open("daniel_bedroom")
		check(not view.get_action_ids().has("day4:wait"), "review must be opened first")
		view.perform_action("review_last_night")
		journal.close()
		view.open("daniel_bedroom")
		check(view.get_action_ids().has("day4:defer") and view.get_action_ids().has("day4:wait"), "free defer and waiting available without resources")
		check(closure.actions("living_room").is_empty(), "closure only at Daniel room")
		var before: Dictionary = GameState.to_dict()
		view.perform_action("day4:defer")
		check(GameState.minutes == before["minutes"] and GameState.resources == before["resources"] and GameState.npcs == before["npcs"], "deferral has no cost or diagnosis")
		check(not view.get_action_ids().has("day4:defer"), "deferral one persisted marker")
		var deferred: Dictionary = GameState.to_dict()
		check(closure.perform("daniel_bedroom", "defer").is_empty() and GameState.to_dict() == deferred, "repeated deferral idempotent")
		if mask == 7:
			GameState.jobs[ids[0]] = {"job": "cooking", "day": 4, "start": 420, "end": 480, "room": "kitchen"}
			GameState.jobs[ids[1]] = {"job": "inventory", "day": 4, "start": 420, "end": 450, "room": "utility"}
			GameState.jobs[ids[2]] = {"job": "night_watch", "day": 4, "start": 420, "end": 420, "room": ""}
			var original: Dictionary = GameState.to_dict()
			var projected: Dictionary = original.duplicate(true)
			director.shelter.project_daytime(projected, 1200)
			check(GameState.to_dict() == original, "job projection never changes live state")
			check(projected["jobs"].size() == 1 and projected["jobs"].has(ids[2]), "night watch remains pending")
			check(projected["reports"].size() == 2 and projected["reports"][0]["minutes"] == 450 and projected["reports"][1]["minutes"] == 480, "projected jobs finish in chronological order")
			check(projected["flags"].get("meal_ready_day_4", false), "shared cooking reducer applies same meal flag")
		before = GameState.to_dict()
		view.perform_action("day4:wait")
		check(GameState.to_dict() == before and view.get_narration_text().contains(tr("D4_CLOSE_CONFIRM_WAIT")), "first wait press is reviewable free confirmation")
		view.close()
		view.open("daniel_bedroom")
		view.perform_action("day4:wait")
		check(GameState.to_dict() == before, "leaving room cancels wait confirmation")
		if mask == 7:
			check(SaveManager.save_game("closure_quote") == OK and SaveManager.load_game("closure_quote"), "save and reload during quote")
			view.perform_action("day4:wait")
			check(GameState.to_dict() == before, "load cancels identical-state quote")
			var pending: String = SaveManager.get_path_for(SaveManager.AUTOSAVE_SLOT) + ".pending"
			check(DirAccess.make_dir_absolute(pending) == OK, "owned save-failure fixture")
			view.perform_action("day4:wait")
			check(GameState.to_dict() == before, "failed wait save changes no clock jobs resources or reports")
			check(DirAccess.remove_absolute(pending) == OK, "remove owned save fixture")
			view.perform_action("day4:wait")
			check(GameState.to_dict() == before, "failed commit cancels quote")
		view.perform_action("day4:wait")
		check(GameState.day == 4 and GameState.minutes == 1200, "wait reaches evening without new day")
		check(GameState.resources == before["resources"] and GameState.player == before["player"] and GameState.npcs == before["npcs"], "waiting changes no resource energy trust infection or resident")
		if mask == 7:
			check(GameState.reports.size() == 2 and GameState.jobs.size() == 1, "reports completed exactly once before publication")
			var jobs_done: Dictionary = GameState.to_dict()
			director.shelter.resolve_finished_jobs()
			check(GameState.to_dict() == jobs_done, "time signals never double-complete projected jobs")
		check(view.get_action_ids().has("day4:complete") and not view.get_action_ids().has("day4:wait"), "evening offers completion")
		before = GameState.to_dict()
		view.perform_action("day4:complete")
		check(GameState.to_dict() == before, "completion first press free")
		if mask == 7:
			EvidenceManager.collect("closure_card", "POWER_CARD")
			before = GameState.to_dict()
			view.perform_action("day4:complete")
			check(GameState.to_dict() == before, "changed evidence invalidates prior completion quote")
		view.perform_action("day4:complete")
		check(GameState.get_flag("day4_review_completed") and GameState.get_flag("day4_review_completed_at") == 1200, "completion persisted at actual time")
		check(journal.visible and not view.is_open() and not scene.get_node("Player").control_enabled, "completion opens real summary modal")
		check(journal.text.text.contains(tr("D4_CLOSE_BUILD_LIMIT")), "slice boundary explicit")
		check(GameState.day == 4 and GameState.resources == before["resources"] and GameState.npcs == before["npcs"], "completion never removes person or consumes next day")
		var done: Dictionary = GameState.to_dict()
		check(SaveManager.save_game("closure_done") == OK and SaveManager.load_game("closure_done"), "completion save load")
		check(GameState.to_dict() == done, "load preserves closure exactly")
		var summary: String = Day4Review.summary()
		for id: String in Roster.get_ids():
			GameState.npcs[id]["infected"] = not GameState.npcs[id]["infected"]
		check(Day4Review.summary() == summary, "summary never reveals infection assignments")
		GameState.from_dict(done, false)
		for patch: Dictionary in [{"day4_review_completed": "yes"}, {"day4_review_completed_at": 1199}, {"day4_review_completed_at": 1300}, {"day4_review_completed_at": "1200"}]:
			var bad: Dictionary = done.duplicate(true)
			bad["flags"].merge(patch, true)
			check(not SaveManager._valid_state_shape(bad), "bad closure rejected " + str(patch))
		journal.close()
		view.open("daniel_bedroom")
		check(view.get_action_ids().has("day4:summary") and not view.get_action_ids().has("day4:complete"), "summary remains rereadable")
		view.perform_action("day4:summary")
		check(GameState.to_dict() == done, "summary reread free")
		if mask == 7:
			for locale: String in ["en", "tr"]:
				Settings.set_language(locale)
				journal.open(Day4Review.summary())
				for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]:
					viewport.size = resolution
					for frame: int in 3:
						await get_tree().process_frame
					var panel: Control = journal.find_child("JournalPanel", true, false)
					check(Rect2(Vector2.ZERO, Vector2(resolution)).encloses(panel.get_global_rect()), "summary modal fits " + locale + str(resolution))
					check(Rect2(Vector2.ZERO, Vector2(resolution)).encloses(journal._close_hint.get_global_rect()) and journal._close_hint.text == tr("JOURNAL_CLOSE_HINT").format({"key": InputSetup.get_key_label(&"journal")}), "visible localized close hint fits " + locale + str(resolution))
					check(not journal.text.text.contains("{resident}") and not journal.text.text.contains("D4_CLOSE_"), "summary localization " + locale)
					if "--capture-closure" in OS.get_cmdline_user_args() and resolution == Vector2i(1920, 1080):
						await RenderingServer.frame_post_draw
						check(viewport.get_texture().get_image().save_png("res://docs/qa/day4-closure-%s.png" % locale) == OK, "closure capture " + locale)
			var close := InputEventAction.new()
			close.action = &"pause"
			close.pressed = true
			viewport.push_input(close)
			var release := InputEventAction.new()
			release.action = &"pause"
			viewport.push_input(release)
			await get_tree().process_frame
			check(not journal.visible and scene.get_node("Player").control_enabled, "actual Escape action closes modal and restores exploration")
			view.open(GameState.get_location(ids[0]))
			view.perform_action("expel:" + ids[0])
			view.perform_action("expel:" + ids[0])
			check(GameState.get_status(ids[0]) == "expelled", "decisions remain possible after closure")
			check(Day4Review.summary() != summary and GameState.get_flag("day4_review_completed_at") == 1200, "current summary updates without rewriting completion time")
			view.close()
			view.open("daniel_bedroom")
			var no_night: Dictionary = GameState.to_dict()
			view.perform_action("sleep")
			check(GameState.to_dict() == no_night, "unwritten Day4 night never consumes resources or advances day")
		journal.close()
		view.close()
		scene.free()
		await get_tree().process_frame
	GameState.day = 3
	check(not Day4Review.available(), "other days cannot close review")
	viewport.free()
	Settings.set_language("en")
	await get_tree().process_frame
	if failures == 0:
		print("DAY4 CLOSURE TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
