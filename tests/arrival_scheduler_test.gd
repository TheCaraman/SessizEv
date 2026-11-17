extends Node
## ARRIVALS-001 stage A: the timetable generator on its own (no GameState,
## save or director changes yet). docs/design/ArrivalSchedule.md section 10.

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	var roster: PackedStringArray = Roster.get_ids()
	var none: Dictionary = {}

	# Same seed, same timetable; the input infection map is never changed.
	var infected: Dictionary = InfectionAssigner.assign(1234)
	var before: Dictionary = infected.duplicate()
	var first: Array[Dictionary] = ArrivalScheduler.generate(1234, infected)
	check(first == ArrivalScheduler.generate(1234, infected), "same seed gives the same timetable")
	check(infected == before, "generator never changes infection")
	check(InfectionAssigner.assign(1234) == before, "infection draw is unchanged by the timetable stream")
	check(ArrivalScheduler.valid_schedule(first, roster), "generated timetable passes the save validator")

	# Owner-approved parameters over many campaigns (K-ARRIVALS-PARAMS-001).
	var variants: Dictionary = {}
	var all_rules_hold: bool = true
	var tutorial_fixed: bool = true
	var both_always: bool = true
	var unwritten_absent: bool = true
	var ids_ok: bool = true
	for seed_value: int in 400:
		var schedule: Array[Dictionary] = ArrivalScheduler.generate(seed_value, InfectionAssigner.assign(seed_value))
		var key: String = ""
		var per_day: Dictionary = {}
		var visits: Array[String] = []
		for entry: Dictionary in schedule:
			visits.append(entry["visit"])
			per_day[entry["day"]] = per_day.get(entry["day"], 0) + 1
			if entry["end"] > 1380:
				all_rules_hold = false
			if entry["id"] != "d%d_%s" % [entry["day"], entry["visit"]]:
				ids_ok = false
			if entry["visit"] in ["marcus", "arthur"]:
				key += "%s%d@%d;" % [entry["visit"], entry["day"], entry["start"]]
				if entry["day"] < 2 or entry["day"] > 3 or entry["start"] < 540 or entry["start"] > 960:
					all_rules_hold = false
		for day: Variant in per_day:
			if per_day[day] > 2:
				all_rules_hold = false
		for i: int in schedule.size():
			for j: int in range(i + 1, schedule.size()):
				var a: Dictionary = schedule[i]
				var b: Dictionary = schedule[j]
				if a["day"] == b["day"] and not (b["start"] >= a["end"] + 90 or a["start"] >= b["end"] + 90):
					all_rules_hold = false
		var elena: Dictionary = schedule[0] if not schedule.is_empty() else {}
		if elena.get("id") != "d1_elena" or elena.get("start") != 1080 or elena.get("end") != 1290:
			tutorial_fixed = false
		if not ("marcus" in visits and "arthur" in visits):
			both_always = false
		if "noah_lily" in visits or "maya" in visits:
			unwritten_absent = false
		variants[key] = true
	check(all_rules_hold, "<=2 visits a day, >=90 min apart, Marcus/Arthur inside Day 2-3 windows, none past 23:00")
	check(tutorial_fixed, "Elena's Day 1 18:00-21:30 tutorial visit is always first and unmoved")
	check(both_always, "Marcus and Arthur come in every campaign")
	check(unwritten_absent, "characters without written arrival dialogue never enter the timetable")
	check(ids_ok, "visit ids keep the d<day>_<visit> form of the old saves")
	check(variants.size() >= 20, "different seeds give varied Day 2-3 timetables (%d variants)" % variants.size())

	# Writing a new character later must not reshuffle the existing ones.
	var everything := func(_dialogue: String) -> bool: return true
	var stable: bool = true
	for seed_value: int in 100:
		var current: Array[Dictionary] = ArrivalScheduler.generate(seed_value, none)
		var expanded: Array[Dictionary] = ArrivalScheduler.generate(seed_value, none, {}, everything)
		for entry: Dictionary in current:
			var match_found: bool = false
			for other: Dictionary in expanded:
				if other["visit"] == entry["visit"] and other["day"] == entry["day"] and other["start"] == entry["start"]:
					match_found = true
			# A newly written visit may legitimately take a slot first; only
			# require stability when the old slot is still free in the bigger set.
			if not match_found and _slot_free(expanded, entry):
				stable = false
	check(stable, "adding dialogue for another character keeps everyone else's dates")

	# K-005 with a pool where every visit can take any slot.
	var pool: Dictionary = {
		"rules": {"max_visits_per_day": 2, "min_gap_minutes": 90, "latest_end": 1380, "slot_minutes": 15, "first_offers_window": 6},
		"visits": [],
	}
	var people: Array[String] = ["marcus_hale", "arthur_bell", "maya_collins", "grace_miller", "victor_shaw", "sophie_lane", "samuel_price", "olivia_hart", "ruth_bennett", "caleb_ross"]
	for person: String in people:
		pool["visits"].append({"id": person, "npcs": [person], "windows": [{"days": [2, 9], "start_min": 540, "start_max": 960, "duration": 120}], "dialogue": person, "always": true})
	var early_ok: bool = true
	var positions: Dictionary = {}
	for seed_value: int in 300:
		var target: String = people[seed_value % people.size()]
		var marks: Dictionary = {target: true}
		var schedule: Array[Dictionary] = ArrivalScheduler.generate(seed_value, marks, pool, everything)
		var found: int = -1
		for i: int in schedule.size():
			if schedule[i]["npc"] == target:
				found = i
		if found < 0 or found >= 6:
			early_ok = false
		positions[found] = true
	check(early_ok, "an infected visitor is always among the first six offers when one is scheduled")
	check(positions.size() >= 4, "the early infected visitor lands in varied positions, not always first")

	# Old saves: the fixed timetable is kept as-is.
	var legacy: Array[Dictionary] = ArrivalScheduler.legacy_schedule()
	var legacy_ids: Array[String] = []
	for entry: Dictionary in legacy:
		legacy_ids.append(entry["id"])
	check(legacy_ids == ["d1_elena", "d2_marcus", "d2_arthur"], "legacy timetable keeps the old visit ids in order")
	check(ArrivalScheduler.valid_schedule(legacy, roster), "legacy timetable passes the save validator")

	# Validator refusals.
	var broken: Array = first.duplicate(true)
	broken.append(first[0].duplicate())
	check(not ArrivalScheduler.valid_schedule(broken, roster), "duplicate visit id refused")
	broken = first.duplicate(true)
	broken[0]["end"] = broken[0]["start"]
	check(not ArrivalScheduler.valid_schedule(broken, roster), "empty visit window refused")
	broken = first.duplicate(true)
	broken[0]["npcs"] = ["nobody"]
	broken[0]["npc"] = "nobody"
	check(not ArrivalScheduler.valid_schedule(broken, roster), "unknown character refused")
	check(not ArrivalScheduler.valid_schedule("x", roster), "non-list timetable refused")

	print("sample seed 1234: ", first.map(func(e: Dictionary) -> String: return "%s %02d:%02d-%02d:%02d" % [e["id"], e["start"] / 60, e["start"] % 60, e["end"] / 60, e["end"] % 60]))
	print("variants: %d, early positions: %s" % [variants.size(), positions.keys()])
	if failures == 0:
		print("ARRIVAL SCHEDULER TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)


func _slot_free(schedule: Array[Dictionary], entry: Dictionary) -> bool:
	var same_day: int = 0
	for other: Dictionary in schedule:
		if other["visit"] == entry["visit"] or other["day"] != entry["day"]:
			continue
		same_day += 1
		if not (entry["start"] >= other["end"] + 90 or entry["end"] + 90 <= other["start"]):
			return false
	return same_day < 2
