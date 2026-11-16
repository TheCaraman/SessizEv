class_name EvidenceManager
extends RefCounted
const CATALOGUES: Array[String] = ["res://resources/evidence/power.json", "res://resources/evidence/night_house.json"]

static func collect(id: String, key: String, kind: String = "fact") -> void:
	var allowed: bool = false
	for path: String in CATALOGUES:
		var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		if kind in definition["types"] and definition["catalogue"].get(key, "") == kind:
			allowed = true
			break
	if not allowed:
		return
	for entry: Dictionary in GameState.evidence:
		if entry["id"] == id:
			return
	GameState.evidence.append({"id": id, "key": key, "kind": kind, "day": GameState.day, "minutes": GameState.minutes})

static func journal_text() -> String:
	var lines := PackedStringArray([TranslationServer.translate("POWER_JOURNAL")])
	for entry: Dictionary in GameState.evidence:
		lines.append("%s — %s" % [TranslationServer.translate("POWER_" + str(entry["kind"]).to_upper()), TranslationServer.translate(entry["key"])])
	lines.append(TranslationServer.translate("POWER_LIMIT"))
	return "\n\n".join(lines)
