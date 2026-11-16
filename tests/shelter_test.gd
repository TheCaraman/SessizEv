extends Node
var checks: int = 0
func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		push_error("FAIL: " + label)
		get_tree().quit(1)
func _ready() -> void:
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
