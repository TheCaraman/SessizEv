extends Node
## Headless test for the main menu, the pause menu and saving by choice.
##
## Run with:
##   godot --headless --path . res://tests/menu_test.tscn
## Exit code 0 means every check passed.
##
## Checks:
##   1. With no save the menu offers no "Continue".
##   2. Saving in Daniel's bedroom writes a save the menu then offers, naming
##      the right day; saving is refused while someone is at the door.
##   3. "Continue" restores exactly the saved campaign.
##   4. "New game" starts a different, fresh campaign.
##   5. A damaged save is reported as unusable rather than loaded.
##   6. The pause key pauses the game in the corridor and resumes it.

const MENU_SCENE: PackedScene = preload("res://scenes/main/main_menu.tscn")
const SESSION_SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")

var _frame: int = 0
var _failures: PackedStringArray = []
var _checks: int = 0
var _session: Node
var _pause_menu: PauseMenu


func _ready() -> void:
	# The pause check stops the tree; this node must keep running through it.
	process_mode = Node.PROCESS_MODE_ALWAYS
	TranslationServer.set_locale("en")
	SaveManager.delete_save()

	_check_menu_without_save()
	GameState.new_campaign(42)
	_session = SESSION_SCENE.instantiate()
	add_child(_session)
	_pause_menu = _session.get_node("PauseMenu") as PauseMenu


func _process(_delta: float) -> void:
	_frame += 1
	match _frame:
		5:
			_check_manual_save()
			_check_continue_and_new_game()
			_check_damaged_save()
			_send_action(&"pause")
		10:
			_check(_pause_menu.is_open(), "the pause key should open the pause menu in the corridor")
			_check(get_tree().paused, "the game should be paused")
			_check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "the cursor should be free while paused")
			_send_action(&"pause")
		15:
			_check(not _pause_menu.is_open(), "the pause key should close the pause menu")
			_check(not get_tree().paused, "the game should resume")
			_check(
				(_session.get_node("Player") as PlayerController).control_enabled,
				"the player should have control again"
			)
			SaveManager.delete_save()
			_finish()


func _check_menu_without_save() -> void:
	var menu := MENU_SCENE.instantiate() as MainMenu
	add_child(menu)
	_check(not menu.has_continue(), "no save: nothing to continue")
	_check(not (menu.get("_continue_button") as Button).visible, "no save: the Continue button should be hidden")
	menu.free()


func _check_manual_save() -> void:
	var director := _session.get_node("CampaignDirector") as CampaignDirector
	var room_view := _session.get_node("RoomView") as RoomView

	# Someone at the door: no saving.
	GameState.advance_minutes(11 * 60 + 5)
	_check(GameState.visitor != "", "a visitor should be waiting in the evening")
	_check(not director.can_save(), "saving should be refused while someone is at the door")
	room_view.open(&"daniel_bedroom")
	_check(not room_view.get_action_ids().has("save"), "the bedroom should not offer saving now")
	room_view.close()

	# Turn her away, then save.
	EventBus.front_door_used.emit()
	var runner := _session.get_node("DialogueRunner") as DialogueRunner
	runner.choose(0)
	runner.choose(0)
	runner.choose_by_id("reject")
	while runner.is_active():
		runner.choose(0)
	GameState.set_flag("menu_test_marker", "kept")
	room_view.open(&"daniel_bedroom")
	_check(room_view.get_action_ids().has("save"), "the bedroom should offer saving when things are quiet")
	room_view.perform_action("save")
	_check(room_view.get_narration_text().contains("Saved"), "saving should be confirmed on screen")
	_check(SaveManager.has_save(), "a save file should exist")
	room_view.close()


func _check_continue_and_new_game() -> void:
	var saved: String = JSON.stringify(GameState.to_dict())
	var saved_minutes: int = GameState.minutes

	var menu := MENU_SCENE.instantiate() as MainMenu
	add_child(menu)
	_check(menu.has_continue(), "with a save the menu should offer Continue")
	var button := menu.get("_continue_button") as Button
	_check(button.visible and button.text.contains("Day 1"), "Continue should name the day, got '%s'" % button.text)

	menu.prepare_new_game()
	_check(JSON.stringify(GameState.to_dict()) != saved, "a new game should not equal the save")
	_check(GameState.day == 1 and GameState.minutes == GameState.DAY_START, "a new game starts on day 1, 07:00")
	_check(GameState.get_status("elena_ward") == "unknown", "a new game forgets who was turned away")
	_check(SaveManager.has_save(), "starting a new game must not delete the save by itself")

	_check(menu.prepare_continue(), "Continue should load the save")
	_check(JSON.stringify(GameState.to_dict()) == saved, "Continue should restore the saved campaign exactly")
	_check(GameState.minutes == saved_minutes, "the time of day should be restored")
	_check(GameState.get_flag("menu_test_marker") == "kept", "flags should be restored")
	_check(GameState.get_status("elena_ward") == "rejected", "who was turned away should be restored")
	menu.free()


func _check_damaged_save() -> void:
	var path: String = SaveManager.get_path_for(SaveManager.AUTOSAVE_SLOT)
	var good: String = FileAccess.get_file_as_string(path)
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string("{ this is not a save")
	file.close()

	var before: String = JSON.stringify(GameState.to_dict())
	_check(SaveManager.get_summary().is_empty(), "a damaged save should have no summary")
	var menu := MENU_SCENE.instantiate() as MainMenu
	add_child(menu)
	_check(not menu.has_continue(), "a damaged save should not be offered")
	_check(not menu.prepare_continue(), "loading a damaged save should fail")
	_check(JSON.stringify(GameState.to_dict()) == before, "a failed load must leave the campaign untouched")
	menu.free()

	# Valid JSON with malformed nested data must fail before touching GameState.
	var valid_payload: Dictionary = JSON.parse_string(good)
	var invalid_states: Array[Dictionary] = []
	for broken: Dictionary in [{"day": "three"}, {"minutes": 1440}, {"minutes": -1}, {"minutes": 420.5}, {"resources": []}, {"player": null}, {"npcs": {"elena_ward": false}}, {"jobs": {"elena_ward": []}}, {"reports": [false]}, {"evidence": ["bad"]}, {"beds": []}, {"power_incident": []}]:
		var invalid: Dictionary = valid_payload["state"].duplicate(true)
		invalid.merge(broken, true)
		invalid_states.append(invalid)
	invalid_states.append({})
	for field: String in ["resources", "npcs"]:
		var invalid: Dictionary = valid_payload["state"].duplicate(true)
		invalid[field] = {}
		invalid_states.append(invalid)
	for invalid: Dictionary in invalid_states:
		file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify({"save_version": GameState.SAVE_VERSION, "state": invalid}))
		file.close()
		_check(SaveManager.get_summary().is_empty(), "malformed structure has no summary")
		_check(not SaveManager.load_game(), "malformed structure rejected")
		_check(JSON.stringify(GameState.to_dict()) == before, "malformed nested load is atomic")

	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(good)
	file.close()


func _send_action(action: StringName) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("MENU TEST: PASS (%d checks)" % _checks)
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		print("MENU TEST: FAIL (%d of %d)" % [_failures.size(), _checks])
		get_tree().quit(1)
