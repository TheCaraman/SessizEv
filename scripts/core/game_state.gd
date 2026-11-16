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

## Version 2 added beds, resolved_arrivals and visitor_arrival
## (docs/Day2Design.md, section 10). Version 1 saves are migrated on load.
const SAVE_VERSION: int = 2
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
	campaign_seed = seed_value
	day = 1
	minutes = DAY_START
	flags = {}
	visitor = ""
	visitor_arrival = ""
	beds = {}
	resolved_arrivals = []
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
	if minute_of_day >= NIGHT_START or minute_of_day < DAY_START:
		return Phase.NIGHT
	if minute_of_day >= EVENING_START:
		return Phase.EVENING
	if minute_of_day >= AFTERNOON_START:
		return Phase.AFTERNOON
	return Phase.MORNING


## Clock text such as "18:05".
func get_clock_text() -> String:
	return "%02d:%02d" % [minutes / 60, minutes % 60]


## Moves the clock forward. The day only changes through start_next_day();
## the clock stops at 23:59 until then.
func advance_minutes(amount: int) -> void:
	if amount <= 0:
		return
	var before: Phase = get_phase()
	minutes = mini(minutes + amount, LAST_MINUTE)
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


## Ids of the residents who sleep in [param room_id].
func get_room_occupants(room_id: String) -> Array[String]:
	var occupants: Array[String] = []
	for id: String in get_residents():
		if npcs[id]["room"] == room_id:
			occupants.append(id)
	return occupants


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
func start_next_day() -> void:
	var people: int = get_headcount()
	for resource: String in ["food", "water"]:
		var have: int = int(resources[resource])
		if have < people:
			set_flag("shortage_%s_day_%d" % [resource, day + 1], people - have)
		resources[resource] = maxi(have - people, 0)
	player["energy"] = 100
	day += 1
	minutes = DAY_START
	EventBus.resources_changed.emit()
	EventBus.day_started.emit(day)
	EventBus.time_changed.emit(day, minutes)
	EventBus.phase_changed.emit(get_phase())


# --- Saving -----------------------------------------------------------------

func to_dict() -> Dictionary:
	return {
		"campaign_seed": campaign_seed,
		"day": day,
		"minutes": minutes,
		"flags": flags.duplicate(true),
		"resources": resources.duplicate(true),
		"player": player.duplicate(true),
		"npcs": npcs.duplicate(true),
		"beds": beds.duplicate(true),
		"resolved_arrivals": resolved_arrivals.duplicate(),
		"visitor": visitor,
		"visitor_arrival": visitor_arrival,
	}


## Restores state from a dictionary made by to_dict(), including one that has
## been through JSON (where every number comes back as a float) and one from
## save version 1 (which had no beds or visit records).
func from_dict(data: Dictionary) -> void:
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
		npcs[id] = {
			"status": str(entry.get("status", "unknown")),
			"infected": bool(entry.get("infected", false)),
			"trust": int(entry.get("trust", 0)),
			"room": str(entry.get("room", "")),
		}

	beds = {}
	resolved_arrivals = []
	if data.has("beds"):
		for bed_id: String in data["beds"]:
			beds[bed_id] = str(data["beds"][bed_id])
		for arrival_id: Variant in data.get("resolved_arrivals", []):
			resolved_arrivals.append(str(arrival_id))
	else:
		_migrate_from_version_1()

	active = true
	EventBus.day_started.emit(day)
	EventBus.time_changed.emit(day, minutes)
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
