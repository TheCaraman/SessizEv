extends Node
## ARRIVALS-002: meaning checks on a saved door timetable. Pure checks on
## dictionaries; nothing is written to user://.

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	var roster: PackedStringArray = Roster.get_ids()
	var all_generated_ok: bool = true
	var all_round_trip_ok: bool = true
	for seed_value: int in 300:
		var schedule: Array[Dictionary] = ArrivalScheduler.generate(seed_value, InfectionAssigner.assign(seed_value))
		if not ArrivalScheduler.valid_schedule_for_version(schedule, 1, roster):
			all_generated_ok = false
		var through_json: Variant = JSON.parse_string(JSON.stringify(schedule))
		if not ArrivalScheduler.valid_schedule_for_version(through_json, 1.0, roster):
			all_round_trip_ok = false
	check(all_generated_ok, "every generated timetable passes the version-1 rules")
	check(all_round_trip_ok, "timetables still pass after a JSON round trip")

	var legacy: Array[Dictionary] = ArrivalScheduler.legacy_schedule()
	check(ArrivalScheduler.valid_schedule_for_version(legacy, 0, roster), "old fixed timetable is valid as version 0")
	check(ArrivalScheduler.valid_schedule_for_version(JSON.parse_string(JSON.stringify(legacy)), 0.0, roster), "old fixed timetable survives JSON as version 0")
	var moved: Array = legacy.duplicate(true)
	moved[1]["start"] = 615
	moved[1]["end"] = 795
	check(not ArrivalScheduler.valid_schedule_for_version(moved, 0, roster), "version 0 must be exactly the old fixed timetable")
	for bad_version: Variant in [2, -1, "1", 1.5, null]:
		check(not ArrivalScheduler.valid_schedule_for_version(legacy, bad_version, roster), "unknown timetable version refused: %s" % str(bad_version))

	var base: Array[Dictionary] = ArrivalScheduler.generate(1234, InfectionAssigner.assign(1234))
	check(ArrivalScheduler.valid_schedule_for_version(base, 1, roster), "reference timetable is valid")
	_refuse(base, roster, func(s: Array) -> void:
		s[1]["start"] = 120
		s[1]["end"] = 300, "a visit before morning")
	_refuse(base, roster, func(s: Array) -> void: s.remove_at(0), "missing fixed tutorial visit")
	_refuse(base, roster, func(s: Array) -> void: s[1]["visit"] = 123, "non-string visit identifier")
	_refuse(base, roster, func(s: Array) -> void: s[1]["dialogue"] = "", "empty dialogue identifier")
	_refuse(base, roster, func(s: Array) -> void: s[1]["id"] = "d9_" + s[1]["visit"], "id that does not match its day")
	_refuse(base, roster, func(s: Array) -> void:
		var copy: Dictionary = s[1].duplicate(true)
		copy["day"] = 5
		copy["id"] = "d5_" + copy["visit"]
		s.append(copy), "the same visit twice")
	_refuse(base, roster, func(s: Array) -> void:
		s[2]["npcs"] = [s[1]["npc"]]
		s[2]["npc"] = s[1]["npc"], "one person in two visits")
	_refuse(base, roster, func(s: Array) -> void:
		s[1]["start"] = 1290
		s[1]["end"] = 1410, "a visit running into the night")
	_refuse(base, roster, func(s: Array) -> void:
		s[0]["start"] = 1095
		s[0]["end"] = 1305, "the Day 1 tutorial moved")
	_refuse(base, roster, func(s: Array) -> void:
		for entry: Dictionary in s:
			if entry["visit"] != "elena":
				entry["day"] = 2
				entry["id"] = "d2_" + entry["visit"]
		s[1]["start"] = 540
		s[1]["end"] = 720
		s[2]["start"] = 750
		s[2]["end"] = 930, "two visits on one day only 30 minutes apart")
	var crowded: Array = base.duplicate(true)
	crowded.append({"id": "d2_maya", "visit": "maya", "npc": "maya_collins", "npcs": ["maya_collins"], "day": 2, "start": 1200, "end": 1350, "dialogue": "maya_arrival"})
	for entry: Dictionary in crowded:
		if entry["visit"] in ["marcus", "arthur"]:
			entry["day"] = 2
			entry["id"] = "d2_" + entry["visit"]
	crowded[1]["start"] = 540
	crowded[1]["end"] = 720
	crowded[2]["start"] = 840
	crowded[2]["end"] = 1020
	check(not ArrivalScheduler.valid_schedule_for_version(crowded, 1, roster), "three visits on one day refused")

	# Save-level consistency of the door with the timetable.
	GameState.new_campaign(1234)
	var state: Dictionary = GameState.to_dict()
	check(SaveManager._valid_state_shape(state), "fresh campaign state is valid")
	var first: Dictionary = state["arrival_schedule"][0]
	var waiting: Dictionary = state.duplicate(true)
	waiting["visitor"] = first["npc"]
	waiting["visitor_arrival"] = first["id"]
	waiting["resolved_arrivals"] = [first["id"]]
	check(SaveManager._valid_state_shape(waiting), "visitor waiting for a begun visit is valid")
	var wrong_person: Dictionary = waiting.duplicate(true)
	wrong_person["visitor"] = "arthur_bell" if first["npc"] != "arthur_bell" else "marcus_hale"
	check(not SaveManager._valid_state_shape(wrong_person), "visitor who is not the visit's person refused")
	var not_begun: Dictionary = waiting.duplicate(true)
	not_begun["resolved_arrivals"] = []
	check(not SaveManager._valid_state_shape(not_begun), "visitor for a visit that never began refused")
	var no_visit: Dictionary = waiting.duplicate(true)
	no_visit["visitor_arrival"] = ""
	check(not SaveManager._valid_state_shape(no_visit), "visitor without a visit refused")
	var twice: Dictionary = waiting.duplicate(true)
	twice["resolved_arrivals"] = [first["id"], first["id"]]
	check(not SaveManager._valid_state_shape(twice), "a visit resolved twice refused")
	var unknown_version: Dictionary = state.duplicate(true)
	unknown_version["arrival_schedule_version"] = 7
	check(not SaveManager._valid_state_shape(unknown_version), "save with an unknown timetable version refused")
	check(SaveManager._valid_state_shape(JSON.parse_string(JSON.stringify(waiting))), "valid waiting state survives JSON")

	if failures == 0:
		print("ARRIVAL VALIDATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)


func _refuse(base: Array, roster: PackedStringArray, change: Callable, label: String) -> void:
	var copy: Array = base.duplicate(true)
	change.call(copy)
	check(not ArrivalScheduler.valid_schedule_for_version(copy, 1, roster), "refused: " + label)
