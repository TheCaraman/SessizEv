class_name Day4Broadcast
extends RefCounted
## A received announcement is a claim, not verification of a safe destination.
const RULES: String = "res://resources/events/day4_broadcast.json"
const HEARD: String = "day4_evacuation_heard"
const AT: String = "day4_evacuation_heard_at"
const MEMORY: String = "day4_radio_included_memory"
var shelter: ShelterManager

func duration() -> int:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	return 0 if GameState.get_flag(HEARD, false) else int(rules["minutes"])

func label() -> String:
	return TranslationServer.translate("RADIO_D4_REVIEW_ACTION" if GameState.get_flag(HEARD, false) else "RADIO_D4_LISTEN_ACTION").format({"minutes": duration()})

func listen() -> String:
	if not Day4Review.available() or shelter == null or GameState.visitor != "":
		return TranslationServer.translate("RADIO_D4_UNAVAILABLE")
	if GameState.get_flag(HEARD, false):
		return TranslationServer.translate("RADIO_D4_NOTES") + "\n\n" + _body()
	var cost: int = duration()
	if GameState.minutes + cost > GameState.get_action_time_limit():
		return TranslationServer.translate("POWER_TOO_LATE")
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	var expected: Dictionary = GameState.to_dict()
	var candidate: Dictionary = expected.duplicate(true)
	candidate["minutes"] += cost
	candidate["flags"][HEARD] = true
	candidate["flags"][AT] = candidate["minutes"]
	candidate["flags"][MEMORY] = not GameState.get_flag("heard_memory_loss_report", false)
	candidate["flags"]["heard_memory_loss_report"] = true
	candidate["flags"]["radio_day_4"] = true
	if not EvidenceManager.collect_into(candidate["evidence"], rules["id"], rules["claim_key"], "claim"):
		return TranslationServer.translate("NARR_SAVE_FAILED")
	shelter.project_daytime(candidate, int(candidate["minutes"]))
	if SaveManager.commit_candidate(expected, candidate, "day4-evacuation-broadcast") != OK:
		return TranslationServer.translate("NARR_SAVE_FAILED")
	return _body()

func _body() -> String:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	var text: String = TranslationServer.translate(rules["text_key"])
	if GameState.get_flag(MEMORY, false):
		text += "\n\n" + TranslationServer.translate("RADIO_D4_MEMORY_REPEAT") + "\n\n" + TranslationServer.translate("RADIO_D2_MEMORY_LOSS")
	return text

static func valid_state(state: Dictionary) -> bool:
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(RULES))
	var flags: Dictionary = state["flags"]
	for key: String in [HEARD, MEMORY]:
		if flags.has(key) and not flags[key] is bool:
			return false
	var claims: Array[Dictionary] = []
	for entry: Dictionary in state["evidence"]:
		if entry.get("id") == rules["id"]:
			claims.append(entry)
	if not flags.get(HEARD, false):
		return not flags.has(AT) and not flags.has(MEMORY) and claims.is_empty()
	if int(state["day"]) < 4 or not NightObservation.whole(flags.get(AT)) or not flags.has(MEMORY) or flags.get("heard_memory_loss_report") != true or flags.get("radio_day_4") != true:
		return false
	var minute: int = int(flags[AT])
	if minute < 420 + int(rules["minutes"]) or minute > 1439 or (int(state["day"]) == 4 and minute > int(state["minutes"])):
		return false
	if claims.size() != 1:
		return false
	var claim: Dictionary = claims[0]
	return claim.get("kind") == "claim" and claim.get("key") == rules["claim_key"] and claim.get("day") == 4 and NightObservation.whole(claim.get("minutes")) and int(claim["minutes"]) == minute - int(rules["minutes"])
