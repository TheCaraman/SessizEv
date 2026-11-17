class_name CharacterArt
extends RefCounted
## Presentation context only. Never reads infection or campaign secrets.
const DATA_PATH: String = "res://resources/characters/character_art.json"
const LEGACY_PATH: String = "res://assets/characters/%s/default.png"

static func texture_path(npc_id: String, context: StringName = &"room") -> String:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	var definitions: Dictionary = parsed if parsed is Dictionary else {}
	var definition: Dictionary = definitions.get(npc_id, {})
	var fallback: String = LEGACY_PATH % npc_id
	var path: String = str(definition.get(str(context), definition.get("room", fallback)))
	return path if ResourceLoader.exists(path) else fallback
