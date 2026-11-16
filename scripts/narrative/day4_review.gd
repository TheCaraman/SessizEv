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
	lines.append(summary())
	return "\n\n".join(lines)

## Current public shelter state; no hidden infection or culprit is consulted.
static func summary() -> String:
	var counts: Dictionary = {"resident": GameState.get_residents().size(), "isolated": 0, "expelled": 0, "fact": 0, "claim": 0, "suspicion": 0}
	for id: String in Roster.get_ids():
		if GameState.get_status(id) == "resident" and GameState.npcs[id].get("isolated", false):
			counts["isolated"] += 1
		if GameState.get_flag("day4_expelled_" + id, false):
			counts["expelled"] += 1
	for entry: Dictionary in GameState.evidence:
		var kind: String = str(entry.get("kind", ""))
		if kind in ["fact", "claim", "suspicion"]:
			counts[kind] += 1
	var state: String = "COMPLETED" if GameState.get_flag("day4_review_completed", false) else ("DEFERRED" if GameState.get_flag("day4_review_deferred", false) else "OPEN")
	var lines := PackedStringArray([TranslationServer.translate("D4_CLOSE_STATE_" + state), TranslationServer.translate("D4_CLOSE_CURRENT").format(counts)])
	lines.append(TranslationServer.translate("D4_CLOSE_OUTAGE" if GameState.power_incident.get("state") == "outage" else "D4_CLOSE_POWER_AVAILABLE"))
	if state == "COMPLETED":
		var minute: int = int(GameState.get_flag("day4_review_completed_at", 1200))
		lines.append(TranslationServer.translate("D4_CLOSE_FINISHED_AT").format({"time": "%02d:%02d" % [minute / 60, minute % 60]}))
		lines.append(TranslationServer.translate("D4_CLOSE_BUILD_LIMIT"))
	return "\n\n".join(lines)
