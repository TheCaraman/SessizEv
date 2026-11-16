extends Node
## The campaign's saved state (autoload: GameState).
##
## Everything that must survive a save lives here as plain data: the seed,
## the clock, flags, supplies, the player's condition and every character's
## status. Other systems change it only through the methods below, which
## announce changes on EventBus.
##
## Dictionary keys are always String (not StringName) so the state survives
## a round trip through JSON unchanged.

enum Phase { MORNING, AFTERNOON, EVENING, NIGHT }

const SAVE_VERSION: int = 1
## The day starts at 07:00. Times are minutes since midnight.
const DAY_START: int = 7 * 60
const AFTERNOON_START: int = 12 * 60
const EVENING_START: int = 18 * 60
const NIGHT_START: int = 23 * 60
const LAST_MINUTE: int = 23 * 60 + 59

const STARTING_RESOURCES: Dictionary = {
	"food": 12, "water": 14, "medical": 2, "repair": 3, "fuel": 4,
}

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
var npcs: Dictionary = {}
## Id of whoever is waiting at the front door, or "".
var visitor: String = ""


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


func set_visitor(npc_id: String) -> void:
	if visitor == npc_id:
		return
	visitor = npc_id
	EventBus.visitor_changed.emit(visitor)


func get_status(npc_id: String) -> String:
	return npcs.get(npc_id, {}).get("status", "")


## Ids of everyone currently living in the house.
func get_residents() -> Array[String]:
	var residents: Array[String] = []
	for id: String in npcs:
		if npcs[id]["status"] == "resident":
			residents.append(id)
	return residents


## Ids of the residents assigned to sleep in [param room_id].
func get_room_occupants(room_id: String) -> Array[String]:
	var occupants: Array[String] = []
	for id: String in get_residents():
		if npcs[id]["room"] == room_id:
			occupants.append(id)
	return occupants


## Takes a character in and gives them a room.
func admit(npc_id: String, room_id: String) -> void:
	if not npcs.has(npc_id):
		return
	npcs[npc_id]["status"] = "resident"
	npcs[npc_id]["room"] = room_id
	EventBus.residents_changed.emit()


## Records that a character is no longer at the house. [param status] is
## "rejected" (turned away), "left" (gave up waiting), "expelled" or "dead".
func remove_npc(npc_id: String, status: String) -> void:
	if not npcs.has(npc_id):
		return
	npcs[npc_id]["status"] = status
	npcs[npc_id]["room"] = ""
	EventBus.residents_changed.emit()


func change_trust(npc_id: String, delta: int) -> void:
	if npcs.has(npc_id):
		npcs[npc_id]["trust"] = clampi(int(npcs[npc_id]["trust"]) + delta, -100, 100)


## Daily upkeep and the move to 07:00 of the next day. Everyone in the house,
## Daniel included, uses one unit of food and one of water.
func start_next_day() -> void:
	var people: int = 1 + get_residents().size()
	resources["food"] = maxi(int(resources["food"]) - people, 0)
	resources["water"] = maxi(int(resources["water"]) - people, 0)
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
		"visitor": visitor,
	}


## Restores state from a dictionary made by to_dict(), including one that has
## been through JSON (where every number comes back as a float).
func from_dict(data: Dictionary) -> void:
	campaign_seed = int(data.get("campaign_seed", 0))
	day = int(data.get("day", 1))
	minutes = int(data.get("minutes", DAY_START))
	flags = (data.get("flags", {}) as Dictionary).duplicate(true)
	visitor = str(data.get("visitor", ""))

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

	active = true
	EventBus.day_started.emit(day)
	EventBus.time_changed.emit(day, minutes)
	EventBus.visitor_changed.emit(visitor)
	EventBus.residents_changed.emit()
	EventBus.resources_changed.emit()
