class_name CorridorDressing
extends Node3D
## Furniture and small objects in the walkable corridors, so they read as part
## of a lived-in house rather than empty passages. Built from boxes in house
## space by HouseBuilder.
##
## Ground floor: entrance x 5..8.2, z 8.5..10; hall x 5..7, z 3..8.5.
## Upper floor (y = 2.8): landing x 5..8.2, z 1.8..3; corridor x 5..7, z 3..8.5.

const UPPER: float = HouseLayout.STOREY_HEIGHT


func _ready() -> void:
	_build_entrance()
	_build_hall()
	_build_upper_corridor()


func _build_entrance() -> void:
	# Doormat inside the front door.
	_flat_box(Vector3(6.0, 0.008, 9.55), Vector3(0.8, 0.016, 0.5), Color(0.20, 0.17, 0.12))

	# Coat rail on the wall facing the front door, east of the hall opening.
	var wall_z: float = 8.5 + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5
	_box(Vector3(7.5, 1.65, wall_z + 0.012), Vector3(1.1, 0.10, 0.024), &"wood_stairs")
	for i: int in 5:
		_box(Vector3(7.06 + i * 0.22, 1.63, wall_z + 0.05), Vector3(0.02, 0.02, 0.06), &"brass")
	# Two coats left hanging, and a scarf.
	_flat_box(Vector3(7.06, 1.22, wall_z + 0.08), Vector3(0.36, 0.82, 0.10), Color(0.13, 0.15, 0.17))
	_flat_box(Vector3(7.06, 1.60, wall_z + 0.08), Vector3(0.22, 0.10, 0.11), Color(0.10, 0.12, 0.14))
	_flat_box(Vector3(7.72, 1.28, wall_z + 0.07), Vector3(0.32, 0.70, 0.08), Color(0.30, 0.22, 0.14))
	_flat_box(Vector3(7.94, 1.36, wall_z + 0.05), Vector3(0.07, 0.52, 0.03), Color(0.40, 0.12, 0.10))

	# Low shoe bench under the coats, with two pairs of shoes on it.
	_box(Vector3(7.55, 0.38, 8.74), Vector3(1.0, 0.04, 0.34), &"wood_stairs", true)
	_box(Vector3(7.55, 0.14, 8.74), Vector3(1.0, 0.03, 0.34), &"wood_stairs")
	for side: float in [-1.0, 1.0]:
		_box(Vector3(7.55 + side * 0.48, 0.19, 8.74), Vector3(0.04, 0.38, 0.34), &"wood_stairs")
	for x: float in [7.22, 7.34, 7.70, 7.82]:
		_flat_box(Vector3(x, 0.19, 8.76), Vector3(0.09, 0.07, 0.26), Color(0.09, 0.08, 0.07))

	# Umbrella leaning in the corner by the door.
	_box(Vector3(4.22, 0.45, 9.78), Vector3(0.04, 0.9, 0.04), &"trim_dark", false, Vector3(0.12, 0.0, -0.08))


func _build_hall() -> void:
	# Narrow console table against the stair wall, with a lamp and a telephone.
	var table := Vector3(6.78, 0.0, 5.6)
	_box(table + Vector3(0.0, 0.76, 0.0), Vector3(0.30, 0.04, 0.85), &"wood_stairs", true)
	_box(table + Vector3(0.0, 0.66, 0.0), Vector3(0.26, 0.12, 0.78), &"wood_stairs")
	for dz: float in [-0.38, 0.38]:
		for dx: float in [-0.11, 0.11]:
			_box(table + Vector3(dx, 0.37, dz), Vector3(0.04, 0.74, 0.04), &"wood_stairs")
	_table_lamp(table + Vector3(0.0, 0.78, -0.25))
	# Telephone: body, handset, and a notepad beside it.
	_flat_box(table + Vector3(0.0, 0.81, 0.18), Vector3(0.16, 0.06, 0.20), Color(0.10, 0.10, 0.10))
	_flat_box(table + Vector3(0.0, 0.86, 0.18), Vector3(0.05, 0.04, 0.24), Color(0.07, 0.07, 0.07))
	_box(table + Vector3(0.02, 0.785, 0.36), Vector3(0.12, 0.012, 0.09), &"frame_paint", false, Vector3(0.0, 0.2, 0.0))

	# Pictures on the living-room wall, the second one hanging crooked.
	var west: float = 4.0 + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5
	_picture(Vector3(west + 0.02, 1.62, 4.3), Vector2(0.50, 0.38), true, 0.0, Color(0.20, 0.24, 0.22))
	_picture(Vector3(west + 0.02, 1.58, 7.5), Vector2(0.34, 0.46), true, deg_to_rad(4.0), Color(0.28, 0.22, 0.16))

	# Wall clock above the table.
	var east: float = 7.0 - HouseLayout.INTERIOR_WALL_THICKNESS * 0.5
	_box(Vector3(east - 0.12, 0.94, 5.6), Vector3(0.08, 0.28, 0.22), &"wood_stairs")
	_flat_box(Vector3(east - 0.165, 0.94, 5.6), Vector3(0.01, 0.22, 0.17), Color(0.62, 0.60, 0.50))


func _build_upper_corridor() -> void:
	# A wooden chair at the far end, beside the storage door.
	var chair := Vector3(4.32, UPPER, 8.12)
	_box(chair + Vector3(0.0, 0.44, 0.0), Vector3(0.40, 0.04, 0.40), &"wood_stairs", true)
	_box(chair + Vector3(-0.18, 0.72, 0.0), Vector3(0.04, 0.56, 0.40), &"wood_stairs")
	for dx: float in [-0.17, 0.17]:
		for dz: float in [-0.17, 0.17]:
			_box(chair + Vector3(dx, 0.22, dz), Vector3(0.04, 0.44, 0.04), &"wood_stairs")
	# A folded blanket left on the seat.
	_flat_box(chair + Vector3(0.02, 0.49, 0.0), Vector3(0.30, 0.06, 0.32), Color(0.32, 0.12, 0.10))

	# Pictures along the stairwell wall.
	var east: float = 7.0 - HouseLayout.INTERIOR_WALL_THICKNESS * 0.5
	# The stairwell is open above its guard; no floating wall pictures.

	# Small cabinet on the landing, opposite the top of the stairs.
	var cabinet := Vector3(4.22, UPPER, 2.0)
	_box(cabinet + Vector3(0.0, 0.40, 0.0), Vector3(0.36, 0.80, 0.30), &"wood_stairs", true)
	_box(cabinet + Vector3(0.0, 0.81, 0.0), Vector3(0.40, 0.03, 0.34), &"wood_stairs")
	_box(cabinet + Vector3(0.185, 0.55, 0.0), Vector3(0.012, 0.03, 0.08), &"brass")
	_flat_box(cabinet + Vector3(0.0, 0.89, 0.0), Vector3(0.12, 0.13, 0.12), Color(0.30, 0.34, 0.30))


## A small shaded lamp that makes one warm pool of light.
func _table_lamp(base: Vector3) -> void:
	_box(base + Vector3(0.0, 0.02, 0.0), Vector3(0.10, 0.04, 0.10), &"brass")
	_box(base + Vector3(0.0, 0.16, 0.0), Vector3(0.025, 0.26, 0.025), &"brass")
	var shade := MeshInstance3D.new()
	var cover := CylinderMesh.new()
	cover.top_radius = 0.085
	cover.bottom_radius = 0.135
	cover.height = 0.20
	cover.radial_segments = 40
	shade.mesh = cover
	shade.position = base + Vector3(0.0, 0.36, 0.0)
	add_child(shade)
	shade.add_to_group("electric_fittings")
	shade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# A cloth shade glows much less than a bare ceiling fitting.
	var shade_material := HouseMaterials.get_material(&"lamp_shade").duplicate() as StandardMaterial3D
	shade_material.emission = Color(0.95, 0.66, 0.36)
	shade_material.emission_energy_multiplier = 0.55
	cover.material = shade_material

	var light := OmniLight3D.new()
	light.add_to_group("electric_lights")
	light.name = "TableLampLight"
	light.position = base + Vector3(-0.1, 0.40, 0.0)
	light.light_color = Color(0.86, 0.88, 0.65)
	light.light_energy = 0.55
	light.omni_range = 4.0
	light.omni_attenuation = 1.8
	light.shadow_enabled = true
	light.shadow_blur = 2.0
	light.light_volumetric_fog_energy = 0.8
	add_child(light)


## A framed picture on a wall that runs along Z. [param faces_east] is true
## when the picture hangs on a west wall and so faces +X.
func _picture(center: Vector3, size: Vector2, faces_east: bool, tilt: float, canvas: Color) -> void:
	var euler := Vector3(tilt, 0.0, 0.0)
	_box(center, Vector3(0.03, size.y, size.x), &"wood_stairs", false, euler)
	var out: float = 1.0 if faces_east else -1.0
	var picture: MeshInstance3D = _flat_box(
		center + Vector3(out * 0.012, 0.0, 0.0), Vector3(0.02, size.y - 0.08, size.x - 0.08), canvas, euler
	)
	picture.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


## Adds a box. With [param solid] it also blocks the player.
func _box(
	center: Vector3, size: Vector3, material: StringName, solid: bool = false,
	euler: Vector3 = Vector3.ZERO
) -> Node3D:
	var mesh_instance: MeshInstance3D = _make_mesh(size, HouseMaterials.get_material(material))
	if not solid:
		mesh_instance.position = center
		mesh_instance.rotation = euler
		add_child(mesh_instance)
		return mesh_instance
	var body := StaticBody3D.new()
	body.position = center
	body.rotation = euler
	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	body.add_child(mesh_instance)
	add_child(body)
	return body


## Adds a non-solid box with a plain colour.
func _flat_box(center: Vector3, size: Vector3, color: Color, euler: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = _make_mesh(size, HouseMaterials.get_flat(color))
	mesh_instance.position = center
	mesh_instance.rotation = euler
	add_child(mesh_instance)
	return mesh_instance


func _make_mesh(size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	return mesh_instance
