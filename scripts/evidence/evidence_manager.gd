class_name EvidenceManager
extends RefCounted

static func collect(id: String, key: String, kind: String = "fact") -> void:
	var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/evidence/power.json"))
	if not kind in definition["types"] or definition["catalogue"].get(key, "") != kind:
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
