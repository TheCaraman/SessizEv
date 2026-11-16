extends Control
## Fits a figure into its slot with feet aligned to a shared floor baseline.
## TextureRect's centered aspect fit made short/narrow sprites float in the room.

var texture: Texture2D:
	set(value):
		texture = value
		queue_redraw()


func _init() -> void:
	custom_minimum_size = Vector2(240.0, 420.0)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _draw() -> void:
	if texture == null:
		return
	var source_size: Vector2 = texture.get_size()
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return
	var scale_factor: float = minf(size.x / source_size.x, size.y / source_size.y)
	var fitted_size: Vector2 = source_size * scale_factor
	var position_in_slot := Vector2((size.x - fitted_size.x) * 0.5, size.y - fitted_size.y)
	# A restrained contact shadow anchors the cutout to the floor, not the wall.
	draw_set_transform(Vector2(size.x * 0.5, size.y - 6.0), 0.0, Vector2(1.0, 0.12))
	draw_circle(Vector2.ZERO, minf(fitted_size.x * 0.4, 90.0), Color(0.0, 0.0, 0.0, 0.18))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_texture_rect(texture, Rect2(position_in_slot, fitted_size), false)
