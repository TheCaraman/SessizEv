class_name Accusation
extends RefCounted
const RULES: String = "res://resources/events/accusation.json"
const RECORDS: String = "day4_accusations"
var shelter: ShelterManager

func targets(room: String) -> Array[String]:
	var result: Array[String] = []
	if not Day4Review.available() or GameState.visitor != "" or shelter == null:
		return result
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	for id: String in rules["responses"]:
		if GameState.get_status(id) != "resident" or GameState.get_location(id) != room:
			continue
		var available: bool = true
		for flag: String in ["absent", "injured", "incapacitated", "busy"]:
			if GameState.npcs[id].get(flag, false):
				available = false
		var job: Dictionary = GameState.jobs.get(id, {})
		if int(job.get("day", 0)) == GameState.day and ((job.get("job") == "night_watch" and GameState.minutes >= GameState.NIGHT_START) or int(job.get("end", 0)) > GameState.minutes):
			available = false
		if available:
			result.append(id)
	return result

func recorded(id: String) -> bool:
	return GameState.get_flag(RECORDS, {}).has(id)

static func basis(state: Dictionary) -> Array[Dictionary]:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	var result: Array[Dictionary] = []
	for entry: Dictionary in state["evidence"]:
		if entry.get("key") in rules["basis_keys"]:
			result.append(entry.duplicate(true))
	return result

static func supported(id: String, selected: Array, state: Dictionary) -> bool:
	var night: Variant = state["flags"].get("night_witness_record", {})
	if not night is Dictionary or night.get("subject") != id or state["flags"].get("witness_interview_observer") != true:
		return false
	for entry: Dictionary in basis(state):
		if entry["id"] in selected and entry["key"] == "WITNESS_OBSERVER":
			return true
	return false

func quote(room: String, id: String, selected: Array) -> Dictionary:
	if id not in targets(room) or recorded(id):
		return {}
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	if GameState.minutes + int(rules["minutes"]) > GameState.get_action_time_limit():
		return {}
	var state: Dictionary = GameState.to_dict()
	var available: Array = []
	for entry: Dictionary in basis(state):
		available.append(entry["id"])
	var chosen: Array = []
	for value: Variant in selected:
		if not value is String or value not in available or value in chosen:
			return {}
		chosen.append(value)
	chosen.sort()
	return {"expected": state, "room": room, "target": id, "basis_ids": chosen, "unsupported": not supported(id, chosen, state), "minutes": int(rules["minutes"]), "trust_delta": int(rules["trust_delta"])}

func commit(offer: Dictionary) -> Error:
	if offer.is_empty() or offer.get("expected") != GameState.to_dict():
		return ERR_BUSY
	var current: Dictionary = quote(str(offer.get("room", "")), str(offer.get("target", "")), offer.get("basis_ids", []))
	if current.is_empty() or current != offer:
		return ERR_UNAVAILABLE
	var candidate: Dictionary = offer["expected"].duplicate(true)
	var id: String = offer["target"]
	var before: int = int(candidate["npcs"][id]["trust"])
	var after: int = maxi(-100, before + int(offer["trust_delta"]))
	candidate["minutes"] += int(offer["minutes"])
	candidate["npcs"][id]["trust"] = after
	var record: Dictionary = {"target": id, "day": 4, "started_at": GameState.minutes, "completed_at": candidate["minutes"], "room": offer["room"], "basis_ids": offer["basis_ids"].duplicate(), "unsupported": offer["unsupported"], "trust_before": before, "trust_after": after}
	if not candidate["flags"].has(RECORDS):
		candidate["flags"][RECORDS] = {}
	candidate["flags"][RECORDS][id] = record
	var key: String = "ACC_CLAIM_UNSUPPORTED" if offer["unsupported"] else "ACC_CLAIM_TESTIMONY"
	if not EvidenceManager.collect_into(candidate["evidence"], "day4_accusation_" + id, key, "claim", {"name": Roster.get_display_name(id)}):
		return ERR_INVALID_DATA
	shelter.project_daytime(candidate, int(candidate["minutes"]))
	return SaveManager.commit_candidate(offer["expected"], candidate, "day4-accuse-" + id)

func response(id: String) -> String:
	if not recorded(id):
		return ""
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	return Roster.get_display_name(id) + ": " + TranslationServer.translate(rules["responses"][id])

static func valid_state(state: Dictionary) -> bool:
	if not state["flags"].has(RECORDS):
		return true
	var records: Variant = state["flags"][RECORDS]
	if not records is Dictionary or int(state["day"]) < 4:
		return false
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	for id: Variant in records:
		var record: Variant = records[id]
		if id not in rules["responses"] or not record is Dictionary or record.get("target") != id or record.get("day") != 4:
			return false
		for key: String in ["started_at", "completed_at", "trust_before", "trust_after"]:
			if not NightObservation.whole(record.get(key)):
				return false
		if record["started_at"] < 420 or record["completed_at"] != record["started_at"] + rules["minutes"] or record["completed_at"] > 1439:
			return false
		if int(state["day"]) == 4 and record["completed_at"] > state["minutes"]:
			return false
		if record.get("room") not in ["guest_a", "guest_b", "multipurpose", "isolation"] or record["trust_before"] < -100 or record["trust_before"] > 100 or record["trust_after"] != maxf(-100, record["trust_before"] + rules["trust_delta"]):
			return false
		if not record.get("basis_ids") is Array or not record.get("unsupported") is bool:
			return false
		var known: Dictionary = {}
		for entry: Dictionary in basis(state):
			known[entry["id"]] = entry
		var used: Array = []
		for source: Variant in record["basis_ids"]:
			if not source is String or source not in known or source in used:
				return false
			var entry: Dictionary = known[source]
			if not NightObservation.whole(entry.get("day")) or not NightObservation.whole(entry.get("minutes")) or entry["day"] > 4 or (entry["day"] == 4 and entry["minutes"] > record["started_at"]):
				return false
			used.append(source)
		if record["unsupported"] != (not supported(id, used, state)):
			return false
		var claim_found: bool = false
		for entry: Dictionary in state["evidence"]:
			if entry.get("id") == "day4_accusation_" + id:
				var key: String = "ACC_CLAIM_UNSUPPORTED" if record["unsupported"] else "ACC_CLAIM_TESTIMONY"
				claim_found = entry.get("key") == key and entry.get("kind") == "claim"
		if not claim_found:
			return false
	return true
