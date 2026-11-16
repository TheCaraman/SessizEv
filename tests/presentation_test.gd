extends Node

var checks: int = 0
var failures: int = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)

func _ready() -> void:
	GameState.new_campaign(15)
	GameState.day = 3
	GameState.minutes = 1380
	GameState.admit("marcus_hale", "guest_a_1")
	GameState.power_incident = {"state": "outage", "cause": "loose_connection", "inspected": []}
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	viewport.add_child(scene)
	scene.get_node("Player").set_physics_process(false)
	var view: RoomView = scene.get_node("RoomView")
	for resolution: Vector2i in [Vector2i(1920, 1080), Vector2i(2560, 1440)]:
		viewport.size = resolution
		for locale: String in ["en", "tr"]:
			TranslationServer.set_locale(locale)
			view.open("utility")
			view.perform_action("power:card")
			for frame: int in 6:
				await get_tree().process_frame
			check(view._root.size == Vector2(resolution), "actual UI viewport " + str(resolution))
			check(view.get_action_ids().size() == 7, "all utility choices retained " + locale)
			var clock_text: String = scene.get_node("Hud").get_clock_text()
			check(clock_text == tr("HUD_CLOCK").format({"day": GameState.day, "time": GameState.get_clock_text(), "phase": tr("PHASE_NIGHT")}), "HUD follows locale " + locale)
			var bounds := Rect2(Vector2.ZERO, Vector2(resolution))
			for control: Control in view._actions.get_children():
				check(bounds.encloses(control.get_global_rect()), "button fits viewport " + locale + " " + control.text)
			check(bounds.encloses(view._narration_panel.get_global_rect()), "narration fits " + locale)
			check(bounds.encloses(view._hint.get_global_rect()), "leave hint fits " + locale)
			if "--capture-presentation" in OS.get_cmdline_user_args():
				await RenderingServer.frame_post_draw
				var path: String = "res://docs/qa/presentation-%s-%d.png" % [locale, resolution.x]
				check(viewport.get_texture().get_image().save_png(path) == OK, "capture saved")
			view.close()
	viewport.queue_free()
	if failures == 0:
		print("PRESENTATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
