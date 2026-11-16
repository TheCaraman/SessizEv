class_name Roster
extends RefCounted
## The eighteen authored characters (docs/NarrativeBible.md, section 4).
##
## Data only. "tier": 0 principal, 1 secondary, 2 short-arc (K-006).
## "arrival_order" is the order in which they are first offered at the door;
## Lily arrives with Noah. "can_be_infected" is false only for Lily (K-002).

const NPCS: Array[Dictionary] = [
	{"id": "elena_ward", "name": "Elena Ward", "age": 35, "tier": 0, "arrival_order": 1, "can_be_infected": true},
	{"id": "marcus_hale", "name": "Marcus Hale", "age": 47, "tier": 0, "arrival_order": 2, "can_be_infected": true},
	{"id": "arthur_bell", "name": "Arthur Bell", "age": 61, "tier": 0, "arrival_order": 3, "can_be_infected": true},
	{"id": "noah_reed", "name": "Noah Reed", "age": 30, "tier": 0, "arrival_order": 4, "can_be_infected": true},
	{"id": "lily_reed", "name": "Lily Reed", "age": 9, "tier": 0, "arrival_order": 4, "can_be_infected": false},
	{"id": "maya_collins", "name": "Maya Collins", "age": 26, "tier": 0, "arrival_order": 5, "can_be_infected": true},
	{"id": "grace_miller", "name": "Grace Miller", "age": 42, "tier": 2, "arrival_order": 6, "can_be_infected": true},
	{"id": "victor_shaw", "name": "Victor Shaw", "age": 45, "tier": 1, "arrival_order": 7, "can_be_infected": true},
	{"id": "sophie_lane", "name": "Sophie Lane", "age": 24, "tier": 1, "arrival_order": 8, "can_be_infected": true},
	{"id": "samuel_price", "name": "Samuel Price", "age": 39, "tier": 1, "arrival_order": 9, "can_be_infected": true},
	{"id": "olivia_hart", "name": "Olivia Hart", "age": 28, "tier": 1, "arrival_order": 10, "can_be_infected": true},
	{"id": "ruth_bennett", "name": "Ruth Bennett", "age": 68, "tier": 1, "arrival_order": 11, "can_be_infected": true},
	{"id": "caleb_ross", "name": "Caleb Ross", "age": 37, "tier": 1, "arrival_order": 12, "can_be_infected": true},
	{"id": "ethan_brooks", "name": "Ethan Brooks", "age": 23, "tier": 2, "arrival_order": 13, "can_be_infected": true},
	{"id": "peter_dawson", "name": "Peter Dawson", "age": 54, "tier": 2, "arrival_order": 14, "can_be_infected": true},
	{"id": "clara_finch", "name": "Clara Finch", "age": 19, "tier": 2, "arrival_order": 15, "can_be_infected": true},
	{"id": "june_parker", "name": "June Parker", "age": 33, "tier": 2, "arrival_order": 16, "can_be_infected": true},
	{"id": "henry_cole", "name": "Henry Cole", "age": 57, "tier": 2, "arrival_order": 17, "can_be_infected": true},
]

## Characters with an arrival_order at or below this are "the first six
## visitor offers" for the infection constraint (K-005).
const EARLY_ARRIVAL_LIMIT: int = 6


static func get_npc(id: String) -> Dictionary:
	for npc: Dictionary in NPCS:
		if npc["id"] == id:
			return npc
	return {}


## Display name for [param id]; names are proper nouns and are not translated.
static func get_display_name(id: String) -> String:
	return get_npc(id).get("name", id)


static func get_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for npc: Dictionary in NPCS:
		ids.append(npc["id"])
	return ids
