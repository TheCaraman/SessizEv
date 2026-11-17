extends Node
var checks: int = 0
var failures: int = 0
var viewport: SubViewport
var scene: Node
var room: RoomView
var controller: Accusation
var panel: AccusationView
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func build(day: int = 4) -> void:
	GameState.new_campaign(42)
	GameState.day = day
	GameState.minutes = 1200 if day == 3 else 420
	GameState.admit("elena_ward", "guest_a_1")
	GameState.admit("marcus_hale", "guest_b_1")
	GameState.admit("arthur_bell", "multipurpose_1")
	scene = load("res://scenes/main/house_blockout.tscn").instantiate()
	viewport.add_child(scene)
	scene.get_node("Player").set_physics_process(false)
	room = scene.get_node("RoomView")
	controller = scene.get_node("CampaignDirector").accusation
	panel = scene.get("_accusation")
func dispose() -> void:
	room.close()
	scene.free()
func _ready() -> void:
	viewport = SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	for target: String in ["elena_ward", "marcus_hale", "arthur_bell"]:
		for infected: bool in [false, true]:
			build()
			GameState.npcs[target]["infected"] = infected
			room.open(GameState.get_location(target))
			var before: Dictionary = GameState.to_dict()
			room.perform_action("accuse:" + target)
			check(panel.visible and viewport.gui_get_focus_owner() == panel._cancel, "explicit modal defaults to cancel")
			check(GameState.to_dict() == before, "opening accusation is free")
			panel._confirm.pressed.emit()
			check(panel._offer.get("unsupported") == true and GameState.to_dict() == before, "empty selection is unsupported free quote")
			var esc := InputEventAction.new()
			esc.action = &"pause"
			esc.pressed = true
			viewport.push_input(esc)
			var release := InputEventAction.new()
			release.action = &"pause"
			viewport.push_input(release)
			check(not panel.visible and room.is_open() and GameState.to_dict() == before, "Escape cancels modal without closing room")
			room.perform_action("accuse:" + target)
			panel._confirm.pressed.emit()
			panel._confirm.pressed.emit()
			check(not panel.visible and GameState.minutes == 430 and GameState.npcs[target]["trust"] == -5, "first explicit accusation applies ten minutes and trust once")
			check(GameState.npcs[target]["infected"] == infected and GameState.get_status(target) == "resident", "accusation never diagnoses removes or infects")
			var record: Dictionary = GameState.get_flag(Accusation.RECORDS)[target]
			check(record["unsupported"] and record["basis_ids"].is_empty(), "unsupported accusation stored honestly")
			check(GameState.evidence[-1]["kind"] == "claim" and GameState.evidence[-1]["key"] == "ACC_CLAIM_UNSUPPORTED", "accusation is a claim")
			check(room.get_narration_text() == controller.response(target), "individual response returns in same room")
			var after: Dictionary = GameState.to_dict()
			room.perform_action("accuse:" + target)
			check(GameState.to_dict() == after, "reread never repeats costs")
			check(SaveManager.save_game("accusation") == OK and SaveManager.load_game("accusation"), "real save and load")
			check(GameState.to_dict() == after, "nested records restore exactly")
			dispose()
			await get_tree().process_frame
	build()
	var target: String = "elena_ward"
	var origin: String = GameState.get_location(target)
	check(controller.quote(origin, "lily_reed", []).is_empty(), "protected child never target")
	for status: String in ["dead", "expelled", "left", "unknown"]:
		GameState.npcs[target]["status"] = status
		check(controller.quote(origin, target, []).is_empty(), "unavailable target " + status)
	GameState.npcs[target]["status"] = "resident"
	for flag: String in ["injured", "absent", "incapacitated", "busy"]:
		GameState.npcs[target][flag] = true
		check(controller.quote(origin, target, []).is_empty(), "unable to speak " + flag)
		GameState.npcs[target].erase(flag)
	GameState.jobs[target] = {"job": "night_watch", "day": 4, "start": 420, "end": 420, "room": ""}
	check(not controller.quote(origin, target, []).is_empty(), "future night-watch assignment does not block daytime conversation")
	GameState.jobs[target] = {"job": "inventory", "day": 4, "start": 420, "end": 480, "room": "utility"}
	check(controller.quote("utility", target, []).is_empty(), "active worker not simultaneously interrogated")
	GameState.jobs.clear()
	EvidenceManager.collect("acc_card", "POWER_CARD")
	check(controller.quote(origin, target, ["unknown"]).is_empty(), "invented basis refused")
	check(controller.quote(origin, target, ["acc_card", "acc_card"]).is_empty(), "duplicate basis refused")
	check(controller.quote(origin, target, ["acc_card"])["unsupported"], "general physical evidence does not identify a person")
	room.open(origin)
	room.perform_action("accuse:" + target)
	panel._checks["acc_card"].button_pressed = true
	var visited: Array[Control] = []
	panel._cancel.grab_focus()
	for press: int in 3:
		var tab := InputEventKey.new()
		tab.keycode = KEY_TAB
		tab.physical_keycode = KEY_TAB
		tab.pressed = true
		viewport.push_input(tab)
		var key_up := InputEventKey.new()
		key_up.keycode = KEY_TAB
		key_up.physical_keycode = KEY_TAB
		viewport.push_input(key_up)
		await get_tree().process_frame
		var focused: Control = viewport.gui_get_focus_owner()
		check(focused != null and panel.is_ancestor_of(focused), "real Tab stays in accusation modal")
		if focused not in visited:
			visited.append(focused)
	check(visited.size() == 3, "Tab reaches selection cancel and confirm")
	panel._confirm.pressed.emit()
	var before: Dictionary = GameState.to_dict()
	panel._checks["acc_card"].button_pressed = false
	check(panel._offer.is_empty() and GameState.to_dict() == before, "selection change cancels quote")
	panel._confirm.pressed.emit()
	GameState.resources["food"] += 1
	before = GameState.to_dict()
	panel._confirm.pressed.emit()
	check(GameState.to_dict() == before and panel._offer.is_empty(), "stale state cannot commit")
	panel._confirm.pressed.emit()
	var pending: String = SaveManager.get_path_for(SaveManager.AUTOSAVE_SLOT) + ".pending"
	check(DirAccess.make_dir_absolute(pending) == OK, "owned write failure fixture")
	panel._confirm.pressed.emit()
	check(GameState.to_dict() == before and panel.visible, "failed write adds no time trust claim or decision")
	check(DirAccess.remove_absolute(pending) == OK, "remove owned failure fixture")
	panel._confirm.pressed.emit()
	check(SaveManager.save_game("acc_quote") == OK and SaveManager.load_game("acc_quote"), "load during quote")
	check(not panel.visible and GameState.to_dict() == before, "loading cancels modal and quote")
	GameState.minutes = 1430
	check(controller.quote(origin, target, []).is_empty(), "no partial cost when day has less than ten minutes")
	GameState.minutes = 420
	GameState.npcs[target]["trust"] = -100
	GameState.npcs[target]["isolated"] = true
	GameState.flags["isolation_ready"] = true
	GameState.jobs["marcus_hale"] = {"job": "inventory", "day": 4, "start": 420, "end": 425, "room": "utility"}
	var isolated: Dictionary = controller.quote("isolation", target, [])
	check(not isolated.is_empty() and controller.commit(isolated) == OK, "isolated resident may answer at isolation door")
	check(GameState.npcs[target]["trust"] == -100 and GameState.get_location(target) == "isolation", "trust floor and isolation preserved")
	check(not GameState.jobs.has("marcus_hale") and GameState.reports[-1]["minutes"] == 425, "other completed task published with accusation time")
	dispose()
	await get_tree().process_frame
	build(3)
	# Actual fresh night supplies the person-specific observation, not a fake fixture.
	GameState.remove_npc("arthur_bell", "unknown")
	await get_tree().physics_frame
	await get_tree().physics_frame
	room.open("daniel_bedroom")
	room.perform_action("watch")
	room.perform_action("watch")
	room.perform_action("wait_watch")
	room.perform_action("wait_watch")
	room.perform_action("sleep")
	var night: Dictionary = GameState.get_flag(NightWitness.RECORD, {})
	check(not night.is_empty() and GameState.day == 4, "real night creates historical subject")
	if night.is_empty():
		get_tree().quit(1)
		return
	scene.get_node("CampaignDirector").night.witness.interview(GameState.get_location(night["observer"]), "observer")
	target = night["subject"]
	origin = GameState.get_location(target)
	check(not controller.quote(origin, target, ["witness_observer"])["unsupported"], "real selected witness claim linked to its subject")
	check(controller.quote(GameState.get_location(night["observer"]), night["observer"], ["witness_observer"])["unsupported"], "witness claim cannot be attached to different target")
	room.close()
	room.open(origin)
	room.perform_action("accuse:" + target)
	panel._checks["witness_observer"].button_pressed = true
	for locale: String in ["en", "tr"]:
		Settings.set_language(locale)
		panel._confirm.pressed.emit()
		check(not panel._offer["unsupported"] and panel._status.text.contains(tr("ACC_TESTIMONY_LIMIT")), "witness limitation explicit " + locale)
		for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]:
			viewport.size = resolution
			for frame: int in 3:
				await get_tree().process_frame
			var bounds := Rect2(Vector2.ZERO, Vector2(resolution))
			for control: Control in [panel._panel, panel._confirm, panel._cancel, panel._status]:
				check(bounds.encloses(control.get_global_rect()), "modal fits " + locale + str(resolution))
			if "--capture-accusation" in OS.get_cmdline_user_args() and resolution == Vector2i(1920, 1080):
				await RenderingServer.frame_post_draw
				check(viewport.get_texture().get_image().save_png("res://docs/qa/accusation-%s.png" % locale) == OK, "capture " + locale)
		panel._offer = {}
	panel._confirm.pressed.emit()
	var selected_quote: Dictionary = panel._offer.duplicate(true)
	before = GameState.to_dict()
	panel._confirm.pressed.emit()
	check(GameState.minutes == before["minutes"] + 10 and not GameState.get_flag(Accusation.RECORDS)[target]["unsupported"], "supported movement claim records without diagnosis")
	check(GameState.evidence[-1]["key"] == "ACC_CLAIM_TESTIMONY", "journal preserves limits of testimony")
	check(controller.commit(selected_quote) != OK, "same old quote cannot apply twice")
	var saved: Dictionary = GameState.to_dict()
	for patch: Dictionary in [{"basis_ids": ["not_found"]}, {"unsupported": true}, {"trust_after": 99}, {"completed_at": 1900}, {"target": "lily_reed"}]:
		var broken: Dictionary = saved.duplicate(true)
		broken["flags"][Accusation.RECORDS][target].merge(patch, true)
		check(not SaveManager._valid_state_shape(broken), "semantic accusation corruption rejected " + str(patch))
	GameState.remove_npc(target, "expelled")
	check(SaveManager.save_game("acc_history") == OK and not controller.targets(origin).has(target), "historical accusation survives expulsion without new speech")
	dispose()
	viewport.free()
	Settings.set_language("en")
	await get_tree().process_frame
	if failures == 0:
		print("ACCUSATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
