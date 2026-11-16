class_name RoomVisuals
extends RefCounted
const DATA_PATH: String = "res://resources/items/room_visuals.json"
var _definitions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))

func resolve(room: String, minutes: int, powered: bool) -> Dictionary:
	var clock: int = posmod(minutes, 1440)
	var night: bool = clock >= 1200 or clock < 420
	var fallback_tint: Color = Color(0.43, 0.46, 0.49) if not powered else (Color(0.65, 0.67, 0.70) if night else Color.WHITE)
	var default_path: String = "res://assets/rooms/%s.png" % room
	var definition: Dictionary = _definitions.get(room, {})
	var variant: String = ("night" if night else "day") if powered else ("outage_night" if night else "outage_day")
	var path: String = str(definition.get(variant, ""))
	if path == "" or not ResourceLoader.exists(path):
		return {"path": default_path, "variant": "fallback", "background_tint": fallback_tint, "actor_tint": fallback_tint}
	var tint: Array = definition["actor_tints"][variant]
	return {"path": path, "variant": variant, "background_tint": Color.WHITE, "actor_tint": Color(float(tint[0]), float(tint[1]), float(tint[2]))}
