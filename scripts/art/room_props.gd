class_name RoomProps
extends Control
## Props use normalized painted-room coordinates, including its letterbox fit.
const DATA_PATH: String = "res://resources/items/room_props.json"
var _entries: Array[Dictionary] = []
var _reference_size: Vector2 = Vector2.ONE

func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)

func show_room(id: String, reference_size: Vector2) -> void:
	_entries.clear()
	_reference_size = reference_size
	var catalogue: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	for entry: Dictionary in catalogue.get(id, []):
		if not ResourceLoader.exists(entry["texture"]):
			push_error("Missing room prop: " + str(entry["texture"]))
			continue
		var rect: Array = entry["rect"]
		_entries.append({"id": entry["id"], "texture": load(entry["texture"]), "rect": Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))})
	queue_redraw()

func get_prop_ids() -> PackedStringArray:
	var ids := PackedStringArray()
	for entry: Dictionary in _entries:
		ids.append(entry["id"])
	return ids

func _draw() -> void:
	if _reference_size.x <= 0 or _reference_size.y <= 0:
		return
	var scale_factor: float = minf(size.x / _reference_size.x, size.y / _reference_size.y)
	var image_size: Vector2 = _reference_size * scale_factor
	var image_origin: Vector2 = (size - image_size) * 0.5
	for entry: Dictionary in _entries:
		var texture: Texture2D = entry["texture"]
		var normalized: Rect2 = entry["rect"]
		var slot := Rect2(image_origin + normalized.position * image_size, normalized.size * image_size)
		var prop_scale: float = minf(slot.size.x / texture.get_width(), slot.size.y / texture.get_height())
		var prop_size: Vector2 = texture.get_size() * prop_scale
		var origin: Vector2 = slot.position + Vector2((slot.size.x - prop_size.x) * 0.5, slot.size.y - prop_size.y)
		draw_texture_rect(texture, Rect2(origin, prop_size), false)
