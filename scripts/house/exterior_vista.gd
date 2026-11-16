extends Node3D
## Authored, inaccessible exterior set: depth and parallax through foyer windows.
## No town simulation, traversable exterior or gameplay entities.

func _ready() -> void:
	_box(Vector3(6, -0.23, 24), Vector3(52, 0.1, 28), Color(0.22, 0.29, 0.22))
	_box(Vector3(6, -0.16, 21), Vector3(52, 0.04, 4), Color(0.23, 0.25, 0.23))
	_box(Vector3(6, 9, 43), Vector3(85, 35, 0.2), Color(0.39, 0.48, 0.40))
	# Short front path, fence and a neighbour across the road.
	_box(Vector3(6, -0.12, 14), Vector3(1.1, 0.05, 8), Color(0.40, 0.40, 0.33))
	for x: float in [-5, 0, 11, 16]:
		_box(Vector3(x, 0.65, 18), Vector3(0.10, 1.3, 0.10), Color(0.29, 0.30, 0.24))
	for y: float in [0.4, 0.9]:
		_box(Vector3(-1.5, y, 18), Vector3(10, 0.09, 0.07), Color(0.32, 0.32, 0.25))
		_box(Vector3(14, y, 18), Vector3(7, 0.09, 0.07), Color(0.32, 0.32, 0.25))
	# Painted distant street; 3D fence/path in front preserve near-field parallax.
	var backdrop := MeshInstance3D.new()
	backdrop.name = "PaintedStreet"
	var quad := QuadMesh.new()
	quad.size = Vector2(40.0, 20.0)
	backdrop.mesh = quad
	backdrop.position = Vector3(6.0, 7.0, 26.0)
	var paint := _material(Color.WHITE)
	paint.cull_mode = BaseMaterial3D.CULL_DISABLED
	paint.albedo_texture = load("res://assets/exterior/briar_glen_street_day.png")
	paint.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	backdrop.material_override = paint
	backdrop.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	backdrop.add_to_group("window_backdrops")
	add_child(backdrop)

func _box(at: Vector3, size: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = at
	instance.material_override = _material(color)
	instance.add_to_group("window_backdrops")
	add_child(instance)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	return material
