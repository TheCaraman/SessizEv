extends Node
## The campaign's saved state (autoload: GameState).
##
## Everything that must survive a save lives here as plain data: the seed,
## the clock, flags, supplies, the player's condition, every character's
## status, who sleeps in which bed and which visits have already happened.
## Other systems change it only through the methods below, which announce
## changes on EventBus.
##
## Dictionary keys are always String (not StringName) so the state survives
## a round trip through JSON unchanged.

enum Phase { MORNING, AFTERNOON, EVENING, NIGHT }

## Version 2 added beds, resolved_arrivals and visitor_arrival; version 3 added
## jobs, completed_jobs and reports (docs/Day2Design.md, section 10).
## Older saves are migrated on load.
const SAVE_VERSION: int = 5
## The day starts at 07:00. Times are minutes since midnight.
const DAY_START: int = 7 * 60
const AFTERNOON_START: int = 12 * 60
const EVENING_START: int = 18 * 60
const NIGHT_START: int = 23 * 60
const LAST_MINUTE: int = 23 * 60 + 59

const STARTING_RESOURCES: Dictionary = {
	"food": 12, "water": 14, "medical": 2, "repair": 3, "fuel": 4,
}

## The six beds available to residents at the start (two in each of three
## rooms). Daniel's own bed is not among them, and the box room has none.
## A bed's room is its id without the trailing number.
const BEDS: Array[String] = [
	"guest_a_1", "guest_a_2", "guest_b_1", "guest_b_2", "multipurpose_1", "multipurpose_2",
]

## True once a campaign has been started or loaded.
var power_incident: Dictionary = {}
var night_session: Dictionary = {}
var evidence: Array[Dictionary] = []
var active: bool = false
var campaign_seed: int = 0
var day: int = 1
var minutes: int = DAY_START
var flags: Dictionary = {}
var resources: Dictionary = {}
var player: Dictionary = {}
## id -> {"status", "infected", "trust", "room"}.
## status: "unknown", "resident", "rejected", "left", "expelled" or "dead".
## "room" is where the character sleeps; it always matches their bed.
var npcs: Dictionary = {}
## bed id -> character id, for occupied beds only.
var beds: Dictionary = {}
## Ids of the visits (resources/events/arrivals.json) that have already
## begun or been missed. A visit never happens twice.
var resolved_arrivals: Array[String] = []
## Work in progress: character id -> {"job", "day", "start", "end", "room"}.
## One job per character. "room" is where they are while working, or "".
var jobs: Dictionary = {}
## Ids of finished jobs ("day:character:job:start"), so none is rewarded twice.
var completed_jobs: Array[String] = []
## What residents have reported: [{"day", "minutes", "npc", "key", "args"}].
var reports: Array[Dictionary] = []
## Id of whoever is waiting at the front door, or "".
var visitor: String = ""
## Id of the visit the waiting person belongs to, or "".
var visitor_arrival: String = ""


## Starts a fresh campaign. A negative seed picks a random one.
func new_campaign(seed_value: int = -1) -> void:
	if seed_value < 0:
		var picker := RandomNumberGenerator.new()
		picker.randomize()
		seed_value = picker.randi()
	power_incident = {}
	night_session = {}
	evidence = []
	campaign_seed = seed_value
	day = 1
	minutes = DAY_START
	flags = {}
	visitor = ""
	visitor_arrival = ""
	beds = {}
	resolved_arrivals = []
	jobs = {}
	completed_jobs = []
	reports = []
	resources = STARTING_RESOURCES.duplicate()
	player = {"energy": 100, "stress": 10, "infection": "healthy"}
	npcs = {}
	var infected: Dictionary = InfectionAssigner.assign(campaign_seed)
	for npc: Dictionary in Roster.NPCS:
		npcs[npc["id"]] = {
			"status": "unknown", "infected": infected[npc["id"]], "trust": 0, "room": "",
		}
	active = true
	EventBus.day_started.emit(day)
	EventBus.time_changed.emit(day, minutes)
	EventBus.visitor_changed.emit(visitor)


func get_phase() -> Phase:
	return phase_for(minutes)


static func phase_for(minute_of_day: int) -> Phase:
	minute_of_day = posmod(minute_of_day, 1440)
	if minute_of_day >= NIGHT_START or minute_of_day < DAY_START:
		return Phase.NIGHT
	if minute_of_day >= EVENING_START:
		return Phase.EVENING
	if minute_of_day >= AFTERNOON_START:
		return Phase.AFTERNOON
	return Phase.MORNING


## Clock text such as "18:05".
func get_clock_text() -> String:
	var clock_minute: int = posmod(minutes, 1440)
	return "%02d:%02d" % [clock_minute / 60, clock_minute % 60]


func night_in_progress() -> bool:
	return not night_session.is_empty() and int(night_session.get("day", 0)) == day and not night_session.get("morning_resolved", false)


func get_action_time_limit() -> int:
	return 1860 if night_in_progress() else LAST_MINUTE


## Moves the clock forward. The day only changes through start_next_day();
## the clock stops at 23:59 until then.
func advance_minutes(amount: int) -> void:
	if amount <= 0:
		return
	var before: Phase = get_phase()
	var ceiling: int = NIGHT_START if day == 3 and power_incident.is_empty() and minutes <= NIGHT_START else get_action_time_limit()
	minutes = mini(minutes + amount, ceiling)
	if night_in_progress():
		var timeline := NightTimeline.new()
		if timeline.from_dict(night_session):
			timeline.advance_to(minutes)
			night_session = timeline.to_dict()
			player["energy"] = timeline.energy()
	EventBus.time_changed.emit(day, minutes)
	if get_phase() != before:
		EventBus.phase_changed.emit(get_phase())


func set_flag(key: String, value: Variant = true) -> void:
	flags[key] = value


func get_flag(key: String, default: Variant = false) -> Variant:
	return flags.get(key, default)


## Puts someone on the doorstep (or clears it with an empty id).
## [param arrival_id] names the visit they belong to.
func set_visitor(npc_id: String, arrival_id: String = "") -> void:
	if visitor == npc_id and visitor_arrival == arrival_id:
		return
	visitor = npc_id
	visitor_arrival = arrival_id if npc_id != "" else ""
	EventBus.visitor_changed.emit(visitor)


## Records that a visit has begun or been missed, so it never repeats.
func resolve_arrival(arrival_id: String) -> void:
	if not resolved_arrivals.has(arrival_id):
		resolved_arrivals.append(arrival_id)


func is_arrival_resolved(arrival_id: String) -> bool:
	return resolved_arrivals.has(arrival_id)


func get_status(npc_id: String) -> String:
	return npcs.get(npc_id, {}).get("status", "")


## Ids of everyone currently living in the house.
func get_residents() -> Array[String]:
	var residents: Array[String] = []
	for id: String in npcs:
		if npcs[id]["status"] == "resident":
			residents.append(id)
	return residents


## Where a resident is right now: at their job while it lasts, otherwise in
## the room they sleep in. Nobody is ever in two rooms at once.
func get_location(npc_id: String) -> String:
	if not npcs.has(npc_id):
		return ""
	if npcs[npc_id].get("isolated", false):
		return "isolation"
	if jobs.has(npc_id):
		var job: Dictionary = jobs[npc_id]
		if (
			str(job["room"]) != "" and int(job["day"]) == day
			and minutes >= int(job["start"]) and minutes < int(job["end"])
		):
			return str(job["room"])
	return str(npcs[npc_id]["room"])


## Ids of the residents who are in [param room_id] right now.
func get_room_occupants(room_id: String) -> Array[String]:
	var occupants: Array[String] = []
	for id: String in get_residents():
		if get_location(id) == room_id:
			occupants.append(id)
	return occupants


## Ids of the residents whose bed is in [param room_id], wherever they are now.
func get_room_sleepers(room_id: String) -> Array[String]:
	var sleepers: Array[String] = []
	for id: String in get_residents():
		if npcs[id]["room"] == room_id:
			sleepers.append(id)
	return sleepers


# --- Beds -------------------------------------------------------------------

## The room a bed is in: "guest_a_2" -> "guest_a".
static func bed_room(bed_id: String) -> String:
	return bed_id.rsplit("_", true, 1)[0]


## The bed's number within its room: "guest_a_2" -> 2.
static func bed_number(bed_id: String) -> int:
	return int(bed_id.rsplit("_", true, 1)[1])


func get_free_beds() -> Array[String]:
	var free: Array[String] = []
	for bed_id: String in BEDS:
		if not beds.has(bed_id):
			free.append(bed_id)
	return free


## The bed a character sleeps in, or "".
func get_bed_of(npc_id: String) -> String:
	for bed_id: String in beds:
		if beds[bed_id] == npc_id:
			return bed_id
	return ""


## Takes a character in and gives them a bed. Returns false, changing
## nothing, if the character or bed is unknown or the bed is taken.
func admit(npc_id: String, bed_id: String) -> bool:
	if not npcs.has(npc_id) or not BEDS.has(bed_id) or beds.has(bed_id):
		return false
	var previous: String = get_bed_of(npc_id)
	if previous != "":
		beds.erase(previous)
	beds[bed_id] = npc_id
	npcs[npc_id]["status"] = "resident"
	npcs[npc_id]["room"] = bed_room(bed_id)
	EventBus.residents_changed.emit()
	return true


## Records that a character is no longer at the house and frees their bed.
## [param status] is "rejected" (turned away), "left" (gave up waiting),
## "expelled" or "dead".
func remove_npc(npc_id: String, status: String) -> void:
	if not npcs.has(npc_id):
		return
	var bed_id: String = get_bed_of(npc_id)
	if bed_id != "":
		beds.erase(bed_id)
	# Unfinished work is abandoned and produces nothing.
	jobs.erase(npc_id)
	npcs[npc_id]["status"] = status
	npcs[npc_id]["room"] = ""
	EventBus.residents_changed.emit()


func change_trust(npc_id: String, delta: int) -> void:
	if npcs.has(npc_id):
		npcs[npc_id]["trust"] = clampi(int(npcs[npc_id]["trust"]) + delta, -100, 100)


# --- Days -------------------------------------------------------------------

## How many people eat and drink tonight: Daniel and every resident.
func get_headcount() -> int:
	return 1 + get_residents().size()


## Daily upkeep and the move to 07:00 of the next day. Everyone in the house
## uses one unit of food and one of water. A shortfall is never hidden: it is
## recorded in flags as "shortage_<resource>_day_<new day>".
func start_next_day(restored_energy: int = 100) -> void:
	# Active nights must be resolved by their owner before consuming supplies.
	if night_in_progress():
		return
	var people: int = get_headcount()
	for resource: String in ["food", "water"]:
		var have: int = int(resources[resource])
		if have < people:
			set_flag("shortage_%s_day_%d" % [resource, day + 1], people - have)
		resources[resource] = maxi(have - people, 0)
	player["energy"] = clampi(restored_energy, 0, 100)
	# Work not finished by the end of the day is dropped.
	jobs = {}
	day += 1
	minutes = DAY_START
	EventBus.resources_changed.emit()
	EventBus.day_started.emit(day)
	EventBus.time_changed.emit(day, minutes)
	EventBus.phase_changed.emit(get_phase())


# --- Saving -----------------------------------------------------------------

func to_dict() -> Dictionary:
	return {
		"night_session": night_session.duplicate(true),
		"power_incident": power_incident.duplicate(true), "evidence": evidence.duplicate(true), "campaign_seed": campaign_seed,
		"day": day,
		"minutes": minutes,
		"flags": flags.duplicate(true),
		"resources": resources.duplicate(true),
		"player": player.duplicate(true),
		"npcs": npcs.duplicate(true),
		"beds": beds.duplicate(true),
		"resolved_arrivals": resolved_arrivals.duplicate(),
		"jobs": jobs.duplicate(true),
		"completed_jobs": completed_jobs.duplicate(),
		"reports": reports.duplicate(true),
		"visitor": visitor,
		"visitor_arrival": visitor_arrival,
	}


## Restores state from a dictionary made by to_dict(), including one that has
## been through JSON (where every number comes back as a float) and one from
## save version 1 (which had no beds or visit records).
func from_dict(data: Dictionary, announce_day: bool = true) -> void:
	night_session = _restore_numbers(data.get("night_session", {}))
	power_incident = _restore_numbers(data.get("power_incident", {}))
	evidence = []
	for entry: Dictionary in data.get("evidence", []):
		evidence.append(_restore_numbers(entry))
	if not data.has("power_incident") and int(data.get("day", 1)) > 3:
		power_incident = {"state": "legacy_skipped"}
	campaign_seed = int(data.get("campaign_seed", 0))
	day = int(data.get("day", 1))
	minutes = int(data.get("minutes", DAY_START))
	flags = (data.get("flags", {}) as Dictionary).duplicate(true)
	# JSON turns whole numbers into floats; flags hold counts as integers.
	for key: String in flags:
		if flags[key] is float and float(int(flags[key])) == flags[key]:
			flags[key] = int(flags[key])
	visitor = str(data.get("visitor", ""))
	visitor_arrival = str(data.get("visitor_arrival", ""))

	resources = {}
	for key: String in data.get("resources", {}):
		resources[key] = int(data["resources"][key])

	player = (data.get("player", {}) as Dictionary).duplicate(true)
	for key: String in ["energy", "stress"]:
		if player.has(key):
			player[key] = int(player[key])

	npcs = {}
	for id: String in data.get("npcs", {}):
		var entry: Dictionary = data["npcs"][id]
		npcs[id] = entry.duplicate(true)
		npcs[id].merge({
			"status": str(entry.get("status", "unknown")),
			"infected": bool(entry.get("infected", false)),
			"trust": int(entry.get("trust", 0)),
			"room": str(entry.get("room", "")),
		}, true)

	beds = {}
	resolved_arrivals = []
	if data.has("beds"):
		for bed_id: String in data["beds"]:
			beds[bed_id] = str(data["beds"][bed_id])
		for arrival_id: Variant in data.get("resolved_arrivals", []):
			resolved_arrivals.append(str(arrival_id))
	else:
		_migrate_from_version_1()

	# Version 3 fields; absent in older saves, where nobody had a job yet.
	jobs = {}
	for id: String in data.get("jobs", {}):
		var job: Dictionary = data["jobs"][id]
		jobs[id] = {
			"job": str(job.get("job", "")), "day": int(job.get("day", 0)),
			"start": int(job.get("start", 0)), "end": int(job.get("end", 0)),
			"room": str(job.get("room", "")),
		}
	completed_jobs = []
	for job_id: Variant in data.get("completed_jobs", []):
		completed_jobs.append(str(job_id))
	reports = []
	for report: Dictionary in data.get("reports", []):
		var args: Dictionary = (report.get("args", {}) as Dictionary).duplicate(true)
		for key: String in args:
			if args[key] is float and float(int(args[key])) == args[key]:
				args[key] = int(args[key])
		reports.append({
			"day": int(report.get("day", 0)), "minutes": int(report.get("minutes", 0)),
			"npc": str(report.get("npc", "")), "key": str(report.get("key", "")), "args": args,
		})

	active = true
	if announce_day:
		EventBus.day_started.emit(day)
	EventBus.time_changed.emit(day, minutes)
	if not announce_day:
		EventBus.phase_changed.emit(get_phase())
	EventBus.visitor_changed.emit(visitor)
	EventBus.residents_changed.emit()
	EventBus.resources_changed.emit()


## Fills in what version 1 did not store, without making any story decision:
## each resident gets the first free bed in the room they already had, and
## Elena's Day 1 visit is marked as done if the old save shows it happened.
## Infection, trust, the clock and every choice are left exactly as saved.
func _migrate_from_version_1() -> void:
	for id: String in npcs:
		if npcs[id]["status"] != "resident":
			continue
		var placed: bool = false
		for bed_id: String in BEDS:
			if bed_room(bed_id) == npcs[id]["room"] and not beds.has(bed_id):
				beds[bed_id] = id
				placed = true
				break
		if not placed:
			push_warning("GameState: no bed for resident '%s' while migrating an old save" % id)
	if get_flag("elena_arrived") or get_status("elena_ward") != "unknown":
		resolved_arrivals.append("d1_elena")
	if visitor == "elena_ward":
		visitor_arrival = "d1_elena"

## JSON stores numbers as floats; preserve recorded timestamps and snapshots.
func _restore_numbers(value: Variant) -> Variant:
	if value is Dictionary:
		var result: Dictionary = {}
		for key: Variant in value:
			result[key] = _restore_numbers(value[key])
		return result
	if value is Array:
		var result: Array = []
		for item: Variant in value:
			result.append(_restore_numbers(item))
		return result
	if value is float and float(int(value)) == value:
		return int(value)
	return value
