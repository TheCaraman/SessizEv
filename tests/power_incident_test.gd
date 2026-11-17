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
	for condition: Dictionary in [{"trust": -40}, {"trust": -41}, {"tired": true}, {"energy": 20}, {"energy": 0}]:
		prepare(91)
		GameState.admit("marcus_hale", "guest_a_1")
		for key: String in condition:
			GameState.npcs["marcus_hale"][key] = condition[key]
		check(power.eligible("marcus_hale"), "unwilling helper still physically eligible " + str(condition))
		check(not power.can_help_repair("marcus_hale"), "helper refusal " + str(condition))
		power.trigger()
		GameState.power_incident["cause"] = "loose_connection"
		power.repair(true)
		check(GameState.minutes == 1415 and GameState.power_incident["repair"]["helper"] == "", "solo fallback " + str(condition))
	for infected: bool in [false, true]:
		prepare(91)
		GameState.admit("marcus_hale", "guest_a_1")
		GameState.npcs["marcus_hale"]["infected"] = infected
		GameState.npcs["marcus_hale"]["trust"] = -39
		GameState.npcs["marcus_hale"]["energy"] = 21
		check(power.can_help_repair("marcus_hale"), "willing helper regardless of infection")
		power.trigger()
		GameState.power_incident["cause"] = "loose_connection"
		power.repair(true)
		check(GameState.minutes == 1405, "helper duration at willingness boundary")
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
	for cause: String in ["loose_connection", "grid_outage"]:
		prepare(91)
		GameState.admit("marcus_hale", "guest_a_1")
		power.trigger()
		GameState.power_incident["cause"] = cause
		var quote: Dictionary = director.power.repair_quote()
		check(quote["minutes"] == 25 and quote["helper"] == "marcus_hale", "exact helper quote")
		var confirmation: String = director.perform_room_action("utility", "power:repair")
		check(confirmation.contains("25") and GameState.minutes == 1380, "first press shows exact cost without spending")
		GameState.npcs["marcus_hale"]["tired"] = true
		var before_requote: Dictionary = GameState.to_dict()
		confirmation = director.perform_room_action("utility", "power:repair")
		check(confirmation.contains("35") and GameState.to_dict() == before_requote, "changed helper requires new confirmation")
		var cost_resource: String = director.power.repair_quote()["resource"]
		var before_resource: int = GameState.resources[cost_resource]
		director.perform_room_action("utility", "power:repair")
		check(GameState.minutes == 1415 and GameState.resources[cost_resource] == before_resource - 1, "confirmed quote spends exact resource and time")
		check(GameState.power_incident["repair"]["helper"] == "", "declined helper never attributed")
	for version: int in [1, 2, 3]:
		prepare(version)
		GameState.minutes = 1200
		var legacy: Dictionary = GameState.to_dict()
		legacy.erase("power_incident")
		legacy.erase("evidence")
		# Old saves had no stored timetable; they keep the fixed one.
		legacy.erase("arrival_schedule")
		legacy.erase("arrival_schedule_version")
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
	var night_energy: float = daylight.light_energy
	check(night_energy > 0.0 and night_energy < 0.5, "night window remains weakly lit")
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	check(is_equal_approx(daylight.light_energy, night_energy), "repeated clock event does not compound dimming")
	var saved_minutes: int = GameState.minutes
	GameState.minutes = 720
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	check(daylight.light_energy > night_energy * 5.0, "daytime exterior light stronger than night during outage")
	GameState.minutes = saved_minutes
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	check(is_equal_approx(daylight.light_energy, night_energy), "return to night restores exact light energy")
	check(scene.get_node("Player/EmergencyNavigation").light_energy > 0, "accessible emergency light")
	var key := InputEventAction.new()
	key.action = "journal"
	key.pressed = true
	scene._unhandled_input(key)
	check(not scene.get_node("Player").control_enabled, "journal blocks movement")
	var journal: JournalView = scene._journal
	check(journal.visible, "journal opens")
	var journal_backdrop: ColorRect = journal.get_node("ModalBackdrop")
	check(journal_backdrop.color.a == 1.0 and journal_backdrop.mouse_filter == Control.MOUSE_FILTER_STOP, "journal fully covers lower HUD and blocks clicks")
	check(journal_backdrop.anchor_left == 0.0 and journal_backdrop.anchor_top == 0.0 and journal_backdrop.anchor_right == 1.0 and journal_backdrop.anchor_bottom == 1.0, "journal backdrop fills viewport")
	var journal_panel: PanelContainer = journal.get_node("JournalPanel")
	check((journal_panel.get_theme_stylebox("panel") as StyleBoxFlat).bg_color.a == 1.0, "journal panel opaque")
	journal.close()
	check(scene.get_node("Player").control_enabled, "journal restores control")
	scene.get_node("RoomView").open("utility")
	var lit_room: RoomView = scene.get_node("RoomView")
	check(lit_room._character_layer.modulate == lit_room.get_prop_layer().modulate and lit_room._character_layer.modulate.r < 1.0, "outage figures and props share dimmed actor lighting")
	check(lit_room._background.modulate == Color.WHITE, "authored outage background is not darkened twice")
	check(lit_room._title.modulate == Color.WHITE, "outage leaves UI readable")
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
