class_name RoomPreferences
extends RefCounted
## Pure social review. ok is input validity, NEVER physical plan approval.
## Caller must separately use ShelterManager.check_plan before applying a plan.

static func evaluate(old_plan: Dictionary, proposed_plan: Dictionary, participants: Dictionary,
		bed_rooms: Dictionary, preferences: Array, ready_content: Dictionary,
		open_conditions: Dictionary) -> Dictionary:
	for table: Dictionary in [ready_content, open_conditions]:
		for key: Variant in table:
			if not _id(key) or not table[key] is bool:
				return _error("INVALID_READINESS")
	for bed: Variant in bed_rooms:
		if not _id(bed) or not _id(bed_rooms[bed]):
			return _error("INVALID_BED_ROOMS")
	for person: Variant in participants:
		if not _id(person) or not participants[person] is Dictionary:
			return _error("INVALID_PARTICIPANT")
		var state: Dictionary = participants[person]
		if not state.get("status") is String or state["status"] not in ["unknown", "resident", "rejected", "left", "expelled", "dead", "isolated", "absent"]:
			return _error("INVALID_STATUS")
		for flag: String in ["isolated", "absent", "alive"]:
			if state.has(flag) and not state[flag] is bool:
				return _error("INVALID_PARTICIPANT_FLAG")
	for plan: Dictionary in [old_plan, proposed_plan]:
		if not plan.get("beds") is Dictionary:
			return _error("INVALID_PLAN_BEDS")
		var beds: Dictionary = plan["beds"]
		for person: Variant in beds:
			if not _id(person) or not participants.has(person) or not _id(beds[person]) or not bed_rooms.has(beds[person]):
				return _error("INVALID_PLAN_BED")
		for person: String in participants:
			if participants[person]["status"] == "resident" and not beds.has(person):
				return _error("MISSING_BED")
		if plan.has("jobs"):
			if not plan["jobs"] is Dictionary:
				return _error("INVALID_PLAN_JOBS")
			for person: Variant in plan["jobs"]:
				if not _id(person) or not participants.has(person) or not plan["jobs"][person] is String:
					return _error("INVALID_PLAN_JOB")
	var seen: Dictionary = {}
	# Validate ALL records before filtering inactive content; malformed data fails closed.
	for entry: Variant in preferences:
		if not entry is Dictionary:
			return _error("INVALID_PREFERENCE")
		var pref: Dictionary = entry
		for field: String in ["id", "speaker_id", "target_id", "kind", "source_ref", "request_key", "objection_key"]:
			if not _id(pref.get(field)):
				return _error("INVALID_PREFERENCE_FIELD")
		if seen.has(pref["id"]):
			return _error("DUPLICATE_PREFERENCE_ID")
		seen[pref["id"]] = true
		if pref["kind"] not in ["share_with", "avoid_with"]:
			return _error("INVALID_KIND")
		if not participants.has(pref["speaker_id"]) or not participants.has(pref["target_id"]) or pref["speaker_id"] == pref["target_id"]:
			return _error("INVALID_PREFERENCE_PARTICIPANT")
		if not pref.get("requires_content") is Array:
			return _error("INVALID_REQUIRED_CONTENT")
		for content: Variant in pref["requires_content"]:
			if not _id(content):
				return _error("INVALID_REQUIRED_CONTENT")
		if not pref.get("condition_id", "") is String:
			return _error("INVALID_CONDITION")
	var results: Array[Dictionary] = []
	for pref: Dictionary in preferences:
		var speaker: String = pref["speaker_id"]
		var target: String = pref["target_id"]
		if not _eligible(participants[speaker]) or not _eligible(participants[target]):
			continue
		var ready: bool = ready_content.get(pref["request_key"], false) and ready_content.get(pref["objection_key"], false)
		for content: String in pref["requires_content"]:
			ready = ready and ready_content.get(content, false)
		var condition: String = pref.get("condition_id", "")
		if not ready or (condition != "" and not open_conditions.get(condition, false)):
			continue
		var old_speaker: String = bed_rooms[old_plan["beds"][speaker]]
		var old_target: String = bed_rooms[old_plan["beds"][target]]
		var new_speaker: String = bed_rooms[proposed_plan["beds"][speaker]]
		var new_target: String = bed_rooms[proposed_plan["beds"][target]]
		var old_met: bool = (old_speaker == old_target) == (pref["kind"] == "share_with")
		var met: bool = (new_speaker == new_target) == (pref["kind"] == "share_with")
		if old_met == met:
			continue
		results.append({"id": pref["id"], "speaker_id": speaker, "target_id": target,
			"kind": pref["kind"], "old_speaker_room": old_speaker, "old_target_room": old_target,
			"new_speaker_room": new_speaker, "new_target_room": new_target,
			"old_satisfied": old_met, "satisfied": met,
			"key": pref["request_key"] if met else pref["objection_key"],
			"args": {"speaker_id": speaker, "target_id": target}})
	results.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return a["id"] < b["id"] if a["speaker_id"] == b["speaker_id"] else a["speaker_id"] < b["speaker_id"])
	return {"ok": true, "error": "", "physical_plan_validated": false, "results": results}

static func _id(value: Variant) -> bool:
	return value is String and not value.strip_edges().is_empty()

static func _eligible(state: Dictionary) -> bool:
	return state["status"] == "resident" and not state.get("isolated", false) and not state.get("absent", false) and state.get("alive", true)

static func _error(code: String) -> Dictionary:
	return {"ok": false, "error": code, "physical_plan_validated": false, "results": []}
