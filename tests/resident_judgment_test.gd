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
	for infected: bool in [false, true]:
		GameState.new_campaign(42)
		GameState.day = 4
		GameState.admit("elena_ward", "guest_a_1")
		GameState.npcs["elena_ward"]["infected"] = infected
		var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
		viewport.add_child(scene)
		scene.get_node("Player").set_physics_process(false)
		var view: RoomView = scene.get_node("RoomView")
		view.open("guest_a")
		var baseline: Dictionary = GameState.to_dict()
		check(view.get_action_ids().has("expel:elena_ward"), "adult in actual room offered")
		view.perform_action("expel:elena_ward")
		check(GameState.to_dict() == baseline and view.get_narration_text() == tr("JUDGMENT_EXPEL_CONFIRM").format({"name": Roster.get_display_name("elena_ward"), "minutes": 15}), "first click is free confirmation")
		if not infected:
			for locale: String in ["en", "tr"]:
				TranslationServer.set_locale(locale)
				for width: int in [1920, 2560]:
					viewport.size = Vector2i(width, width * 9 / 16)
					view.close()
					view.open("guest_a")
					view.perform_action("expel:elena_ward")
					for frame: int in 5:
						await get_tree().process_frame
					var bounds := Rect2(Vector2.ZERO, Vector2(viewport.size))
					check(bounds.encloses(view._narration_panel.get_global_rect()) and bounds.encloses(view._actions.get_global_rect()), "confirmation fits " + locale)
					if "--capture-judgment" in OS.get_cmdline_user_args():
						await RenderingServer.frame_post_draw
						check(viewport.get_texture().get_image().save_png("res://docs/qa/expel-confirmation-%s-%d.png" % [locale, width]) == OK, "confirmation capture")
		view.close()
		view.open("guest_a")
		view.perform_action("expel:elena_ward")
		check(GameState.to_dict() == baseline, "leaving cancels")
		GameState.minutes += 1
		view.perform_action("expel:elena_ward")
		check(GameState.get_status("elena_ward") == "resident", "changed clock needs new confirmation")
		view.perform_action("expel:elena_ward")
		check(GameState.get_status("elena_ward") == "expelled" and GameState.get_bed_of("elena_ward") == "", "confirmed adult leaves and frees bed")
		check(GameState.minutes == int(baseline["minutes"]) + 16 and GameState.resources == baseline["resources"], "time once and no supply refund")
		check(GameState.npcs["elena_ward"]["trust"] == int(baseline["npcs"]["elena_ward"]["trust"]) - 20 and GameState.npcs["elena_ward"]["infected"] == infected, "trust consequence without infection rewrite")
		check(view.get_narration_text().contains(tr("EXPEL_ELENA_LEAVES")), "authored departure line independent of infection")
		var after: Dictionary = GameState.to_dict()
		view.perform_action("expel:elena_ward")
		check(GameState.to_dict() == after, "repeat cannot charge twice")
		check(SaveManager.load_game() and GameState.get_status("elena_ward") == "expelled", "departure persisted")
		view.close()
		scene.free()
		await get_tree().process_frame
	GameState.new_campaign(42)
	GameState.day = 4
	GameState.admit("lily_reed", "guest_a_1")
	var judgment := ResidentJudgment.new()
	check(judgment.targets("guest_a").is_empty(), "child never offered")
	GameState.admit("marcus_hale", "guest_b_1")
	for unavailable: String in ["isolated", "absent", "injured", "incapacitated"]:
		GameState.npcs["marcus_hale"][unavailable] = true
		check(judgment.targets("guest_b").is_empty(), "unavailable target excluded " + unavailable)
		GameState.npcs["marcus_hale"].erase(unavailable)
	GameState.minutes = 1430
	var before: Dictionary = GameState.to_dict()
	check(judgment.expel("guest_b", "marcus_hale") == tr("POWER_TOO_LATE") and GameState.to_dict() == before, "late decision free refusal")
	GameState.minutes = 600
	GameState.jobs["marcus_hale"] = {"job": "inventory", "day": 4, "start": 590, "end": 610, "room": "pantry"}
	check(judgment.targets("guest_b").is_empty() and judgment.targets("pantry").has("marcus_hale"), "decision follows actual job location")
	judgment.expel("pantry", "marcus_hale")
	judgment.expel("pantry", "marcus_hale")
	check(not GameState.jobs.has("marcus_hale") and GameState.reports.is_empty() and GameState.completed_jobs.is_empty(), "interrupted work earns no report or output")
	for status: String in ["dead", "left", "expelled", "rejected", "unknown"]:
		GameState.npcs["marcus_hale"]["status"] = status
		check(judgment.targets("guest_b").is_empty(), "nonresident excluded " + status)
	GameState.new_campaign(42)
	GameState.day = 4
	GameState.admit("elena_ward", "guest_a_1")
	GameState.admit("marcus_hale", "guest_a_2")
	GameState.admit("arthur_bell", "guest_b_1")
	judgment.expel("guest_a", "elena_ward")
	var before_memory: Dictionary = GameState.to_dict()
	check(not GameState.flags.has(judgment.memory_key("marcus_hale", "elena_ward")), "confirmation alone creates no memory")
	var response: String = judgment.expel("guest_a", "elena_ward")
	check(response.contains(tr("EXPEL_ELENA_LEAVES")) and GameState.get_status("elena_ward") == "expelled", "departure speech belongs to actual decision")
	check(GameState.flags.get(judgment.memory_key("marcus_hale", "elena_ward"), false), "same-room listener remembers")
	check(not GameState.flags.has(judgment.memory_key("arthur_bell", "elena_ward")), "other room gets no telepathic knowledge")
	check(GameState.npcs["marcus_hale"]["trust"] == before_memory["npcs"]["marcus_hale"]["trust"], "memory alone has no hidden trust tax")
	check(SaveManager.load_game() and judgment.memories("guest_a").size() == 1, "listener memory survives load")
	var memory_state: Dictionary = GameState.to_dict()
	check(judgment.discuss("guest_a", "marcus_hale", "elena_ward").contains(tr("EXPEL_MARCUS_WITNESS").format({"name": Roster.get_display_name("elena_ward")})), "personal response to known departure")
	check(judgment.discuss("guest_b", "arthur_bell", "elena_ward") == "" and GameState.to_dict() == memory_state, "unknown or repeat topic gives no fabricated testimony or cost")
	var memory_scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	viewport.add_child(memory_scene)
	memory_scene.get_node("Player").set_physics_process(false)
	var memory_view: RoomView = memory_scene.get_node("RoomView")
	memory_view.open("guest_a")
	check(memory_view.get_action_ids().has("discuss_expulsion:marcus_hale:elena_ward"), "room exposes actual listener topic")
	memory_view.perform_action("discuss_expulsion:marcus_hale:elena_ward")
	check(memory_view.get_narration_text().contains(Roster.get_display_name("marcus_hale")), "real room response")
	for frame: int in 5:
		await get_tree().process_frame
	if "--capture-judgment" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png("res://docs/qa/expel-witness-tr-2560.png") == OK, "witness response capture")
	memory_view.close()
	memory_scene.free()
	await get_tree().process_frame
	SaveManager.delete_save()
	if failures == 0:
		print("RESIDENT JUDGMENT TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
