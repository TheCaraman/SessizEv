extends Node
## Persists outside current_scene to exercise real menu/session replacements.

var checks: int = 0
var failures: int = 0

func _ready() -> void:
	_run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		print("FAIL: " + message)

func settle() -> void:
	await get_tree().process_frame
	await get_tree().process_frame

func press(node: Node, key: String) -> void:
	for child: Node in node.get_children():
		if child is Button and child.text == tr(key):
			child.pressed.emit()
			return
		press(child, key)

func menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
	await settle()

func _run() -> void:
	# Keep this harness alive while SceneTree replaces the playable scene.
	get_tree().current_scene = null
	TranslationServer.set_locale("en")
	SaveManager.delete_save()
	await menu()
	press(get_tree().current_scene, "MENU_NEW_GAME")
	await settle()
	check(get_tree().current_scene.scene_file_path == MainMenu.SESSION_SCENE, "new game changes the actual scene")
	GameState.advance_minutes(1080 - GameState.minutes)
	check(GameState.visitor == "elena_ward", "Elena waits")
	check(SaveManager.save_game() == OK, "waiting visitor save succeeds")
	var saved: Dictionary = GameState.to_dict()
	get_tree().current_scene.get_node("PauseMenu")._go_to_main_menu()
	await settle()
	var title := get_tree().current_scene as MainMenu
	check(title != null and title.has_continue(), "pause returns to menu with continue")
	title._continue_button.pressed.emit()
	await settle()
	check(get_tree().current_scene.scene_file_path == MainMenu.SESSION_SCENE, "continue changes the actual scene")
	check(GameState.to_dict() == saved, "continue preserves waiting visitor and full campaign")
	EventBus.front_door_used.emit()
	check(get_tree().current_scene.get_node("DialogueRunner").is_active(), "continued visitor can be spoken to")
	for iteration: int in 2:
		await menu()
		press(get_tree().current_scene, "MENU_NEW_GAME")
		await settle()
		check(GameState.visitor == "" and GameState.resolved_arrivals.is_empty(), "restart clears previous arrivals")
		GameState.advance_minutes(1080 - GameState.minutes)
		check(GameState.resolved_arrivals.size() == 1, "restart resolves one arrival")
		GameState.advance_minutes(220)
		check(GameState.visitor == "" and GameState.get_status("elena_ward") == "left", "visitor departs once")
	var session: Node = get_tree().current_scene
	var director := session.get_node("CampaignDirector") as CampaignDirector
	var before: Dictionary = GameState.resources.duplicate()
	director.perform_room_action("daniel_bedroom", "sleep")
	check(GameState.day == 2 and GameState.resources.food == before.food - 1 and GameState.resources.water == before.water - 1, "first night consumes exactly once")
	director.perform_room_action("daniel_bedroom", "sleep")
	check(GameState.day == 2, "repeated sleep at morning does nothing")
	GameState.admit("elena_ward", "guest_a_1")
	var view := session.get_node("ShelterView") as ShelterView
	for locale: String in ["en", "tr"]:
		TranslationServer.set_locale(locale)
		var unchanged: Dictionary = GameState.to_dict()
		view.open()
		view.set_bed("elena_ward", "guest_b_1")
		view.set_job("elena_ward", "inventory")
		view.cancel()
		check(GameState.to_dict() == unchanged, "management cancellation costs nothing: " + locale)
		check(session.get_node("Player").control_enabled, "cancellation restores controls")
	GameState.advance_minutes(1200 - GameState.minutes)
	before = GameState.resources.duplicate()
	var morning: String = director.perform_room_action("daniel_bedroom", "sleep")
	check(GameState.day == 3 and GameState.resources.food == before.food - 2 and GameState.resources.water == before.water - 2, "second night consumes once per person")
	check(morning.contains(tr("NARR_END_OF_BUILD")), "Day 3 boundary is reported")
	director.perform_room_action("daniel_bedroom", "sleep")
	check(GameState.day == 3, "repeated second-night action does not consume again")
	_check_translations()
	SaveManager.delete_save()
	if failures == 0:
		print("DAY12 INTEGRATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)

func _check_translations() -> void:
	var file := FileAccess.open("res://localization/strings.csv", FileAccess.READ)
	file.get_csv_line()
	var seen: Dictionary = {}
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() == 1 and row[0] == "":
			continue
		check(row.size() == 3, "translation has three columns")
		if row.size() != 3:
			continue
		check(not seen.has(row[0]), "unique translation key: " + row[0])
		seen[row[0]] = true
		check(row[1] != "" and row[2] != "", "English and Turkish present: " + row[0])
