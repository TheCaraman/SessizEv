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
	var result: Error = SaveManager.commit_candidate(now, candidate, "day4-expel-" + id)
	cancel()
	if result != OK:
		return TranslationServer.translate("JUDGMENT_SAVE_FAILED")
	return TranslationServer.translate("JUDGMENT_EXPELLED").format({"name": Roster.get_display_name(id)})
