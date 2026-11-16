class_name Isolation
extends RefCounted

const RULES: String = "res://resources/events/isolation.json"
var _expected: Dictionary = {}
var _choice: String = ""

func cancel() -> void:
	_expected = {}
	_choice = ""

func occupant() -> String:
	for id: String in GameState.get_residents():
		if GameState.npcs[id].get("isolated", false):
			return id
	return ""

func actions(room: String) -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	if GameState.day != 4 or GameState.visitor != "":
		return list
	var id: String = occupant()
	if room == "isolation":
		if not GameState.get_flag("isolation_ready", false):
			list.append({"id": "prepare", "label": TranslationServer.translate("ISO_PREPARE")})
		elif id != "":
			list.append({"id": "care:" + id, "label": TranslationServer.translate("ISO_CARE_ACTION").format({"name": Roster.get_display_name(id)})})
			list.append({"id": "release:" + id, "label": TranslationServer.translate("ISO_RELEASE").format({"name": Roster.get_display_name(id)})})
		return list
	if id == "" and GameState.get_flag("isolation_ready", false):
		var judgment := ResidentJudgment.new()
		for target: String in judgment.targets(room):
			if GameState.get_bed_of(target) != "":
				list.append({"id": "place:" + target, "label": TranslationServer.translate("ISO_PLACE").format({"name": Roster.get_display_name(target)})})
	return list

func perform(room: String, choice: String) -> String:
	var allowed: bool = false
	for action: Dictionary in actions(room):
		if action["id"] == choice:
			allowed = true
	if not allowed:
		cancel()
		return ""
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	var operation: String = choice.get_slice(":", 0)
	var target: String = choice.get_slice(":", 1)
	if operation == "care" and GameState.get_flag(care_marker(target), false):
		cancel()
		return care_text(target, rules)
	var minutes: int = int(rules[operation + "_minutes"])
	if GameState.minutes + minutes > GameState.LAST_MINUTE:
		cancel()
		return TranslationServer.translate("POWER_TOO_LATE")
	if operation == "prepare" and int(GameState.resources["repair"]) < int(rules["prepare_repair"]):
		cancel()
		return TranslationServer.translate("ISO_NO_MATERIALS")
	var now: Dictionary = GameState.to_dict()
	if _choice != choice or _expected != now:
		_choice = choice
		_expected = now
		return TranslationServer.translate("ISO_CONFIRM_" + operation.to_upper()).format({"name": Roster.get_display_name(target) if target != "" else "", "minutes": minutes})
	var candidate: Dictionary = now.duplicate(true)
	candidate["minutes"] += minutes
	var sequence: int = int(candidate["flags"].get("isolation_sequence", 0)) + 1
	candidate["flags"]["isolation_sequence"] = sequence
	if operation == "prepare":
		candidate["flags"]["isolation_ready"] = true
		candidate["resources"]["repair"] -= int(rules["prepare_repair"])
	elif operation == "care":
		candidate["flags"][care_marker(target)] = true
	else:
		candidate["npcs"][target]["isolated"] = operation == "place"
		if operation == "place":
			candidate["flags"][care_marker(target)] = true
			candidate["jobs"].erase(target)
			var marker: String = "isolation_first_" + target
			if not candidate["flags"].get(marker, false):
				candidate["npcs"][target]["trust"] = maxi(-100, int(candidate["npcs"][target]["trust"]) + int(rules["first_trust"]))
				candidate["flags"][marker] = true
	var result: Error = SaveManager.commit_candidate(now, candidate, "isolation-" + str(sequence))
	cancel()
	if result != OK:
		return TranslationServer.translate("JUDGMENT_SAVE_FAILED")
	if operation in ["place", "care"]:
		return care_text(target, rules)
	return TranslationServer.translate("ISO_DONE_" + operation.to_upper())

func care_marker(id: String) -> String:
	return "isolation_care_day_%d_%s" % [GameState.day, id]

func care_text(id: String, rules: Dictionary) -> String:
	return TranslationServer.translate("ISO_CARE_DONE") + "\n\n" + Roster.get_display_name(id) + ": " + TranslationServer.translate(rules["care_keys"][id])
