extends Node
## ARRIVALS-001 stage B: the stored timetable drives the real door through
## CampaignDirector, survives saving, and old saves keep the fixed timetable.
## The chained runs then play a seeded Day 3 Marcus visit (admitted, turned
## away or missed) through the Day 3 night, the power cut, the real night
## transition into Day 4, the Day 4 radio and the Day 4 closure, using only
## the room actions and dialogue choices the player has.

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

	# The director above has finished; only one director may listen to the
	# door and the clock during the chained Day 3 -> Day 4 runs below.
	director.free()
	dialogue.free()
	var chain_seed: int = _find_chain_seed()
	check(chain_seed >= 0, "some seed schedules Marcus on Day 3 and Arthur on Day 2")
	if chain_seed >= 0:
		for branch: String in ["admit", "reject", "miss"]:
			_run_chain(chain_seed, branch)

	SaveManager.delete_save(SLOT)
	SaveManager.delete_save(SaveManager.AUTOSAVE_SLOT)
	if failures == 0:
		print("ARRIVAL INTEGRATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)


func _infection() -> Dictionary:
	var result: Dictionary = {}
	for id: String in GameState.npcs:
		result[id] = GameState.npcs[id]["infected"]
	return result


## A seed whose timetable puts Marcus on Day 3 and Arthur on Day 2, so Marcus
## is the only person at the door on Day 3.
func _find_chain_seed() -> int:
	for candidate: int in 4000:
		var marcus_day: int = 0
		var arthur_day: int = 0
		for entry: Dictionary in ArrivalScheduler.generate(candidate, InfectionAssigner.assign(candidate)):
			if entry["visit"] == "marcus":
				marcus_day = int(entry["day"])
			elif entry["visit"] == "arthur":
				arthur_day = int(entry["day"])
		if marcus_day == 3 and arthur_day == 2:
			return candidate
	return -1


## Presses a room action the way the room view does, after checking that the
## player is actually offered it right now.
func _act(director: CampaignDirector, room: String, action: String) -> String:
	var offered: bool = false
	for entry: Dictionary in director.get_room_actions(room):
		if entry["id"] == action:
			offered = true
	check(offered, "%s offers %s on Day %d at %s" % [room, action, GameState.day, GameState.get_clock_text()])
	return director.perform_room_action(room, action)


## Saves, replaces the live campaign with another one, loads, and checks that
## the whole campaign came back unchanged.
func _round_trip(label: String, seed_value: int) -> void:
	var saved: Dictionary = GameState.to_dict()
	check(SaveManager.save_game(SLOT) == OK, label + ": save")
	GameState.new_campaign(seed_value + 1)
	check(SaveManager.load_game(SLOT), label + ": load")
	check(GameState.to_dict() == saved, label + ": the campaign is identical after load")


## One full Day 3 -> Day 4 run. [param branch] is what Daniel does with Marcus
## at the door: "admit", "reject" or "miss" (never opens the door).
## Each branch also takes a different way through the power cut: repaired with
## Marcus at night, put off and repaired solo on Day 4, or never repaired.
func _run_chain(seed_value: int, branch: String) -> void:
	var tag: String = "[%s] " % branch
	GameState.new_campaign(seed_value)
	var infection: Dictionary = _infection()
	var timetable: Array[Dictionary] = GameState.arrival_schedule.duplicate(true)
	var visit: Dictionary = {}
	var arthur_id: String = ""
	var day3_visits: int = 0
	for entry: Dictionary in timetable:
		if entry["day"] == 3:
			day3_visits += 1
		if entry["visit"] == "marcus":
			visit = entry
		elif entry["visit"] == "arthur":
			arthur_id = entry["id"]
	check(day3_visits == 1 and visit.get("id", "") == "d3_marcus", tag + "Marcus is the only Day 3 visit")
	if visit.is_empty() or arthur_id == "":
		return

	# Day 3 start-up only (no Day 3 outcome is set here): Elena took a bed on
	# Day 1 and Arthur's Day 2 knock went unanswered.
	GameState.admit("elena_ward", "guest_a_1")
	GameState.resolve_arrival("d1_elena")
	GameState.resolve_arrival(arthur_id)
	GameState.remove_npc("arthur_bell", "left")
	GameState.set_flag(arthur_id + "_left_unanswered")
	GameState.day = 3
	GameState.minutes = GameState.DAY_START

	# Same wiring as the session scene (scripts/dev/house_blockout.gd).
	var root := Node.new()
	add_child(root)
	var shelter := ShelterManager.new()
	root.add_child(shelter)
	var dialogue := DialogueRunner.new()
	root.add_child(dialogue)
	var director := CampaignDirector.new()
	director.shelter = shelter
	root.add_child(director)
	director.setup(dialogue)

	# --- Day 3 morning: Daniel rests until the seeded knock.
	var presses: int = 0
	while GameState.visitor == "" and GameState.minutes < int(visit["start"]) and presses < 20:
		_act(director, "daniel_bedroom", "rest")
		presses += 1
	check(GameState.minutes == int(visit["start"]) and GameState.visitor == "marcus_hale" and GameState.visitor_arrival == "d3_marcus", tag + "Marcus knocks at his seeded Day 3 time")
	check(not director.can_save(), tag + "no saving while Marcus is at the door")

	match branch:
		"admit", "reject":
			EventBus.front_door_used.emit()
			check(dialogue.get_dialogue_id() == "marcus_arrival", tag + "opening the door starts Marcus's arrival dialogue")
			dialogue.choose_by_id("continue")
			dialogue.choose_by_id("continue")
			check(dialogue.get_node_id() == "hub", tag + "the doorstep conversation reaches its choices")
			if branch == "admit":
				var asked_at: int = GameState.minutes
				check(dialogue.choose_by_id("work") and dialogue.choose_by_id("continue"), tag + "ask Marcus about his work")
				check(GameState.minutes == asked_at + 5 and GameState.get_flag("known_skill_marcus_electrical"), tag + "the question takes five minutes and reveals his trade")
				check(dialogue.choose_by_id("admit") and dialogue.choose_by_id("bed:guest_b_1"), tag + "admit Marcus to a guest room B bed")
				dialogue.choose_by_id("continue")
				check(GameState.get_status("marcus_hale") == "resident" and GameState.get_bed_of("marcus_hale") == "guest_b_1", tag + "Marcus lives in the house")
				check(int(GameState.npcs["marcus_hale"]["trust"]) == 10 and GameState.get_flag("marcus_admitted"), tag + "the admission is remembered")
			else:
				check(dialogue.choose_by_id("reject") and dialogue.choose_by_id("confirm"), tag + "turn Marcus away")
				dialogue.choose_by_id("continue")
				check(GameState.get_status("marcus_hale") == "rejected" and GameState.get_bed_of("marcus_hale") == "", tag + "Marcus is turned away and has no bed")
				check(GameState.get_flag("marcus_rejected"), tag + "the refusal is remembered")
			check(not dialogue.is_active() and GameState.visitor == "", tag + "the doorstep is clear after the conversation")
		"miss":
			var warned_presses: int = 0
			presses = 0
			while GameState.visitor != "" and presses < 20:
				var before: int = GameState.minutes
				_act(director, "daniel_bedroom", "rest")
				if GameState.minutes == before:
					warned_presses += 1
				presses += 1
			check(warned_presses == 1, tag + "Daniel is warned once before resting past Marcus's patience")
			check(GameState.visitor == "" and GameState.get_status("marcus_hale") == "left", tag + "unanswered Marcus leaves")
			check(GameState.minutes == int(visit["end"]) and GameState.get_flag("d3_marcus_left_unanswered"), tag + "the missed visit is recorded when his window ends")
	check(GameState.resolved_arrivals.count("d3_marcus") == 1, tag + "the Day 3 visit is resolved exactly once")
	var marcus_status: String = GameState.get_status("marcus_hale")
	_round_trip(tag + "after the Day 3 doorstep", seed_value)
	check(GameState.arrival_schedule == timetable and _infection() == infection, tag + "the doorstep decision changes neither timetable nor infection")

	# --- Rooms: the player's plan moves the admitted guest; one room at a time.
	if branch == "admit":
		var plan: Dictionary = shelter.get_current_plan()
		plan["beds"]["marcus_hale"] = "multipurpose_1"
		var planned_at: int = GameState.minutes
		check(shelter.apply_plan(plan)["key"] == "", tag + "a bed plan moving Marcus is accepted")
		check(GameState.minutes == planned_at + ShelterManager.PLAN_MINUTES, tag + "agreeing the plan takes its fixed time")
		var occupants: Array[String] = GameState.get_room_occupants("multipurpose")
		check(GameState.get_location("marcus_hale") == "multipurpose" and occupants.size() == 1 and occupants[0] == "marcus_hale", tag + "Marcus is in the multipurpose room")
		check(GameState.get_room_sleepers("guest_b").is_empty() and GameState.get_bed_of("elena_ward") == "guest_a_1", tag + "nobody else moved and Marcus left guest room B")
		check(shelter.apply_plan(shelter.get_current_plan())["key"] == "" and GameState.minutes == planned_at + ShelterManager.PLAN_MINUTES, tag + "re-confirming the same plan costs nothing")

	# --- Day 3 evening and night.
	presses = 0
	while GameState.minutes < CampaignDirector.EARLIEST_SLEEP_MINUTE and presses < 20:
		_act(director, "daniel_bedroom", "rest")
		presses += 1
	check(GameState.day == 3 and GameState.minutes < GameState.NIGHT_START and director.power.pending(), tag + "the evening is reached before the power cut")
	var people: int = GameState.get_headcount()
	check(people == (3 if branch == "admit" else 2), tag + "tonight's headcount follows the doorstep decision")
	var food: int = int(GameState.resources["food"])
	var water: int = int(GameState.resources["water"])
	var morning: String = ""
	match branch:
		"admit":
			check(_act(director, "daniel_bedroom", "sleep") == tr("POWER_WAKE"), tag + "going to bed is cut short by the power failure")
			check(GameState.day == 3 and GameState.minutes == GameState.NIGHT_START and not director.power.is_powered(), tag + "the power fails at 23:00 on Day 3")
			_act(director, "utility", "power:panel")
			check(GameState.minutes == GameState.NIGHT_START + 10, tag + "inspecting the panel takes ten minutes")
			var quote: Dictionary = director.power.repair_quote()
			check(quote["helper"] == "marcus_hale" and quote["minutes"] == 25, tag + "admitted Marcus offers to help with the repair")
			var resource: String = quote["resource"]
			var stock: int = int(GameState.resources[resource])
			var quoted_at: int = GameState.minutes
			_act(director, "utility", "power:repair")
			check(GameState.minutes == quoted_at and not director.power.is_powered(), tag + "the first repair press only quotes")
			check(_act(director, "utility", "power:repair") == tr("POWER_RESTORED"), tag + "the confirmed repair restores power")
			check(GameState.minutes == quoted_at + 25 and int(GameState.resources[resource]) == stock - 1, tag + "the repair spends its quoted time and one unit")
			check(GameState.power_incident["repair"]["helper"] == "marcus_hale", tag + "Marcus is recorded as the helper")
			morning = _act(director, "daniel_bedroom", "sleep")
		"reject":
			check(_act(director, "daniel_bedroom", "watch") == tr("WATCH_CONFIRM") and not GameState.night_in_progress(), tag + "the night watch asks for confirmation first")
			var started: String = _act(director, "daniel_bedroom", "watch")
			check(GameState.night_in_progress() and GameState.minutes == GameState.NIGHT_START and not director.power.is_powered(), tag + "the confirmed watch reaches 23:00 and the power cut")
			check(started.contains(tr("POWER_WAKE")), tag + "the watch narration reports the power cut")
			check(_act(director, "utility", "power:defer") == tr("POWER_DEFER"), tag + "the repair is put off")
			check(director.power.repair_quote()["helper"] == "", tag + "with Marcus turned away nobody offers to help")
			presses = 0
			while GameState.day == 3 and presses < 20:
				morning = _act(director, "daniel_bedroom", "wait_watch")
				presses += 1
		"miss":
			check(_act(director, "daniel_bedroom", "sleep") == tr("POWER_WAKE"), tag + "going to bed is cut short by the power failure")
			check(_act(director, "utility", "power:defer") == tr("POWER_DEFER"), tag + "the repair is put off")
			morning = _act(director, "daniel_bedroom", "sleep")
	check(GameState.power_incident.get("cause") != "sabotage" and GameState.power_incident.get("actor") == "", tag + "without the memory-loss report no saboteur is invented")

	# --- Day 4 morning, reached through the real night transition.
	check(GameState.day == 4 and GameState.minutes == GameState.DAY_START, tag + "the night ends at Day 4 07:00")
	check(morning.contains(tr("RADIO_D4_MORNING_GUIDE")), tag + "the Day 4 morning points to the radio")
	check(int(GameState.resources["food"]) == food - people and int(GameState.resources["water"]) == water - people, tag + "the night is paid for exactly once")
	check(GameState.get_status("marcus_hale") == marcus_status and GameState.visitor == "", tag + "Marcus's outcome holds and nobody is at the door")
	check(GameState.arrival_schedule == timetable and _infection() == infection and GameState.resolved_arrivals.count("d3_marcus") == 1, tag + "the night changes neither timetable, visit nor infection")
	_round_trip(tag + "Day 4 morning", seed_value)

	if branch == "reject":
		var stock_resource: String = director.power.repair_quote()["resource"]
		var stock_before: int = int(GameState.resources[stock_resource])
		_act(director, "utility", "power:repair")
		check(_act(director, "utility", "power:repair") == tr("POWER_RESTORED"), tag + "the put-off repair is done on Day 4 morning")
		check(GameState.minutes == GameState.DAY_START + 35 and int(GameState.resources[stock_resource]) == stock_before - 1, tag + "Daniel repairs alone in 35 minutes")
		check(GameState.power_incident["repair"]["helper"] == "", tag + "no helper is credited")

	# --- Day 4 radio.
	var radio_minutes: int = int((JSON.parse_string(FileAccess.get_file_as_string(Day4Broadcast.RULES)) as Dictionary)["minutes"])
	var radio_at: int = GameState.minutes
	check(_act(director, "living_room", "radio").contains(tr("RADIO_D4_EVACUATION")), tag + "the Day 4 radio carries the evacuation announcement")
	check(GameState.get_flag(Day4Broadcast.HEARD) and GameState.minutes == radio_at + radio_minutes and int(GameState.get_flag(Day4Broadcast.AT)) == GameState.minutes, tag + "listening takes its time and is recorded")
	var heard: Dictionary = GameState.to_dict()
	_act(director, "living_room", "radio")
	check(GameState.to_dict() == heard, tag + "rereading the radio notes is free")

	# --- Day 4 closure.
	check(_act(director, "daniel_bedroom", "review_last_night") == "" and GameState.get_flag("day4_reviewed"), tag + "the night review is opened and recorded")
	var quiet: Dictionary = GameState.to_dict()
	check(_act(director, "daniel_bedroom", "day4:wait") == tr("D4_CLOSE_CONFIRM_WAIT") and GameState.to_dict() == quiet, tag + "waiting for the evening asks first and costs nothing")
	check(_act(director, "daniel_bedroom", "day4:wait") == tr("D4_CLOSE_WAITED"), tag + "the confirmed wait is carried out")
	check(GameState.day == 4 and GameState.minutes == 1200, tag + "the wait reaches 20:00 on Day 4")
	quiet = GameState.to_dict()
	check(_act(director, "daniel_bedroom", "day4:complete") == tr("D4_CLOSE_CONFIRM_COMPLETE") and GameState.to_dict() == quiet, tag + "closing the review asks first and costs nothing")
	check(_act(director, "daniel_bedroom", "day4:complete") == "" and GameState.get_flag("day4_review_completed") and GameState.get_flag("day4_review_completed_at") == 1200, tag + "the confirmed closure is recorded at 20:00")
	var summary: String = Day4Review.summary()
	check(summary.contains(tr("D4_CLOSE_OUTAGE" if branch == "miss" else "D4_CLOSE_POWER_AVAILABLE")), tag + "the closing summary reports the power as it is")
	check(summary.contains(tr("RADIO_D4_EVACUATION_CLAIM")) and summary.contains(tr("D4_CLOSE_BUILD_LIMIT")), tag + "the summary keeps the radio claim and states the build limit")
	_round_trip(tag + "after the Day 4 closure", seed_value)
	var closed: Dictionary = GameState.to_dict()
	check(_act(director, "daniel_bedroom", "sleep") == tr("NARR_END_OF_BUILD") and GameState.to_dict() == closed, tag + "sleeping after the closure states the build limit and changes nothing")
	check(GameState.arrival_schedule == timetable and _infection() == infection, tag + "timetable and infection are the campaign's own to the end")
	root.free()
