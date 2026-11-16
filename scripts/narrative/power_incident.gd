class_name PowerIncident
extends Node
signal power_changed(powered: bool)
## Scene-local authored incident. Hidden records never enter journal data.
var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/events/day3_power.json"))

func pending() -> bool:
	return GameState.day == int(definition["day"]) and GameState.power_incident.is_empty()

func is_powered() -> bool:
	return GameState.power_incident.get("state", "") != "outage"

func eligible(id: String) -> bool:
	if not id in definition["participants"] or GameState.get_status(id) != "resident":
		return false
	var person: Dictionary = GameState.npcs[id]
	for flag: String in ["isolated", "injured", "incapacitated", "absent"]:
		if person.get(flag, false):
			return false
	if person.get("access_locked", false) or GameState.get_flag("utility_locked") or "utility" in person.get("blocked_rooms", []):
		return false
	var job: Dictionary = GameState.jobs.get(id, {})
	return job.is_empty() or int(job.get("day", 0)) != GameState.day or (str(job.get("job", "")) != "night_watch" and int(job.get("end", 0)) <= GameState.minutes)

## Willing assistance is separate from the physical opportunity for sabotage.
## Infection never determines whether a resident can help with repairs.
func can_help_repair(id: String) -> bool:
	if not eligible(id):
		return false
	var person: Dictionary = GameState.npcs[id]
	return int(person.get("trust", 0)) > ShelterManager.REFUSAL_TRUST and not person.get("tired", false) and int(person.get("energy", 100)) > 20

func trigger() -> void:
	if not pending():
		return
	var snapshot: Dictionary = {}
	var actors: Array[String] = []
	var ids: Array = definition["participants"].duplicate()
	ids.sort()
	for id: String in ids:
		var allowed: bool = eligible(id)
		snapshot[id] = {"eligible": allowed, "status": GameState.get_status(id), "infected": GameState.npcs.get(id, {}).get("infected", false), "location": GameState.get_location(id), "person": GameState.npcs.get(id, {}).duplicate(true), "job": GameState.jobs.get(id, {}).duplicate(true)}
		if allowed and GameState.npcs[id].get("infected", false):
			actors.append(id)
	var causes: Array[String] = ["loose_connection", "grid_outage"]
	if not actors.is_empty() and GameState.get_flag("heard_memory_loss_report"):
		causes.append("sabotage")
	var rng := RandomNumberGenerator.new()
	rng.seed = GameState.campaign_seed ^ int(str(definition["id"]).hash())
	var cause: String = causes[rng.randi_range(0, causes.size() - 1)]
	var actor: String = actors[rng.randi_range(0, actors.size() - 1)] if cause == "sabotage" else ""
	GameState.power_incident = {"state": "outage", "cause": cause, "actor": actor, "day": 3, "minutes": 1380, "snapshot": snapshot, "movement": {"actor": actor, "from": GameState.get_location(actor), "to": "utility", "access": "unlocked_route", "minutes": 1380} if actor != "" else {}, "motive": "interrupt_communications_after_warning" if actor != "" else "", "inspected": []}
	EvidenceManager.collect("power_failure", "POWER_WAKE")
	power_changed.emit(false)
	EventBus.notice_requested.emit(tr("POWER_WAKE"))
	SaveManager.save_game()

func inspect(which: String) -> String:
	if not GameState.power_incident.has("cause") or not definition["costs"].has(which):
		return ""
	var record: Dictionary = GameState.power_incident
	var key: String = definition["causes"][record["cause"]][which]
	if not which in record["inspected"]:
		var duration: int = int(definition["costs"][which])
		if GameState.minutes + duration > GameState.get_action_time_limit():
			return tr("POWER_TOO_LATE")
		record["inspected"].append(which)
		GameState.advance_minutes(duration)
		EvidenceManager.collect("power_" + which, key)
		if which == "panel" and record["cause"] == "sabotage":
			EvidenceManager.collect("power_interference", "POWER_INTERFERENCE", "suspicion")
		SaveManager.save_game()
	return tr(key) + "\n" + tr("POWER_LIMIT")

func repair_quote() -> Dictionary:
	if is_powered():
		return {}
	var helper: String = "marcus_hale" if can_help_repair("marcus_hale") else ""
	return {"resource": definition["causes"][GameState.power_incident["cause"]]["resource"], "helper": helper, "minutes": int(definition["helper_minutes"] if helper != "" else definition["solo_minutes"])}

func repair_label() -> String:
	var quote: Dictionary = repair_quote()
	if quote.is_empty():
		return tr("POWER_ALREADY")
	return tr("POWER_EXACT_FUEL" if quote["resource"] == "fuel" else "POWER_EXACT_REPAIR").format(quote)

func repair(confirmed: bool = false) -> String:
	if is_powered():
		return tr("POWER_ALREADY")
	if not confirmed:
		return repair_label() + "\n" + tr("POWER_HELPER_MARCUS" if can_help_repair("marcus_hale") else "POWER_HELPER_SOLO") + "\n" + tr("POWER_CONFIRM")
	var quote: Dictionary = repair_quote()
	var resource: String = quote["resource"]
	var helper: String = quote["helper"]
	var duration: int = quote["minutes"]
	if GameState.minutes + duration > GameState.get_action_time_limit():
		return tr("POWER_TOO_LATE")
	if int(GameState.resources.get(resource, 0)) < 1:
		return tr("POWER_NO_RESOURCE")
	GameState.resources[resource] -= 1
	GameState.power_incident["state"] = "restored"
	GameState.power_incident["repair"] = {"helper": helper, "resource": resource, "day": GameState.day, "minutes": GameState.minutes}
	power_changed.emit(true)
	GameState.advance_minutes(duration)
	EventBus.resources_changed.emit()
	EvidenceManager.collect("power_restored", "POWER_RESTORED")
	SaveManager.save_game()
	return tr("POWER_RESTORED")
