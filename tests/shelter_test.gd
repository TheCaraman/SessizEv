extends Node
var checks: int = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		push_error("FAIL: " + label)
		get_tree().quit(1)
func _ready() -> void:
	_test_room_preferences()
	GameState.new_campaign(123)
	GameState.day = 2
	GameState.admit("elena_ward", "guest_a_1")
	GameState.admit("marcus_hale", "guest_b_1")
	var manager := ShelterManager.new()
	add_child(manager)
	var view := ShelterView.new()
	add_child(view)
	view.setup(manager)
	var original: Dictionary = GameState.to_dict()
	view.open()
	view.set_job("elena_ward", "cooking")
	view.cancel()
	check(GameState.to_dict() == original, "cancel is free")
	var plan: Dictionary = manager.get_current_plan()
	plan.beds.elena_ward = "guest_b_1"
	plan.beds.marcus_hale = "guest_a_1"
	plan.jobs.elena_ward = "cooking"
	check(manager.apply_plan(plan).key == "", "bed swap")
	check(GameState.minutes == 435, "15 minute confirmation")
	check(GameState.get_location("elena_ward") == "kitchen", "activity location")
	check(not GameState.get_room_occupants("guest_b").has("elena_ward"), "no duplicate figure")
	var snapshot: Dictionary = GameState.to_dict()
	plan.beds.marcus_hale = "guest_b_1"
	check(manager.apply_plan(plan).key == "PLAN_BED_TAKEN", "duplicate rejected")
	check(GameState.to_dict() == snapshot, "invalid atomic")
	GameState.advance_minutes(50)
	plan = manager.get_current_plan()
	plan.jobs.elena_ward = "inventory"
	manager.apply_plan(plan)
	check(GameState.reports.is_empty(), "replacement cancels old outcome during confirmation")
	GameState.advance_minutes(60)
	manager.resolve_finished_jobs()
	check(GameState.reports.size() == 1, "one result")
	manager.resolve_finished_jobs()
	check(GameState.reports.size() == 1, "idempotent result")
	GameState.npcs.elena_ward.trust = -40
	check(manager.why_refuses("elena_ward", "cooking").key == "REFUSE_NO_TRUST", "trust refusal")
	GameState.npcs.elena_ward.trust = 0
	GameState.npcs.elena_ward.injured = true
	check(manager.why_refuses("elena_ward", "cooking").key == "REFUSE_INJURED", "injury refusal")
	GameState.npcs.elena_ward.injured = false
	plan = manager.get_current_plan()
	plan.jobs.elena_ward = "security"
	manager.apply_plan(plan)
	GameState.npcs.elena_ward.status = "isolated"
	GameState.advance_minutes(60)
	check(GameState.reports.size() == 1 and not GameState.jobs.has("elena_ward"), "isolation cancels")
	GameState.npcs.elena_ward.status = "resident"
	plan = manager.get_current_plan()
	plan.jobs.elena_ward = "night_watch"
	manager.apply_plan(plan)
	check(manager.resolve_night().size() == 1, "night report")
	check(manager.resolve_night().is_empty(), "night report once")
	GameState.npcs.elena_ward.tired = true
	check(manager.why_refuses("elena_ward", "inventory").key == "REFUSE_TIRED", "fatigue refusal")
	GameState.npcs.elena_ward.tired = false
	GameState.npcs.elena_ward.blocked_rooms = ["pantry"]
	check(manager.why_refuses("elena_ward", "inventory").key == "REFUSE_ACCESS", "access refusal")
	GameState.npcs.elena_ward.blocked_rooms = []
	GameState.resources.food = 0
	check(manager.why_refuses("elena_ward", "cooking").key == "REFUSE_NO_FOOD", "food refusal")
	GameState.resources.food = 10
	var saved: Dictionary = GameState.to_dict()
	GameState.from_dict(JSON.parse_string(JSON.stringify(saved)))
	check(GameState.to_dict() == saved, "save round trip")
	var old: Dictionary = saved.duplicate(true)
	old.erase("jobs")
	old.erase("completed_jobs")
	old.erase("reports")
	GameState.from_dict(old)
	check(GameState.npcs == saved.npcs and GameState.jobs.is_empty(), "migration preserves infection and NPCs")
	var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(session)
	var director: CampaignDirector = session.get_node("CampaignDirector")
	check(director.shelter != null, "scene manager connected")
	director.perform_room_action("daniel_bedroom", "manage")
	check(session.get_node("ShelterView").is_open(), "room action opens management")
	check(not session.get_node("Player").control_enabled, "management blocks walking")
	session.get_node("ShelterView").cancel()
	check(session.get_node("Player").control_enabled, "cancel restores walking")
	print("SHELTER TEST: PASS (%d checks)" % checks)
	get_tree().quit()

func _test_room_preferences() -> void:
	var evaluator: GDScript = preload("res://scripts/shelter/room_preferences.gd")
	var people: Dictionary = {"a": {"status": "resident"}, "b": {"status": "resident"}}
	var rooms: Dictionary = {"a1": "one", "a2": "one", "b1": "two", "b2": "two"}
	var old: Dictionary = {"beds": {"a": "a1", "b": "b1"}, "jobs": {}}
	var next: Dictionary = {"beds": {"a": "a1", "b": "a2"}, "jobs": {}}
	var content: Dictionary = {"TEST_REQUEST": true, "TEST_OBJECTION": true, "fixture": true}
	var conditions: Dictionary = {"observed": true}
	var share: Dictionary = {"id": "z", "speaker_id": "a", "target_id": "b", "kind": "share_with", "requires_content": ["fixture"], "condition_id": "observed", "source_ref": "synthetic", "request_key": "TEST_REQUEST", "objection_key": "TEST_OBJECTION"}
	var avoid: Dictionary = share.duplicate(true)
	avoid["id"] = "a"
	avoid["kind"] = "avoid_with"
	var reverse: Dictionary = share.duplicate(true)
	reverse["id"] = "first"
	reverse["speaker_id"] = "b"
	reverse["target_id"] = "a"
	var prefs: Array = [reverse, share, avoid]
	var inputs: Array = [old, next, people, rooms, prefs, content, conditions]
	var before: Array = inputs.duplicate(true)
	var game_before: Dictionary = GameState.to_dict().duplicate(true)
	var result: Dictionary = evaluator.evaluate(old, next, people, rooms, prefs, content, conditions)
	check(result.ok and not result.physical_plan_validated and result.results.size() == 3, "preferences: conflicting directional requests retained")
	check(result.results[0].id == "a" and result.results[1].id == "z" and result.results[2].speaker_id == "b", "preferences: speaker/id ordering")
	check(not result.results[0].satisfied and result.results[1].satisfied, "preferences: avoid and share outcomes")
	check(result.results[1].key == "TEST_REQUEST" and result.results[0].key == "TEST_OBJECTION", "preferences: authored keys")
	check(inputs == before and GameState.to_dict() == game_before, "preferences: no input or global mutation")
	check(evaluator.evaluate(old, next, people, rooms, [share], content, conditions).results.size() == 1, "preferences: no inferred reciprocal request")
	check(evaluator.evaluate(next, old, people, rooms, [share, avoid], content, conditions).results[0].satisfied, "preferences: separation satisfies avoid")
	check(evaluator.evaluate(old, old, people, rooms, prefs, content, conditions).results.is_empty(), "preferences: unchanged old objection suppressed")
	var swapped: Dictionary = {"beds": {"a": "a2", "b": "a1"}}
	check(evaluator.evaluate(next, swapped, people, rooms, prefs, content, conditions).results.is_empty(), "preferences: same room bed swap suppressed")
	var job_only: Dictionary = old.duplicate(true)
	job_only.jobs = {"a": "synthetic_job"}
	check(evaluator.evaluate(old, job_only, people, rooms, prefs, content, conditions).results.is_empty(), "preferences: job only suppressed")
	var still_apart: Dictionary = {"beds": {"a": "b1", "b": "a1"}}
	check(evaluator.evaluate(old, still_apart, people, rooms, prefs, content, conditions).results.is_empty(), "preferences: old unmet outcome not repeated after room move")
	for person: String in ["a", "b"]:
		for status: String in ["dead", "unknown", "left", "expelled", "isolated", "absent", "rejected"]:
			var unavailable: Dictionary = people.duplicate(true)
			unavailable[person].status = status
			check(evaluator.evaluate(old, next, unavailable, rooms, prefs, content, conditions).results.is_empty(), "preferences: unavailable participant " + person + status)
		for flag: String in ["isolated", "absent", "alive"]:
			var unavailable: Dictionary = people.duplicate(true)
			unavailable[person][flag] = flag != "alive"
			check(evaluator.evaluate(old, next, unavailable, rooms, prefs, content, conditions).results.is_empty(), "preferences: participant flag " + person + flag)
	for missing: String in content:
		var incomplete: Dictionary = content.duplicate(true)
		incomplete.erase(missing)
		check(evaluator.evaluate(old, next, people, rooms, prefs, incomplete, conditions).results.is_empty(), "preferences: missing content " + missing)
	check(evaluator.evaluate(old, next, people, rooms, prefs, content, {}).results.is_empty(), "preferences: missing recorded condition")
	for field: String in ["id", "speaker_id", "target_id", "kind", "source_ref", "request_key", "objection_key", "requires_content", "condition_id"]:
		var broken: Dictionary = share.duplicate(true)
		broken[field] = 17
		var rejected: Dictionary = evaluator.evaluate(old, next, people, rooms, [broken], content, conditions)
		check(not rejected.ok and rejected.results.is_empty(), "preferences: invalid field " + field)
	for replacement: String in ["a", "missing"]:
		var broken: Dictionary = share.duplicate(true)
		broken.target_id = replacement
		check(not evaluator.evaluate(old, next, people, rooms, [broken], content, conditions).ok, "preferences: self or unknown target")
	check(not evaluator.evaluate(old, next, people, rooms, [share, share], content, conditions).ok, "preferences: duplicate id rejected")
	check(not evaluator.evaluate(old, next, people, rooms, [17], content, conditions).ok, "preferences: non-record rejected")
	var unknown_kind: Dictionary = share.duplicate(true)
	unknown_kind.kind = "unknown"
	check(not evaluator.evaluate(old, next, people, rooms, [unknown_kind], content, conditions).ok, "preferences: unknown kind rejected")
	check(not evaluator.evaluate(old, {"beds": []}, people, rooms, prefs, content, conditions).ok, "preferences: invalid beds type")
	check(not evaluator.evaluate(old, next, people, rooms, prefs, {"fixture": 1}, conditions).ok, "preferences: truthy content is not readiness")
	check(not evaluator.evaluate(old, next, people, rooms, prefs, content, {"observed": 1}).ok, "preferences: truthy condition is not recorded true")
	var missing_bed: Dictionary = next.duplicate(true)
	missing_bed.beds.erase("b")
	check(not evaluator.evaluate(old, missing_bed, people, rooms, [], content, conditions).ok, "preferences: missing bed fails even without preferences")
	missing_bed.beds.b = "unknown"
	check(not evaluator.evaluate(old, missing_bed, people, rooms, prefs, content, conditions).ok, "preferences: unknown bed rejected")
	for seed_value: int in [123, 987]:
		var opaque_people: Dictionary = people.duplicate(true)
		opaque_people.a.infected = seed_value == 123
		opaque_people.b.infected = seed_value != 123
		var opaque_plan: Dictionary = next.duplicate(true)
		opaque_plan.seed = seed_value
		check(evaluator.evaluate(old, opaque_plan, opaque_people, rooms, prefs, content, conditions) == result, "preferences: seed and infection ignored")
