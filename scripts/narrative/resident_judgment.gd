class_name ResidentJudgment
extends RefCounted

const RULES: String = "res://resources/events/resident_judgment.json"
var _expected: Dictionary = {}
var _target: String = ""

func cancel() -> void:
	_expected = {}
	_target = ""

func targets(room: String) -> Array[String]:
	var found: Array[String] = []
	if GameState.day != 4 or GameState.visitor != "":
		return found
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	for id: String in rules["eligible_adults"]:
		if GameState.get_status(id) != "resident" or GameState.get_location(id) != room:
			continue
		var eligible: bool = true
		for flag: String in ["absent", "isolated", "incapacitated", "injured"]:
			if GameState.npcs[id].get(flag, false):
				eligible = false
		if eligible:
			found.append(id)
	return found

func memory_key(witness: String, subject: String) -> String:
	return "memory_" + witness + "_saw_expulsion_" + subject

func memories(room: String) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	for witness: String in targets(room):
		for subject: String in rules["eligible_adults"]:
			if GameState.get_flag(memory_key(witness, subject), false):
				entries.append({"witness": witness, "subject": subject})
	return entries

func discuss(room: String, witness: String, subject: String) -> String:
	for entry: Dictionary in memories(room):
		if entry["witness"] == witness and entry["subject"] == subject:
			var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
			return Roster.get_display_name(witness) + ": " + TranslationServer.translate(rules["witness_keys"][witness]).format({"name": Roster.get_display_name(subject)})
	return ""

func expel(room: String, id: String) -> String:
	if not targets(room).has(id):
		cancel()
		return ""
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	var minutes: int = int(rules["expel_minutes"])
	if GameState.minutes + minutes > GameState.LAST_MINUTE:
		cancel()
		return TranslationServer.translate("POWER_TOO_LATE")
	var now: Dictionary = GameState.to_dict()
	if _target != id or _expected != now:
		_target = id
		_expected = now
		return TranslationServer.translate("JUDGMENT_EXPEL_CONFIRM").format({"name": Roster.get_display_name(id), "minutes": minutes})
	var candidate: Dictionary = now.duplicate(true)
	candidate["minutes"] += minutes
	candidate["npcs"][id]["status"] = "expelled"
	candidate["npcs"][id]["room"] = ""
	candidate["npcs"][id]["trust"] = maxi(-100, int(candidate["npcs"][id]["trust"]) + int(rules["expel_trust"]))
	candidate["jobs"].erase(id)
	for bed: String in candidate["beds"].keys():
		if candidate["beds"][bed] == id:
			candidate["beds"].erase(bed)
	candidate["flags"]["day4_expelled_" + id] = true
	candidate["flags"]["memory_" + id + "_expelled_by_daniel"] = true
	# Only residents actually in the room at the decision hear it. Being in
	# the shelter is not omniscient knowledge of everyone else's conversation.
	for witness: String in targets(room):
		if witness != id:
			candidate["flags"][memory_key(witness, id)] = true
	var result: Error = SaveManager.commit_candidate(now, candidate, "day4-expel-" + id)
	cancel()
	if result != OK:
		return TranslationServer.translate("JUDGMENT_SAVE_FAILED")
	return Roster.get_display_name(id) + ": " + TranslationServer.translate(rules["departure_keys"][id]) + "\n\n" + TranslationServer.translate("JUDGMENT_EXPELLED").format({"name": Roster.get_display_name(id)})
