class_name Day4Closure
extends RefCounted
## The review can end without diagnosing or removing anyone.
var shelter: ShelterManager
var _expected: Dictionary = {}
var _choice: String = ""

func cancel() -> void:
	_expected = {}
	_choice = ""

func actions(room: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if room != "daniel_bedroom" or not Day4Review.available() or GameState.visitor != "" or not GameState.get_flag("day4_reviewed", false):
		return result
	if GameState.get_flag("day4_review_completed", false):
		result.append({"id": "day4:summary", "label": TranslationServer.translate("D4_CLOSE_SUMMARY_ACTION")})
		return result
	if not GameState.get_flag("day4_review_deferred", false):
		result.append({"id": "day4:defer", "label": TranslationServer.translate("D4_CLOSE_DEFER_ACTION")})
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Day4Review.DEFINITION))
	var choice: String = "wait" if GameState.minutes < int(rules["closing_minute"]) else "complete"
	if choice != "wait" or shelter != null:
		var confirming: bool = _choice == choice and _expected == GameState.to_dict()
		var key: String = "D4_CLOSE_" + ("CONFIRM_" if confirming else "") + choice.to_upper() + "_ACTION"
		result.append({"id": "day4:" + choice, "label": TranslationServer.translate(key)})
	return result

func perform(room: String, choice: String) -> String:
	var allowed: bool = false
	for action: Dictionary in actions(room):
		if action["id"] == "day4:" + choice:
			allowed = true
	if not allowed:
		cancel()
		return ""
	if choice == "summary":
		cancel()
		EventBus.review_requested.emit(Day4Review.summary())
		return ""
	var current: Dictionary = GameState.to_dict()
	if choice in ["wait", "complete"] and (_choice != choice or _expected != current):
		_expected = current
		_choice = choice
		return TranslationServer.translate("D4_CLOSE_CONFIRM_" + choice.to_upper())
	var candidate: Dictionary = current.duplicate(true)
	var transaction: String = "day4-review-" + choice
	match choice:
		"defer":
			candidate["flags"]["day4_review_deferred"] = true
		"wait":
			var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Day4Review.DEFINITION))
			candidate["minutes"] = int(rules["closing_minute"])
			shelter.project_daytime(candidate, int(candidate["minutes"]))
		"complete":
			candidate["flags"]["day4_review_completed"] = true
			candidate["flags"]["day4_review_completed_at"] = GameState.minutes
	var error: Error = SaveManager.commit_candidate(current, candidate, transaction)
	cancel()
	if error != OK:
		return TranslationServer.translate("DAY4_REVIEW_SAVE_FAILED")
	if choice == "complete":
		EventBus.review_requested.emit(Day4Review.summary())
		return ""
	return TranslationServer.translate("D4_CLOSE_DEFERRED" if choice == "defer" else "D4_CLOSE_WAITED")
