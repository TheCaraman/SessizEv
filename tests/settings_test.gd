extends Node
var checks: int = 0
var failures: int = 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.new_campaign(42)
	var campaign: Dictionary = GameState.to_dict()
	check(Settings.restore_defaults() == OK, "defaults persist")
	for key: String in Settings.DEFAULTS:
		check(is_equal_approx(Settings.get_number(key), Settings.DEFAULTS[key]), "default " + key)
	var disk: String = FileAccess.get_file_as_string(Settings.PATH)
	for value: Variant in [true, "1.2", null, NAN, INF, -1.0, 900.0]:
		check(Settings.set_number("brightness", value) == ERR_INVALID_PARAMETER, "invalid preference refused")
	check(Settings.set_number("unknown", 1.0) == ERR_INVALID_PARAMETER, "unknown preference refused")
	check(FileAccess.get_file_as_string(Settings.PATH) == disk, "refusal leaves preference file intact")
	check(Settings.set_number("brightness", 1.35) == OK, "brightness saved")
	check(Settings.set_number("mouse_sensitivity", 0.0044) == OK, "sensitivity saved")
	check(Settings.set_number("fov", 90.0) == OK, "FOV saved")
	var master: int = AudioServer.get_bus_index(&"Master")
	check(Settings.set_number("master_volume", 0.35) == OK, "volume saved")
	check(is_equal_approx(AudioServer.get_bus_volume_linear(master), 0.35), "live Master gain follows preference")
	check(Settings.set_number("master_volume", 0.0) == OK and AudioServer.is_bus_mute(master), "zero volume is fully muted")
	check(Settings.set_number("master_volume", 1.01) == ERR_INVALID_PARAMETER and AudioServer.is_bus_mute(master), "invalid volume does not unmute")
	Settings.load_preferences()
	check(AudioServer.is_bus_mute(master) and Settings.get_number("master_volume") == 0.0, "mute survives reload")
	check(Settings.set_number("master_volume", 0.35) == OK and not AudioServer.is_bus_mute(master), "raising volume unmutes")
	check(Settings.set_language("tr") == OK, "language write preserves numeric values")
	Settings.load_preferences()
	check(Settings.language == "tr" and is_equal_approx(Settings.get_number("brightness"), 1.35), "mixed preferences survive reload")
	check(is_equal_approx(Settings.get_number("mouse_sensitivity"), 0.0044) and is_equal_approx(Settings.get_number("fov"), 90.0), "controls survive reload")
	check(is_equal_approx(Settings.get_number("master_volume"), 0.35), "language write preserves volume")
	check(GameState.to_dict() == campaign, "preferences never change campaign state")
	var legacy := ConfigFile.new()
	legacy.set_value("interface", "language", "tr")
	legacy.save(Settings.PATH)
	Settings.load_preferences()
	check(Settings.language == "tr", "language-only legacy file migrates")
	for key: String in Settings.DEFAULTS:
		check(is_equal_approx(Settings.get_number(key), Settings.DEFAULTS[key]), "legacy default " + key)
	legacy.set_value("preferences", "brightness", true)
	legacy.set_value("preferences", "fov", 1000)
	legacy.set_value("preferences", "mouse_sensitivity", "bad")
	legacy.save(Settings.PATH)
	Settings.load_preferences()
	for key: String in Settings.DEFAULTS:
		check(is_equal_approx(Settings.get_number(key), Settings.DEFAULTS[key]), "malformed preference uses safe default " + key)
	Settings.restore_defaults()
	Settings.set_language("en")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	session.process_mode = Node.PROCESS_MODE_PAUSABLE
	viewport.add_child(session)
	var player: PlayerController = session.get_node("Player")
	player.set_physics_process(false)
	var menu: MainMenu = load("res://scenes/main/main_menu.tscn").instantiate()
	viewport.add_child(menu)
	menu.find_child("SettingsButton", true, false).pressed.emit()
	var panel: SettingsView = menu._settings
	check(panel.visible and not get_tree().paused, "title settings opens without pausing a campaign")
	panel._sliders["brightness"].value = 1.35
	panel._sliders["mouse_sensitivity"].value = 0.0044
	panel._sliders["fov"].value = 90.0
	panel._sliders["master_volume"].value = 0.25
	check(is_equal_approx(AudioServer.get_bus_volume_linear(master), 0.25), "volume slider edits actual audio gain")
	check(panel._readouts["master_volume"].text == "25%", "volume readout uses percentage")
	check(is_equal_approx(Settings.get_number("brightness"), 1.35), "brightness slider edits its own setting")
	check(is_equal_approx(player.mouse_sensitivity, 0.0044), "live player sensitivity updates")
	check(is_equal_approx(player.get_node("Head/Camera3D").fov, 90.0), "live FOV updates")
	check(is_equal_approx(session.get_node("RetroPostProcess")._material.get_shader_parameter("brightness"), 1.35), "3D world shader updates")
	check(Settings.set_number("vignette", 0.0) == OK, "vignette can be switched off")
	check(is_zero_approx(session.get_node("RetroPostProcess")._material.get_shader_parameter("vignette_strength")), "vignette off reaches actual world shader")
	Settings.load_preferences()
	check(is_zero_approx(Settings.get_number("vignette")), "vignette off survives preference reload")
	check(Settings.set_number("vignette", 0.7) != OK, "vignette rejects excessive intensity")
	check(Settings.set_number("vignette", Settings.DEFAULTS["vignette"]) == OK, "vignette default restored")
	var room: RoomView = session.get_node("RoomView")
	room.open("living_room")
	check(is_equal_approx(room._background.modulate.r, 1.35) and room._background.modulate.a == 1.0, "2D brightness never fades the room into the corridor")
	check(room._title.modulate == Color.WHITE and room._root.modulate == Color.WHITE, "room UI is not brightness-tinted")
	check(is_equal_approx(session.get_node("DialogueView")._figure.modulate.r, 1.35), "dialogue figure follows brightness")
	panel._back.grab_focus()
	var visited: Array[Control] = []
	for press: int in Settings.DEFAULTS.size() + 2:
		var tab := InputEventKey.new()
		tab.keycode = KEY_TAB
		tab.physical_keycode = KEY_TAB
		tab.pressed = true
		viewport.push_input(tab)
		var release := InputEventKey.new()
		release.keycode = KEY_TAB
		release.physical_keycode = KEY_TAB
		viewport.push_input(release)
		await get_tree().process_frame
		var focused: Control = viewport.gui_get_focus_owner()
		check(focused != null and panel.is_ancestor_of(focused), "real Tab input stays inside modal")
		if focused not in visited:
			visited.append(focused)
	check(visited.size() == Settings.DEFAULTS.size() + 2, "Tab reaches every settings control including motion, reset and back")
	for resolution: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]:
		viewport.size = resolution
		for locale: String in ["en", "tr"]:
			Settings.set_language(locale)
			for frame: int in 3:
				await get_tree().process_frame
			var bounds := Rect2(Vector2.ZERO, Vector2(resolution))
			for control: Control in panel._sliders.values():
				check(bounds.encloses(control.get_global_rect()), "settings slider fits " + locale + str(resolution))
			check(bounds.encloses(panel._back.get_global_rect()), "settings back fits " + locale + str(resolution))
			if "--capture-settings" in OS.get_cmdline_user_args() and resolution == Vector2i(1920, 1080):
				await RenderingServer.frame_post_draw
				check(viewport.get_texture().get_image().save_png("res://docs/qa/settings-%s.png" % locale) == OK, "settings capture saved")
	panel.find_child("RestoreDefaults", true, false).pressed.emit()
	check(Settings.language == "tr" and is_equal_approx(Settings.get_number("brightness"), 1.0), "reset preserves language")
	check(not AudioServer.is_bus_mute(master) and is_equal_approx(AudioServer.get_bus_volume_linear(master), 1.0), "reset restores audible default gain")
	panel.close()
	menu.free()
	room.close()
	var pause: PauseMenu = session.get_node("PauseMenu")
	pause.open()
	pause.find_child("SettingsButton", true, false).pressed.emit()
	check(pause._settings.visible and get_tree().paused, "pause settings keeps campaign paused")
	_press_pause(viewport)
	await get_tree().process_frame
	check(not pause._settings.visible and pause.visible and get_tree().paused, "first Escape closes settings only")
	_press_pause(viewport)
	await get_tree().process_frame
	check(not pause.visible and not get_tree().paused, "second Escape resumes gameplay")
	check(player.control_enabled, "gameplay control returns after modal closes")
	viewport.free()
	Settings.restore_defaults()
	Settings.set_language("en")
	await get_tree().process_frame
	if failures == 0:
		print("SETTINGS TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)

func _press_pause(target: Viewport) -> void:
	var event := InputEventAction.new()
	event.action = &"pause"
	event.pressed = true
	target.push_input(event)
	var release := InputEventAction.new()
	release.action = &"pause"
	target.push_input(release)
