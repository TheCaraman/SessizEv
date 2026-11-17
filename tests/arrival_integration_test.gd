extends Node
## ARRIVALS-001 stage B: the stored timetable drives the real door through
## CampaignDirector, survives saving, and old saves keep the fixed timetable.

const SLOT: String = "arrival_integration"
var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	var dialogue := DialogueRunner.new()
	add_child(dialogue)
	var director := CampaignDirector.new()
	add_child(director)
	director.setup(dialogue)

	# A campaign whose Marcus visit falls on Day 3 (the case the fixed
	# timetable never had).
	var seed_value: int = -1
	var visit: Dictionary = {}
	for candidate: int in 2000:
		for entry: Dictionary in ArrivalScheduler.generate(candidate, InfectionAssigner.assign(candidate)):
			if entry["visit"] == "marcus" and entry["day"] == 3:
				seed_value = candidate
				visit = entry
		if seed_value >= 0:
			break
	check(seed_value >= 0, "some seed schedules Marcus on Day 3")

	GameState.new_campaign(seed_value)
	check(GameState.arrival_schedule_version == ArrivalScheduler.ALGORITHM_VERSION, "new campaign stores the current timetable version")
	check(GameState.arrival_schedule == ArrivalScheduler.generate(seed_value, _infection()), "new campaign stores exactly the generated timetable")
	var stored: Array[Dictionary] = GameState.arrival_schedule.duplicate(true)

	# Day 2 passes without Marcus at the door.
	GameState.day = 2
	GameState.minutes = 420
	var marcus_on_day_2: bool = false
	while GameState.minutes < 1320:
		GameState.advance_minutes(15)
		if GameState.visitor == "marcus_hale":
			marcus_on_day_2 = true
		if GameState.visitor != "":
			# Let anyone else who knocked give up; this check is about Marcus.
			GameState.advance_minutes(240)
	check(not marcus_on_day_2, "Marcus does not knock on Day 2 when his visit is on Day 3")
	check(GameState.get_status("marcus_hale") == "unknown", "Marcus is still unmet after Day 2")

	# Day 3: a timed action is cut short exactly at his knock.
	GameState.day = 3
	GameState.minutes = int(visit["start"]) - 30
	GameState.visitor = ""
	GameState.visitor_arrival = ""
	GameState.player["energy"] = 50
	director.perform_room_action("daniel_bedroom", "rest")
	check(GameState.minutes == int(visit["start"]), "rest stops at the scheduled Day 3 knock (%d)" % GameState.minutes)
	check(GameState.visitor == "marcus_hale" and GameState.visitor_arrival == "d3_marcus", "Marcus is at the door for visit d3_marcus")

	# Save and load during the visit: same timetable, same person waiting.
	check(SaveManager.save_game(SLOT) == OK, "save during the Day 3 visit")
	GameState.new_campaign(seed_value + 1)
	check(SaveManager.load_game(SLOT), "load the Day 3 visit save")
	check(GameState.arrival_schedule == stored, "timetable is identical after save/load")
	check(GameState.visitor == "marcus_hale" and GameState.visitor_arrival == "d3_marcus", "the visitor is still waiting after load")

	# A decision cannot rewrite the timetable.
	var expected: Dictionary = GameState.to_dict()
	var forged: Dictionary = expected.duplicate(true)
	forged["arrival_schedule"][0]["start"] += 15
	check(SaveManager.commit_candidate(expected, forged, "arrival-forgery", SLOT) == ERR_INVALID_DATA, "a candidate that changes the timetable is refused")
	check(GameState.arrival_schedule == stored, "refused candidate leaves the live timetable alone")

	# Ignored until the window ends: he leaves, and never returns.
	GameState.advance_minutes(int(visit["end"]) - GameState.minutes)
	check(GameState.visitor == "" and GameState.get_status("marcus_hale") == "left", "unanswered Marcus leaves when his Day 3 window ends")
	check(GameState.get_flag("d3_marcus_left_unanswered"), "missed Day 3 visit is recorded")
	check(GameState.resolved_arrivals.count("d3_marcus") == 1, "the Day 3 visit is resolved exactly once")

	# Version 5 save (no stored timetable): kept on the old fixed timetable.
	GameState.new_campaign(seed_value)
	GameState.day = 2
	GameState.minutes = 610
	var old_state: Dictionary = GameState.to_dict()
	old_state.erase("arrival_schedule")
	old_state.erase("arrival_schedule_version")
	old_state["visitor"] = "marcus_hale"
	old_state["visitor_arrival"] = "d2_marcus"
	old_state["resolved_arrivals"] = ["d1_elena", "d2_marcus"]
	DirAccess.make_dir_recursive_absolute(SaveManager.SAVE_DIR)
	var file := FileAccess.open(SaveManager.get_path_for(SLOT), FileAccess.WRITE)
	file.store_string(JSON.stringify({"save_version": 5, "state": old_state}))
	file.close()
	check(SaveManager.load_game(SLOT), "version 5 save still loads")
	check(GameState.arrival_schedule_version == 0 and GameState.arrival_schedule == ArrivalScheduler.legacy_schedule(), "version 5 save keeps the fixed timetable, not re-rolled")
	check(GameState.visitor == "marcus_hale" and GameState.visitor_arrival == "d2_marcus", "old save's waiting visitor is kept")
	check(SaveManager.save_game(SLOT) == OK and SaveManager.load_game(SLOT), "migrated save writes and loads as version 6")
	check(GameState.arrival_schedule == ArrivalScheduler.legacy_schedule(), "fixed timetable survives the v6 rewrite")

	# A stored timetable that refers to a visit it does not contain is damage.
	var broken: Dictionary = GameState.to_dict()
	broken["resolved_arrivals"] = ["d9_nobody"]
	file = FileAccess.open(SaveManager.get_path_for(SLOT), FileAccess.WRITE)
	file.store_string(JSON.stringify({"save_version": 6, "state": broken}))
	file.close()
	check(not SaveManager.load_game(SLOT), "save with an unknown resolved visit is refused")

	SaveManager.delete_save(SLOT)
	if failures == 0:
		print("ARRIVAL INTEGRATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)


func _infection() -> Dictionary:
	var result: Dictionary = {}
	for id: String in GameState.npcs:
		result[id] = GameState.npcs[id]["infected"]
	return result
