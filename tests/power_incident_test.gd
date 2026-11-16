extends Node
var failures: int = 0
var checks: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)
func prepare(seed_value: int) -> void:
	GameState.new_campaign(seed_value)
	GameState.day = 3
	GameState.minutes = 1380
func _ready() -> void:
	var power := PowerIncident.new()
	add_child(power)
	for seed_value: int in range(100):
		prepare(seed_value)
		power.trigger()
		check(GameState.power_incident["cause"] != "sabotage", "no residents")
		check(GameState.power_incident["actor"] == "", "no invented actor")
		var record: Dictionary = GameState.power_incident.duplicate(true)
		GameState.from_dict(JSON.parse_string(JSON.stringify(GameState.to_dict())))
		power.trigger()
		check(GameState.power_incident == record, "loaded idempotence")
	for flag: String in ["isolated", "injured", "incapacitated", "absent", "access_locked"]:
		prepare(42)
		GameState.admit("marcus_hale", "guest_a_1")
		GameState.npcs["marcus_hale"][flag] = true
		check(not power.eligible("marcus_hale"), flag)
		GameState.npcs["marcus_hale"]["infected"] = true
		GameState.set_flag("heard_memory_loss_report")
		power.trigger()
		check(GameState.power_incident["actor"] != "marcus_hale", "blocked actor " + flag)
	for status: String in ["dead", "expelled", "left", "unknown"]:
		GameState.npcs["marcus_hale"]["status"] = status
		check(not power.eligible("marcus_hale"), status)
	for cause: String in ["loose_connection", "grid_outage", "sabotage"]:
		prepare(42)
		power.trigger()
		GameState.power_incident["cause"] = cause
		for which: String in ["panel", "access", "outside"]:
			power.inspect(which)
			var minute: int = GameState.minutes
			power.inspect(which)
			check(GameState.minutes == minute, "reread free")
		check(GameState.evidence[1]["key"] == power.definition["causes"][cause]["panel"], "physical evidence")
		var before: Dictionary = GameState.to_dict()
		power.repair(false)
		check(GameState.to_dict() == before, "cancel atomic")
		var resource: String = power.definition["causes"][cause]["resource"]
		GameState.resources[resource] = 0
		before = GameState.to_dict()
		power.repair(true)
		check(GameState.to_dict() == before, "no supplies atomic")
		GameState.resources[resource] = 1
		GameState.minutes = 1430
		before = GameState.to_dict()
		power.repair(true)
		check(GameState.to_dict() == before, "too late atomic")
		GameState.minutes = 420
		GameState.day = 4
		power.repair(true)
		check(power.is_powered() and GameState.resources[resource] == 0, "deferred repair")
		before = GameState.to_dict()
		power.repair(true)
		check(GameState.to_dict() == before, "repair idempotent")
	prepare(42)
	GameState.minutes = 1200
	var dialogue := DialogueRunner.new()
	add_child(dialogue)
	var director := CampaignDirector.new()
	add_child(director)
	director.setup(dialogue)
	var food: int = GameState.resources["food"]
	director.perform_room_action("daniel_bedroom", "sleep")
	check(GameState.day == 3 and GameState.minutes == 1380 and GameState.resources["food"] == food, "sleep interrupted")
	director.perform_room_action("daniel_bedroom", "sleep")
	check(GameState.day == 4 and GameState.resources["food"] == food - 1, "next sleep one consumption")
	prepare(42)
	GameState.minutes = 1360
	director.perform_room_action("daniel_bedroom", "rest")
	check(GameState.minutes == 1380 and GameState.day == 3, "action interrupted")
	var old: Dictionary = GameState.to_dict()
	old.erase("power_incident")
	old.erase("evidence")
	old["day"] = 4
	GameState.from_dict(old)
	check(GameState.power_incident.get("state") == "legacy_skipped", "legacy day4 no retroactive incident")
	check(not EvidenceManager.journal_text().contains("actor"), "hidden actor")
	for seed_value: int in range(80):
		prepare(seed_value)
		GameState.admit("elena_ward", "guest_a_1")
		GameState.admit("marcus_hale", "guest_a_2")
		GameState.npcs["elena_ward"]["infected"] = false
		GameState.npcs["marcus_hale"]["infected"] = false
		GameState.set_flag("heard_memory_loss_report")
		power.trigger()
		check(GameState.power_incident["actor"] == "" and GameState.power_incident["cause"] != "sabotage", "healthy residents never perpetrators")
		GameState.power_incident = {}
		GameState.npcs["elena_ward"]["infected"] = true
		GameState.npcs["marcus_hale"]["infected"] = true
		power.trigger()
		var expected: Dictionary = GameState.power_incident.duplicate(true)
		GameState.power_incident = {}
		var reverse: Dictionary = {}
		var ids: Array = GameState.npcs.keys()
		ids.reverse()
		for id: String in ids:
			reverse[id] = GameState.npcs[id]
		GameState.npcs = reverse
		power.trigger()
		check(GameState.power_incident == expected, "dictionary order deterministic")
		GameState.power_incident = {}
		GameState.set_flag("heard_memory_loss_report", false)
		power.trigger()
		check(GameState.power_incident["cause"] != "sabotage", "broadcast prerequisite")
	prepare(91)
	GameState.admit("marcus_hale", "guest_a_1")
	GameState.jobs["marcus_hale"] = {"day": 3, "start": 1300, "end": 1430, "job": "inventory", "room": "pantry"}
	check(not power.eligible("marcus_hale"), "busy excluded")
	GameState.jobs["marcus_hale"] = {"day": 3, "start": 1200, "end": 1200, "job": "night_watch", "room": ""}
	check(not power.eligible("marcus_hale"), "night watch incompatible")
	GameState.jobs.clear()
	GameState.npcs["marcus_hale"]["blocked_rooms"] = ["utility"]
	check(not power.eligible("marcus_hale"), "room access excluded")
	GameState.npcs["marcus_hale"].erase("blocked_rooms")
	power.trigger()
	GameState.power_incident["cause"] = "loose_connection"
	power.repair(true)
	check(GameState.minutes == 1405 and GameState.power_incident["repair"]["helper"] == "marcus_hale", "eligible Marcus 25 minutes")
	var historical: Dictionary = GameState.power_incident.duplicate(true)
	GameState.remove_npc("marcus_hale", "dead")
	check(GameState.power_incident == historical, "historical record retained")
	prepare(91)
	power.trigger()
	GameState.power_incident["cause"] = "loose_connection"
	power.repair(true)
	check(GameState.minutes == 1415 and GameState.power_incident["repair"]["helper"] == "", "Daniel solo 35 minutes")
	var data: Dictionary = GameState.to_dict()
	check(SaveManager.save_game("power_test") == OK, "manual save")
	check(SaveManager.load_game("power_test"), "manual load")
	check(GameState.to_dict() == data, "manual roundtrip preserves all data")
	SaveManager.delete_save("power_test")
	for version: int in [1, 2, 3]:
		prepare(version)
		GameState.minutes = 1200
		var legacy: Dictionary = GameState.to_dict()
		legacy.erase("power_incident")
		legacy.erase("evidence")
		if version == 1:
			legacy.erase("beds")
		if version < 3:
			legacy.erase("jobs")
		var infection: Dictionary = GameState.npcs.duplicate(true)
		var supplies: Dictionary = GameState.resources.duplicate(true)
		GameState.from_dict(legacy)
		check(GameState.power_incident.is_empty() and GameState.npcs == infection and GameState.resources == supplies, "old save pending without reroll")
	# Real scene: lights, input control and room/dialogue modal exclusion.
	prepare(15)
	GameState.minutes = 1370
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame
	GameState.advance_minutes(60)
	check(GameState.minutes == 1380 and not GameState.power_incident.is_empty(), "direct timed action clamps at event")
	await get_tree().physics_frame
	await get_tree().physics_frame
	for light: Node in get_tree().get_nodes_in_group("electric_lights"):
		check(not light.visible, "real electric light off")
	for fitting: MeshInstance3D in get_tree().get_nodes_in_group("electric_fittings"):
		check(not fitting.material_override.emission_enabled, "lamp glow off")
	var daylight: Node = scene.find_child("Daylight", true, false)
	check(daylight != null and daylight.visible, "window daylight independent")
	check(scene.get_node("Player/EmergencyNavigation").light_energy > 0, "accessible emergency light")
	var key := InputEventAction.new()
	key.action = "journal"
	key.pressed = true
	scene._unhandled_input(key)
	check(not scene.get_node("Player").control_enabled, "journal blocks movement")
	var journal: JournalView = scene._journal
	check(journal.visible, "journal opens")
	journal.close()
	check(scene.get_node("Player").control_enabled, "journal restores control")
	scene.get_node("RoomView").open("utility")
	scene._unhandled_input(key)
	check(not journal.visible, "room excludes journal")
	scene.get_node("RoomView").close()
	GameState.minutes = 420
	GameState.day = 4
	scene.get_node("CampaignDirector").power.repair(true)
	await get_tree().physics_frame
	await get_tree().physics_frame
	for light: Node in get_tree().get_nodes_in_group("electric_lights"):
		check(light.visible, "real electric light restored")
	for fitting: MeshInstance3D in get_tree().get_nodes_in_group("electric_fittings"):
		check(fitting.material_override.emission_enabled, "lamp glow restored")
	check(director.perform_room_action("daniel_bedroom", "sleep").contains(tr("NARR_END_OF_BUILD")) == false, "morning sleep unavailable")
	scene.queue_free()
	if failures == 0:
		print("POWER INCIDENT TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
