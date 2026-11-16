class_name Day4Review
extends RefCounted

const DEFINITION: String = "res://resources/events/day4_review.json"

static func available() -> bool:
	return GameState.active and GameState.day == 4 and not GameState.night_in_progress()

static func record_open() -> Error:
	if not available():
		return ERR_UNAVAILABLE
	if GameState.get_flag("day4_reviewed", false):
		return OK
	var expected: Dictionary = GameState.to_dict()
	var candidate: Dictionary = expected.duplicate(true)
	candidate["flags"]["day4_reviewed"] = true
	return SaveManager.commit_candidate(expected, candidate, "day4-review-open")

static func text() -> String:
	var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DEFINITION))
	var lines := PackedStringArray()
	for key: String in definition["opening_keys"]:
		var visible_key: String = key
		if key == "DAY4_REVIEW_INTRO" and not GameState.power_incident.has("cause"):
			visible_key = "DAY4_REVIEW_LEGACY"
		lines.append(TranslationServer.translate(visible_key))
	lines.append(TranslationServer.translate("DAY4_REVIEW_RESIDENTS").format({"count": GameState.get_residents().size()}))
	if GameState.evidence.is_empty():
		lines.append(TranslationServer.translate("DAY4_REVIEW_NO_RECORDS"))
	else:
		# Only already collected facts/claims/suspicions are shown. No actor,
		# cause or infection data is read from the private incident snapshot.
		lines.append(EvidenceManager.journal_text())
	lines.append(TranslationServer.translate("DAY4_REVIEW_NEXT"))
	return "\n\n".join(lines)
