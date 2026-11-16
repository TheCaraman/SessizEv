extends Node
var checks: int = 0
var failures: int = 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
func write_payload(state: Dictionary, version: int = 5) -> void:
	var file := FileAccess.open(SaveManager.get_path_for("night_clock"), FileAccess.WRITE)
	file.store_string(JSON.stringify({"save_version": version, "state": state}))
	file.close()
func _ready() -> void:
	GameState.new_campaign(42)
	GameState.day = 3
	GameState.minutes = 1380
	var power := PowerIncident.new()
	add_child(power)
	power.trigger()
	GameState.power_incident["cause"] = "loose_connection"
	var timeline := NightTimeline.new()
	timeline.begin(3, 100)
	GameState.night_session = timeline.to_dict()
	var food: int = GameState.resources["food"]
	GameState.advance_minutes(120)
	check(GameState.day == 3 and GameState.minutes == 1500 and GameState.get_clock_text() == "01:00", "midnight does not advance campaign day")
	check(GameState.get_phase() == GameState.Phase.NIGHT and GameState.player["energy"] == 90, "night phase and actual awake cost")
	check(GameState.resources["food"] == food, "no early daily consumption")
	var state: Dictionary = GameState.to_dict()
	check(SaveManager.save_game("night_clock") == OK and SaveManager.load_game("night_clock"), "v5 extended night save/load")
	check(GameState.to_dict() == state, "night restore exact")
	for broken: Dictionary in [{"minutes": 1501}, {"day": 4}, {"night_session": []}, {"night_session": {"bad": 1}}]:
		var invalid: Dictionary = state.duplicate(true)
		invalid.merge(broken, true)
		write_payload(invalid)
		check(not SaveManager.load_game("night_clock") and GameState.to_dict() == state, "invalid night load cannot mutate campaign")
	var repaired: int = GameState.resources["repair"]
	power.repair(true)
	check(GameState.minutes == 1535 and GameState.resources["repair"] == repaired - 1, "repair works after midnight")
	GameState.advance_minutes(1000)
	check(GameState.minutes == 1860 and GameState.get_clock_text() == "07:00", "extended clock clamps at dawn")
	check(GameState.get_phase() == GameState.Phase.MORNING and GameState.player["energy"] == 60, "dawn phase and full-watch energy")
	state = GameState.to_dict()
	GameState.start_next_day()
	check(GameState.to_dict() == state, "unclaimed night blocks premature morning")
	timeline.from_dict(GameState.night_session)
	check(timeline.claim_morning(), "claim completed morning")
	GameState.night_session = timeline.to_dict()
	GameState.start_next_day(timeline.energy())
	check(GameState.day == 4 and GameState.resources["food"] == food - 1 and GameState.player["energy"] == 60, "single morning consumption and retained fatigue")
	check(SaveManager.save_game("night_clock") == OK and SaveManager.load_game("night_clock"), "resolved night can save on later day")
	check(not GameState.night_in_progress() and GameState.get_action_time_limit() == GameState.LAST_MINUTE, "ordinary next day retains original limit")
	for version: int in [1, 2, 3, 4]:
		GameState.new_campaign(version)
		state = GameState.to_dict()
		state.erase("night_session")
		var infected: Dictionary = GameState.npcs.duplicate(true)
		write_payload(state, version)
		check(SaveManager.load_game("night_clock"), "legacy load " + str(version))
		check(GameState.night_session.is_empty() and GameState.npcs == infected, "legacy migration never invents watch or rerolls infection")
	SaveManager.delete_save("night_clock")
	power.free()
	if failures == 0:
		print("NIGHT STATE TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
