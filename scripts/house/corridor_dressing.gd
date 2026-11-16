class_name CorridorDressing
extends Node3D
## Furniture and small objects in the walkable corridors, so they read as part
## of a lived-in house rather than empty passages. Built in house space by
## HouseBuilder. Shaped parts come from PropMeshes; plain boxes are kept only
## for things that really are boxes (shelves, books, a bench top).
##
## Ground floor: entrance x 4..8.2, z 8.5..10; hall x 4..7, z 3..8.5.
## Upper floor (y = 2.8): landing x 4..8.2, z 1.8..3; corridor x 4..7, z 3..8.5
## and x 4..6.8, z 8.5..10. West corridor walls are at x = 4; the stairwell
## guard is at x = 7.

const UPPER: float = HouseLayout.STOREY_HEIGHT
const WEST_WALL: float = 4.0 + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5


func _ready() -> void:
	_build_entrance()
	_build_hall()
	_build_upper_corridor()


func _build_entrance() -> void:
	# Doormat inside the front door.
	_flat_box(Vector3(6.0, 0.008, 9.55), Vector3(0.8, 0.016, 0.5), Color(0.20, 0.17, 0.12))

	# Coat rail on the wall facing the front door, east of the hall opening.
	var wall_z: float = 8.5 + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5
	_box(Vector3(7.62, 1.68, wall_z + 0.012), Vector3(0.9, 0.09, 0.024), &"wood_stairs")
	var hooks: Array[float] = [7.27, 7.50, 7.73, 7.96]
	for x: float in hooks:
		PropMeshes.cylinder(self, Vector3(x, 1.665, wall_z + 0.045), 0.008, 0.008, 0.06,
			HouseMaterials.get_material(&"brass"), Vector3(PI * 0.5, 0.0, 0.0), 8)
	# Two coats and a scarf left hanging.
	PropMeshes.coat(self, Vector3(7.27, 1.665, wall_z), Color(0.12, 0.14, 0.16), 0.86, 11)
	PropMeshes.coat(self, Vector3(7.96, 1.665, wall_z), Color(0.30, 0.22, 0.14), 0.74, 23)
	var scarf := MeshInstance3D.new()
	scarf.mesh = PropMeshes.cloth_mesh(0.07, 0.08, 0.56, 2, 0.01, 37)
	scarf.mesh.surface_set_material(0, _cloth_material(Color(0.42, 0.13, 0.10)))
	scarf.position = Vector3(7.50, 1.65, wall_z + 0.04)
	add_child(scarf)

	# Low shoe bench under the coats: two shelves, shoes on the lower one and
	# a pair kicked off on the floor beside it.
	var bench := Vector3(7.62, 0.0, 8.74)
	_box(bench + Vector3(0.0, 0.40, 0.0), Vector3(0.86, 0.035, 0.32), &"wood_stairs", true)
	_box(bench + Vector3(0.0, 0.14, 0.0), Vector3(0.82, 0.025, 0.30), &"wood_stairs")
	for side: float in [-1.0, 1.0]:
		_box(bench + Vector3(side * 0.41, 0.20, 0.0), Vector3(0.035, 0.40, 0.32), &"wood_stairs")
	var dark_shoes := Color(0.11, 0.08, 0.06)
	var worn_shoes := Color(0.30, 0.20, 0.12)
	for x: float in [-0.26, -0.15]:
		PropMeshes.shoe(self, bench + Vector3(x, 0.153, 0.0), dark_shoes, PI * 0.5)
	for x: float in [0.12, 0.24]:
		PropMeshes.shoe(self, bench + Vector3(x, 0.153, 0.0), worn_shoes, PI * 0.5 + 0.12)
	PropMeshes.shoe(self, Vector3(7.02, 0.0, 9.02), Color(0.20, 0.17, 0.15), 1.1)
	PropMeshes.shoe(self, Vector3(6.90, 0.0, 9.10), Color(0.20, 0.17, 0.15), 0.6)

	# Umbrella leaning in the corner by the front door.
	PropMeshes.umbrella(self, Vector3(4.24, 0.0, 9.80), Color(0.10, 0.12, 0.13), Vector3(0.12, 0.0, -0.10))


func _build_hall() -> void:
	# Narrow console table against the stair guard, with a lamp, a telephone,
	# a notepad and a small mantel clock.
	var table := Vector3(6.78, 0.0, 5.6)
	_box(table + Vector3(0.0, 0.76, 0.0), Vector3(0.30, 0.04, 0.85), &"wood_stairs", true)
	_box(table + Vector3(0.0, 0.66, 0.0), Vector3(0.26, 0.12, 0.78), &"wood_stairs")
	for dz: float in [-0.38, 0.38]:
		for dx: float in [-0.11, 0.11]:
			PropMeshes.cylinder(self, table + Vector3(dx, 0.37, dz), 0.018, 0.013, 0.74,
				HouseMaterials.get_material(&"wood_stairs"), Vector3.ZERO, 10)
	_table_lamp(table + Vector3(0.0, 0.78, -0.25))

	var phone := Node3D.new()
	phone.name = "Telephone"
	phone.position = table + Vector3(-0.01, 0.78, 0.24)
	# The dial faces into the hall (-X).
	phone.rotation.y = PI
	add_child(phone)
	PropMeshes.telephone(phone)
	_box(table + Vector3(-0.06, 0.785, 0.37), Vector3(0.12, 0.012, 0.09), &"frame_paint", false, Vector3(0.0, 0.2, 0.0))
	PropMeshes.cylinder(self, table + Vector3(-0.07, 0.80, 0.39), 0.004, 0.004, 0.12,
		HouseMaterials.get_flat(Color(0.12, 0.20, 0.30)), Vector3(PI * 0.5, 0.3, 0.0), 6)

	_mantel_clock(table + Vector3(0.02, 0.78, 0.02))

	# Pictures on the living-room wall, the second one hanging slightly crooked.
	PropMeshes.framed_picture(self, Vector3(WEST_WALL + 0.004, 1.62, 4.35), Vector2(0.58, 0.44), 1.0, 0.0, &"painting_landscape")
	PropMeshes.framed_picture(self, Vector3(WEST_WALL + 0.004, 1.58, 7.5), Vector2(0.38, 0.48), 1.0, deg_to_rad(3.5), &"painting_still_life")


func _build_upper_corridor() -> void:
	# A wooden chair at the far end, beside Daniel's door, with a blanket on it.
	var chair := Vector3(4.32, UPPER, 8.12)
	var wood: Material = HouseMaterials.get_material(&"wood_stairs")
	_box(chair + Vector3(0.0, 0.44, 0.0), Vector3(0.40, 0.04, 0.40), &"wood_stairs", true)
	for dz: float in [-0.17, 0.17]:
		PropMeshes.cylinder(self, chair + Vector3(-0.18, 0.72, dz), 0.016, 0.016, 0.56, wood, Vector3.ZERO, 8)
	_box(chair + Vector3(-0.18, 0.92, 0.0), Vector3(0.035, 0.09, 0.40), &"wood_stairs")
	_box(chair + Vector3(-0.18, 0.70, 0.0), Vector3(0.025, 0.05, 0.36), &"wood_stairs")
	for dx: float in [-0.17, 0.17]:
		for dz: float in [-0.17, 0.17]:
			PropMeshes.cylinder(self, chair + Vector3(dx, 0.22, dz), 0.018, 0.015, 0.44, wood, Vector3.ZERO, 8)
	var blanket := MeshInstance3D.new()
	blanket.mesh = PropMeshes.cloth_mesh(0.30, 0.32, 0.36, 3, 0.012, 51)
	blanket.mesh.surface_set_material(0, _cloth_material(Color(0.36, 0.13, 0.11)))
	blanket.position = chair + Vector3(0.04, 0.465, 0.0)
	blanket.rotation = Vector3(-PI * 0.5, PI * 0.5, 0.0)
	add_child(blanket)

	# Pictures on the bedroom wall, between the doors.
	PropMeshes.framed_picture(self, Vector3(WEST_WALL + 0.004, UPPER + 1.58, 3.45), Vector2(0.42, 0.34), 1.0, 0.0, &"photo_house")
	PropMeshes.framed_picture(self, Vector3(WEST_WALL + 0.004, UPPER + 1.62, 5.75), Vector2(0.48, 0.38), 1.0, deg_to_rad(-2.0), &"painting_landscape")

	# Low bookcase at the window end.
	_bookcase(Vector3(4.21, UPPER, 9.25))

	# Small cabinet on the landing, opposite the top of the stairs, with a jug.
	var cabinet := Vector3(4.22, UPPER, 2.0)
	_box(cabinet + Vector3(0.0, 0.40, 0.0), Vector3(0.36, 0.80, 0.30), &"wood_stairs", true)
	_box(cabinet + Vector3(0.0, 0.81, 0.0), Vector3(0.40, 0.03, 0.34), &"wood_stairs")
	PropMeshes.sphere(self, cabinet + Vector3(0.185, 0.55, 0.0), 0.012, HouseMaterials.get_material(&"brass"))
	var glaze: Material = HouseMaterials.get_flat(Color(0.20, 0.34, 0.31))
	PropMeshes.sphere(self, cabinet + Vector3(0.0, 0.90, 0.0), 0.07, glaze, Vector3(1.0, 1.1, 1.0))
	PropMeshes.cylinder(self, cabinet + Vector3(0.0, 1.00, 0.0), 0.035, 0.03, 0.08, glaze, Vector3.ZERO, 16)


## Two shelves of books and a few lying flat; books really are boxes.
func _bookcase(base: Vector3) -> void:
	var depth: float = 0.28
	var width: float = 0.70
	var height: float = 1.05
	_box(base + Vector3(0.0, height * 0.5, 0.0), Vector3(depth, height, width), &"wood_stairs", true).visible = false
	_box(base + Vector3(-depth * 0.5 + 0.01, height * 0.5, 0.0), Vector3(0.02, height, width), &"wood_stairs")
	for side: float in [-1.0, 1.0]:
		_box(base + Vector3(0.0, height * 0.5, side * (width * 0.5 - 0.012)), Vector3(depth, height, 0.024), &"wood_stairs")
	var shelves: Array[float] = [0.04, 0.36, 0.70, 1.04]
	for y: float in shelves:
		_box(base + Vector3(0.0, y, 0.0), Vector3(depth, 0.025, width), &"wood_stairs")
	var spines: Array[Color] = [
		Color(0.36, 0.13, 0.10), Color(0.16, 0.24, 0.20), Color(0.46, 0.38, 0.22),
		Color(0.15, 0.17, 0.24), Color(0.32, 0.28, 0.22), Color(0.26, 0.10, 0.14),
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = 2611
	for shelf: int in 2:
		var z: float = -width * 0.5 + 0.04
		var y: float = shelves[shelf] + 0.0125
		var limit: float = width * 0.5 - rng.randf_range(0.10, 0.22)
		while z < limit:
			var thickness: float = rng.randf_range(0.025, 0.05)
			var book_height: float = rng.randf_range(0.20, 0.29)
			_flat_box(
				base + Vector3(0.01, y + book_height * 0.5, z + thickness * 0.5),
				Vector3(0.19, book_height, thickness), spines[rng.randi() % spines.size()],
				Vector3(rng.randf_range(-0.03, 0.03), 0.0, 0.0)
			)
			z += thickness + 0.003
	# A small stack lying on top.
	for i: int in 3:
		_flat_box(
			base + Vector3(0.01, shelves[3] + 0.0125 + 0.02 + i * 0.035, 0.12),
			Vector3(0.20 - i * 0.02, 0.032, 0.15 - i * 0.01), spines[(i + 2) % spines.size()],
			Vector3(0.0, 0.15 * float(i), 0.0)
		)


## A small wooden mantel clock with a cream face, facing into the hall (-X).
func _mantel_clock(base: Vector3) -> void:
	var wood: Material = HouseMaterials.get_material(&"wood_stairs")
	var face: Material = HouseMaterials.get_flat(Color(0.74, 0.70, 0.58))
	var hands: Material = HouseMaterials.get_flat(Color(0.05, 0.05, 0.05))
	_box(base + Vector3(0.0, 0.012, 0.0), Vector3(0.11, 0.024, 0.20), &"wood_stairs")
	_box(base + Vector3(0.0, 0.085, 0.0), Vector3(0.08, 0.12, 0.16), &"wood_stairs")
	PropMeshes.cylinder(self, base + Vector3(0.0, 0.145, 0.0), 0.08, 0.08, 0.08, wood, Vector3(0.0, 0.0, PI * 0.5), 24)
	PropMeshes.cylinder(self, base + Vector3(-0.042, 0.125, 0.0), 0.055, 0.055, 0.006, face, Vector3(0.0, 0.0, PI * 0.5), 24)
	PropMeshes.box(self, base + Vector3(-0.047, 0.142, 0.0), Vector3(0.004, 0.036, 0.006), hands)
	PropMeshes.box(self, base + Vector3(-0.047, 0.125, 0.012), Vector3(0.004, 0.005, 0.028), hands, Vector3(0.5, 0.0, 0.0))


## A small shaded lamp that makes one warm pool of light.
func _table_lamp(base: Vector3) -> void:
	var brass: Material = HouseMaterials.get_material(&"brass")
	PropMeshes.cylinder(self, base + Vector3(0.0, 0.015, 0.0), 0.06, 0.07, 0.03, brass, Vector3.ZERO, 20)
	PropMeshes.cylinder(self, base + Vector3(0.0, 0.16, 0.0), 0.012, 0.012, 0.26, brass, Vector3.ZERO, 10)
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


func _cloth_material(color: Color) -> Material:
	var cloth := HouseMaterials.get_material(&"coat_cloth").duplicate() as StandardMaterial3D
	cloth.albedo_color = color
	return cloth


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
