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
		GameState.new_campaign(42)
		GameState.day = 4
		var ids: Array[String] = ["elena_ward", "marcus_hale", "arthur_bell"]
		for i: int in 3:
			if mask & (1 << i):
				GameState.admit(ids[i], GameState.BEDS[i])
		var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
		viewport.add_child(scene)
		scene.get_node("Player").set_physics_process(false)
		var view: RoomView = scene.get_node("RoomView")
		var before: Dictionary = GameState.to_dict()
		view.open("daniel_bedroom")
		check(view.get_action_ids().has("review_last_night"), "review available for resident subset")
		view.perform_action("review_last_night")
		var journal: JournalView = scene.get("_journal")
		check(journal.visible and not view.is_open() and not scene.get_node("Player").control_enabled, "real modal controls")
		check(journal.text.text.contains(tr("DAY4_REVIEW_NO_RECORDS")), "missing evidence explicit")
		check(journal.text.text.contains(tr("DAY4_REVIEW_LEGACY")) and not journal.text.text.contains(tr("DAY4_REVIEW_INTRO")), "missing incident never invented")
		check(GameState.minutes == before["minutes"] and GameState.npcs == before["npcs"] and GameState.resources == before["resources"], "free review changes no people resources or time")
		check(GameState.flags.get("day4_reviewed", false), "review persisted")
		var after: Dictionary = GameState.to_dict()
		journal.close()
		check(scene.get_node("Player").control_enabled, "close returns control")
		view.open("daniel_bedroom")
		view.perform_action("review_last_night")
		check(GameState.to_dict() == after, "reread idempotent")
		if mask == 7:
			GameState.power_incident = {"state": "outage", "cause": "loose_connection", "inspected": []}
			check(Day4Review.text().contains(tr("DAY4_REVIEW_INTRO")), "recorded incident permits opening")
			EvidenceManager.collect("power_card", "POWER_CARD")
			for locale: String in ["en", "tr"]:
				TranslationServer.set_locale(locale)
				for width: int in [1920, 2560]:
					viewport.size = Vector2i(width, width * 9 / 16)
					journal.open(Day4Review.text())
					for frame: int in 5:
						await get_tree().process_frame
					check(journal.text.text.contains(tr("POWER_CARD")) and not journal.text.text.contains("saboteur"), "only collected evidence shown")
					if "--capture-review" in OS.get_cmdline_user_args():
						await RenderingServer.frame_post_draw
						check(viewport.get_texture().get_image().save_png("res://docs/qa/day4-review-%s-%d.png" % [locale, width]) == OK, "review image saved")
		journal.close()
		view.close()
		scene.free()
		await get_tree().process_frame
	GameState.day = 3
	check(not Day4Review.available() and Day4Review.record_open() == ERR_UNAVAILABLE, "other day rejected")
	SaveManager.delete_save()
	if failures == 0:
		print("DAY4 REVIEW TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
