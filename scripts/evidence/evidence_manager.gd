class_name EvidenceManager
extends RefCounted
const CATALOGUES: Array[String] = ["res://resources/evidence/power.json", "res://resources/evidence/night_house.json", "res://resources/evidence/night_witness.json", "res://resources/evidence/accusation.json"]

static func collect(id: String, key: String, kind: String = "fact") -> void:
	collect_into(GameState.evidence, id, key, kind)

static func collect_into(records: Array, id: String, key: String, kind: String = "fact", args: Dictionary = {}) -> bool:
	var allowed: bool = false
	for path: String in CATALOGUES:
		var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path))
		if kind in definition["types"] and definition["catalogue"].get(key, "") == kind:
			allowed = true
			break
	if not allowed:
		return false
	for entry: Dictionary in records:
		if entry["id"] == id:
			return true
	var entry: Dictionary = {"id": id, "key": key, "kind": kind, "day": GameState.day, "minutes": GameState.minutes}
	if not args.is_empty():
		entry["args"] = args.duplicate(true)
	records.append(entry)
	return true

static func journal_text() -> String:
	var lines := PackedStringArray([TranslationServer.translate("POWER_JOURNAL")])
	for entry: Dictionary in GameState.evidence:
		lines.append("%s — %s" % [TranslationServer.translate("POWER_" + str(entry["kind"]).to_upper()), TranslationServer.translate(entry["key"]).format(entry.get("args", {}))])
	lines.append(TranslationServer.translate("POWER_LIMIT"))
	return "\n\n".join(lines)
