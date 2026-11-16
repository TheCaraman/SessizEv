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
		GameState.admit("marcus_hale", "guest_b_1")
		GameState.npcs["elena_ward"]["infected"] = infected
		var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
		viewport.add_child(scene)
		scene.get_node("Player").set_physics_process(false)
		var view: RoomView = scene.get_node("RoomView")
		var supplies: Dictionary = GameState.resources.duplicate()
		view.open("isolation")
		var before: Dictionary = GameState.to_dict()
		var expected_trust: int = int(before["npcs"]["elena_ward"]["trust"]) - 10
		view.perform_action("isolation:prepare")
		check(GameState.to_dict() == before, "prepare confirmation free")
		view.perform_action("isolation:prepare")
		check(GameState.get_flag("isolation_ready", false) and GameState.resources["repair"] == int(supplies["repair"]) - 1 and GameState.minutes == 450, "preparation paid once")
		check(GameState.get_headcount() == 3 and GameState.get_location("elena_ward") == "guest_a", "preparing alone moves nobody")
		view.close()
		view.open("guest_a")
		view.perform_action("isolation:place:elena_ward")
		view.close()
		view.open("guest_a")
		view.perform_action("isolation:place:elena_ward")
		check(GameState.get_location("elena_ward") == "guest_a", "exit cancels placement")
		view.perform_action("isolation:place:elena_ward")
		check(GameState.get_location("elena_ward") == "isolation" and GameState.get_room_occupants("guest_a").is_empty(), "one physical location")
		check(GameState.get_bed_of("elena_ward") == "guest_a_1" and GameState.get_headcount() == 3 and GameState.get_residents().size() == 2, "bed reserved and consumption unchanged")
		check(GameState.npcs["elena_ward"]["infected"] == infected and GameState.npcs["elena_ward"]["trust"] == expected_trust, "no infection change and first trust cost")
		var shelter: ShelterManager = scene.get_node("ShelterManager")
		check(shelter.why_refuses("elena_ward", "inventory")["key"] == "ISO_PLAN_LOCKED", "isolated worker refuses")
		var plan: Dictionary = shelter.get_current_plan()
		plan["beds"]["elena_ward"] = "guest_a_2"
		check(shelter.check_plan(plan)["key"] == "ISO_PLAN_LOCKED", "reserved bed cannot move")
		check(SaveManager.save_game("isolation_test") == OK and SaveManager.load_game("isolation_test"), "isolated state roundtrip")
		GameState.beds.erase("guest_a_1")
		check(SaveManager.save_game("isolation_test") == ERR_INVALID_DATA and SaveManager.load_game("isolation_test") and GameState.get_bed_of("elena_ward") == "guest_a_1", "missing reservation refused without overwriting valid save")
		GameState.npcs["marcus_hale"]["isolated"] = true
		check(SaveManager.save_game("isolation_test") == ERR_INVALID_DATA and SaveManager.load_game("isolation_test"), "two occupants refused")
		var management: ShelterView = scene.get_node("ShelterView")
		management.open()
		check(management.get_all_text().contains(tr("ISO_RESERVED").format({"name": Roster.get_display_name("elena_ward")})), "management labels reservation")
		management.cancel()
		if not infected:
			for locale: String in ["en", "tr"]:
				TranslationServer.set_locale(locale)
				for width: int in [1920, 2560]:
					viewport.size = Vector2i(width, width * 9 / 16)
					view.close()
					view.open("isolation")
					view.perform_action("isolation:release:elena_ward")
					for frame: int in 5:
						await get_tree().process_frame
					var bounds := Rect2(Vector2.ZERO, Vector2(viewport.size))
					check(bounds.encloses(view._narration_panel.get_global_rect()) and bounds.encloses(view._actions.get_global_rect()), "release confirmation fits " + locale)
					if "--capture-isolation" in OS.get_cmdline_user_args():
						await RenderingServer.frame_post_draw
						check(viewport.get_texture().get_image().save_png("res://docs/qa/isolation-%s-%d.png" % [locale, width]) == OK, "isolation capture")
		view.close()
		view.open("guest_b")
		check(not view.get_action_ids().has("isolation:place:marcus_hale"), "second occupant refused")
		view.close()
		view.open("isolation")
		check(view.get_action_ids().has("expel:elena_ward"), "isolated adult can still be expelled")
		view.perform_action("isolation:release:elena_ward")
		view.perform_action("isolation:release:elena_ward")
		check(GameState.get_location("elena_ward") == "guest_a" and GameState.minutes == 475, "release restores reserved location after ten minutes")
		view.close()
		view.open("guest_a")
		view.perform_action("isolation:place:elena_ward")
		view.perform_action("isolation:place:elena_ward")
		check(GameState.npcs["elena_ward"]["trust"] == expected_trust and GameState.minutes == 490, "repeat placement costs time not repeated trust")
		view.close()
		view.open("isolation")
		view.perform_action("expel:elena_ward")
		view.perform_action("expel:elena_ward")
		check(GameState.get_status("elena_ward") == "expelled" and not GameState.npcs["elena_ward"]["isolated"] and GameState.get_bed_of("elena_ward") == "", "expulsion clears occupant and reservation")
		check(SaveManager.save_game("isolation_test") == OK, "post-isolation departure valid")
		view.close()
		scene.free()
		await get_tree().process_frame
	GameState.new_campaign(42)
	GameState.day = 4
	GameState.resources["repair"] = 0
	var isolation := Isolation.new()
	var before: Dictionary = GameState.to_dict()
	check(isolation.perform("isolation", "prepare") == tr("ISO_NO_MATERIALS") and GameState.to_dict() == before, "no materials no costs")
	SaveManager.delete_save("isolation_test")
	SaveManager.delete_save()
	if failures == 0:
		print("ISOLATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
