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
	var director: CampaignDirector = scene.get_node("CampaignDirector")
	for resolution: Vector2i in [Vector2i(1920, 1080), Vector2i(2560, 1440)]:
		viewport.size = resolution
		for locale: String in ["en", "tr"]:
			TranslationServer.set_locale(locale)
			view.open("daniel_bedroom")
			view.perform_action("watch")
			for frame: int in 6:
				await get_tree().process_frame
			var confirm_bounds := Rect2(Vector2.ZERO, Vector2(resolution))
			check(confirm_bounds.encloses(view._narration_panel.get_global_rect()), "full watch confirmation fits " + locale)
			check(not GameState.night_in_progress(), "layout preview cannot confirm by accident")
			if "--capture-presentation" in OS.get_cmdline_user_args():
				await RenderingServer.frame_post_draw
				check(viewport.get_texture().get_image().save_png("res://docs/qa/watch-confirmation-%s-%d.png" % [locale, resolution.x]) == OK, "confirmation capture saved")
			view.close()
	check(director.night.begin_watch(), "presentation fixture starts actual watch")
	director.perform_room_action("daniel_bedroom", "wait_watch")
	check(GameState.minutes == 1500, "presentation fixture reaches actual 01:00")
	for resolution: Vector2i in [Vector2i(1920, 1080), Vector2i(2560, 1440)]:
		viewport.size = resolution
		for locale: String in ["en", "tr"]:
			TranslationServer.set_locale(locale)
			view.open("daniel_bedroom")
			view._set_narration(tr("WATCH_WAITED").format({"time": GameState.get_clock_text(), "energy": GameState.player["energy"]}))
			for frame: int in 6:
				await get_tree().process_frame
			var bounds := Rect2(Vector2.ZERO, Vector2(resolution))
			check(view.get_action_ids().has("wait_watch") and view.get_action_ids().has("sleep"), "night wait and sleep offered " + locale)
			for control: Control in view._actions.get_children():
				check(bounds.encloses(control.get_global_rect()), "night action fits " + locale + " " + control.text)
			check(bounds.encloses(view._narration_panel.get_global_rect()), "night narration fits " + locale)
			check(bounds.encloses(view._hint.get_global_rect()), "night leave hint fits " + locale)
			if "--capture-presentation" in OS.get_cmdline_user_args():
				await RenderingServer.frame_post_draw
				check(viewport.get_texture().get_image().save_png("res://docs/qa/night-actions-%s-%d.png" % [locale, resolution.x]) == OK, "night capture saved")
			view.close()
	view.open("living_room")
	check((view.get_prop_layer() as RoomProps).get_prop_ids() == PackedStringArray(["media_console"]), "living room loads authored media prop")
	view.open("kitchen")
	check((view.get_prop_layer() as RoomProps).get_prop_ids().is_empty(), "room changes clear prior props")
	var audio_refs: Array[WeakRef] = _audio_refs(scene)
	viewport.queue_free()
	await get_tree().process_frame
	if AudioServer.get_driver_name() != "Dummy":
		# AudioServer releases stopped voices on a later mix. Do not terminate
		# the process in the same frame as queued scene destruction.
		var deadline: int = Time.get_ticks_msec() + 1000
		while _has_live_audio(audio_refs) and Time.get_ticks_msec() < deadline:
			await get_tree().create_timer(0.02).timeout
		check(not _has_live_audio(audio_refs), "scene audio is released before test process exits")
	if failures == 0:
		print("PRESENTATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)

func _audio_refs(scene: Node) -> Array[WeakRef]:
	var refs: Array[WeakRef] = []
	for node: Node in scene.find_children("*", "AudioStreamPlayer3D", true, false):
		var player := node as AudioStreamPlayer3D
		if player.stream != null:
			refs.append(weakref(player.stream))
		if player.playing:
			var playback: AudioStreamPlayback = player.get_stream_playback()
			if playback != null:
				refs.append(weakref(playback))
	return refs

func _has_live_audio(refs: Array[WeakRef]) -> bool:
	for reference: WeakRef in refs:
		if reference.get_ref() != null:
			return true
	return false
