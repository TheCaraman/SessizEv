extends Node
var checks: int = 0
var failures: int = 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func fixture(origin: String) -> Dictionary:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NightObservation.RULES))
	var steps: Array = []
	var minute: int = 1501
	for room: String in rules["routes"][origin]:
		steps.append({"room": room, "minute": minute})
		minute += 2
	var seen: int = 1504 if origin == "guest_a" else 1506
	return {"day": 3, "start": 1501, "end": minute - 2, "seen_at": seen,
		"subject": "elena_ward", "observer": "marcus_hale", "subject_reason": "bathroom_visit", "observer_reason": "checking_after_pipe_noise", "denial_reason": "fear_of_accusation",
		"steps": steps, "snapshot": {"elena_ward": {"status": "resident", "route_access": true}, "marcus_hale": {"status": "resident", "route_access": true}},
		"observation": {"room": "corridor", "minute": seen, "awake": true, "sightline": true}}

func _ready() -> void:
	GameState.new_campaign(42)
	var before: Dictionary = GameState.to_dict()
	for origin: String in ["guest_a", "guest_b", "multipurpose"]:
		var record: Dictionary = fixture(origin)
		check(NightObservation.valid(record), "connected authored route " + origin)
		check(NightObservation.valid(JSON.parse_string(JSON.stringify(record))), "JSON numbers accepted " + origin)
		for infected: bool in [false, true]:
			record["snapshot"]["elena_ward"]["infected"] = infected
			check(NightObservation.valid(record), "infection independent " + origin)
	for patch: Dictionary in [{"subject": "lily_reed"}, {"observer": "elena_ward"}, {"subject": "unknown"}, {"day": 4}, {"start": 1490}, {"end": 1860}, {"seen_at": 1501}, {"seen_at": "1504"}, {"steps": []}, {"snapshot": {}}, {"subject_reason": "sabotage"}, {"observer_reason": "just_because"}, {"denial_reason": "infected"}, {"observation": {"room": "corridor", "minute": 1504, "awake": false, "sightline": true}}]:
		var broken: Dictionary = fixture("guest_a")
		broken.merge(patch, true)
		check(not NightObservation.valid(broken), "invalid record rejected " + str(patch.keys()))
	for status: String in ["dead", "expelled", "unknown", "left"]:
		var broken: Dictionary = fixture("guest_a")
		broken["snapshot"]["marcus_hale"]["status"] = status
		check(not NightObservation.valid(broken), "unavailable observer " + status)
	for flag: String in ["isolated", "absent", "injured", "incapacitated", "busy"]:
		var broken: Dictionary = fixture("guest_a")
		broken["snapshot"]["elena_ward"][flag] = true
		check(not NightObservation.valid(broken), "unavailable subject " + flag)
	var locked: Dictionary = fixture("guest_a")
	locked["snapshot"]["elena_ward"]["route_access"] = false
	check(not NightObservation.valid(locked), "blocked route rejected")
	var reordered: Dictionary = fixture("guest_b")
	reordered["steps"][1]["room"] = "utility"
	check(not NightObservation.valid(reordered), "impossible room jump rejected")
	check(GameState.to_dict() == before, "validation never creates live witness flags evidence or infection")
	if failures == 0:
		print("NIGHT OBSERVATION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
