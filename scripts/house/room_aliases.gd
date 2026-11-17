class_name RoomAliases
extends RefCounted
## ROOM-COMPACT-001: rooms merged in the compact plan. Old ids may still turn
## up in saves, data and calls; every entry point maps them to the room that
## now holds that function, so no job, supply check, evidence or location is
## lost. HouseLayout.canonical_room_id (Codex) delegates to canonical().

const ALIASES: Dictionary = {
	"dining": "kitchen",
	"pantry": "utility",
	"bathroom_ground": "bathroom_upper",
}


## The room that now stands for [param room_id] (itself if not merged).
static func canonical(room_id: Variant) -> String:
	var id: String = str(room_id)
	return str(ALIASES.get(id, id))


## Canonical ids for a list, in order, without duplicates.
static func canonical_list(room_ids: Array) -> Array:
	var result: Array = []
	for room_id: Variant in room_ids:
		var id: String = canonical(room_id)
		if not result.has(id):
			result.append(id)
	return result


## Rewrites every room reference in a saved-state dictionary (as made by
## GameState.to_dict) in place. Returns how many references changed.
static func migrate_state(data: Dictionary) -> int:
	var changed: int = 0
	for npc: Variant in (data.get("npcs", {}) as Dictionary).values():
		if npc is Dictionary:
			changed += _fix_key(npc, "room")
			if npc.get("blocked_rooms") is Array:
				var before: Array = npc["blocked_rooms"]
				var after: Array = canonical_list(before)
				if after != before:
					npc["blocked_rooms"] = after
					changed += 1
	for job: Variant in (data.get("jobs", {}) as Dictionary).values():
		if job is Dictionary:
			changed += _fix_key(job, "room")
	for entry: Variant in data.get("evidence", []):
		if entry is Dictionary:
			changed += _fix_key(entry, "room")
	var flags: Variant = data.get("flags", {})
	if flags is Dictionary:
		for key: String in ["night_witness_record", "day4_accusations"]:
			changed += _fix_nested(flags.get(key))
	return changed


static func _fix_key(entry: Dictionary, key: String) -> int:
	if entry.has(key) and ALIASES.has(str(entry[key])):
		entry[key] = canonical(entry[key])
		return 1
	return 0


static func _fix_nested(value: Variant) -> int:
	var changed: int = 0
	if value is Dictionary:
		changed += _fix_key(value, "room")
		for child: Variant in value.values():
			changed += _fix_nested(child)
	elif value is Array:
		for child: Variant in value:
			changed += _fix_nested(child)
	return changed
