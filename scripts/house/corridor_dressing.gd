class_name CorridorDressing
extends Node3D
## Furniture and small objects in the walkable corridors, so they read as part
## of a lived-in house rather than empty passages. Built in house space by
## HouseBuilder. Shaped parts come from PropMeshes; plain boxes are kept only
## for things that really are boxes (shelves, drawers, books).
##
## Plan after HOUSE-ATMOS-001 (×1.25, storey 3.3 m):
##   Ground: hall x 5..8.75, z 3.75..10.625; vestibule x 5..10.25, z 10.625..12.5.
##           West wall x = 5 (living-room door at z 7.5); stair guard x = 8.75;
##           coat wall z = 10.625 east of the opening (x 8.875..10.25);
##           front door x = 7.5 and windows at x 5.94 and 9.31 on z = 12.5.
##   Upper:  corridor x 5..8.75, z 3.75..10.625, overlooking the tall entrance;
##           bedroom doors on x = 5 at z 3.0, 5.625, 8.75; window x 6.625 on z = 12.5;
##           landing x 5..10.25, z 2.25..3.75, box-room wall z = 2.25.

const UPPER: float = HouseLayout.STOREY_HEIGHT
const WEST_FACE: float = 5.0 + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5
const FRONT_FACE: float = 12.5 - HouseLayout.EXTERIOR_WALL_THICKNESS * 0.5


func _ready() -> void:
	_build_entrance()
	_build_hall()
	_build_upper_corridor()


func _build_entrance() -> void:
	# Doormat inside the front door.
	_flat_box(Vector3(7.5, 0.008, 12.05), Vector3(0.9, 0.016, 0.55), Color(0.20, 0.17, 0.12))

	# Cast-iron radiators under both front windows.
	_radiator(Vector3(5.94, 0.0, FRONT_FACE - 0.08), 0.9)
	_radiator(Vector3(9.31, 0.0, FRONT_FACE - 0.08), 0.8)

	# Coat rail on the wall facing the front door, east of the hall opening.
	var wall_z: float = 10.625 + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5
	_box(Vector3(9.55, 1.72, wall_z + 0.012), Vector3(1.05, 0.09, 0.024), &"wood_stairs")
	for x: float in [9.15, 9.42, 9.69, 9.96]:
		PropMeshes.cylinder(self, Vector3(x, 1.705, wall_z + 0.045), 0.008, 0.008, 0.06,
			HouseMaterials.get_material(&"brass"), Vector3(PI * 0.5, 0.0, 0.0), 8)
	PropMeshes.coat(self, Vector3(9.15, 1.705, wall_z), Color(0.12, 0.14, 0.16), 0.92, 11)
	PropMeshes.coat(self, Vector3(9.96, 1.705, wall_z), Color(0.30, 0.22, 0.14), 0.80, 23)
	var scarf := MeshInstance3D.new()
	scarf.mesh = PropMeshes.cloth_mesh(0.07, 0.08, 0.58, 2, 0.01, 37)
	scarf.mesh.surface_set_material(0, _cloth_material(Color(0.42, 0.13, 0.10)))
	scarf.position = Vector3(9.56, 1.69, wall_z + 0.04)
	add_child(scarf)

	# Low shoe bench under the coats.
	var bench := Vector3(9.55, 0.0, wall_z + 0.18)
	_box(bench + Vector3(0.0, 0.40, 0.0), Vector3(0.9, 0.035, 0.32), &"wood_stairs", true)
	_box(bench + Vector3(0.0, 0.14, 0.0), Vector3(0.86, 0.025, 0.30), &"wood_stairs")
	for side: float in [-1.0, 1.0]:
		_box(bench + Vector3(side * 0.43, 0.20, 0.0), Vector3(0.035, 0.40, 0.32), &"wood_stairs")
	for x: float in [-0.28, -0.16]:
		PropMeshes.shoe(self, bench + Vector3(x, 0.153, 0.0), Color(0.11, 0.08, 0.06), PI * 0.5)
	for x: float in [0.12, 0.24]:
		PropMeshes.shoe(self, bench + Vector3(x, 0.153, 0.0), Color(0.30, 0.20, 0.12), PI * 0.5 + 0.12)
	PropMeshes.shoe(self, Vector3(8.75, 0.0, 11.35), Color(0.20, 0.17, 0.15), 1.1)
	PropMeshes.shoe(self, Vector3(8.62, 0.0, 11.45), Color(0.20, 0.17, 0.15), 0.6)

	# Umbrella leaning in the corner by the west window.
	PropMeshes.umbrella(self, Vector3(5.22, 0.0, 12.22), Color(0.10, 0.12, 0.13), Vector3(0.12, 0.0, -0.10))


func _build_hall() -> void:
	# Old writing bureau with a glazed hutch, against the west wall.
	_bureau(Vector3(WEST_FACE, 0.0, 4.95))

	# A small still life between the bureau and the living-room door, and a
	# landscape beyond the door.
	PropMeshes.framed_picture(self, Vector3(WEST_FACE + 0.004, 1.62, 6.25), Vector2(0.40, 0.50), 1.0, deg_to_rad(3.0), &"painting_still_life")
	PropMeshes.framed_picture(self, Vector3(WEST_FACE + 0.004, 1.66, 9.25), Vector2(0.62, 0.47), 1.0, 0.0, &"painting_landscape")

	# Narrow console table against the stair guard, with a lamp, a telephone,
	# a notepad and a small mantel clock.
	var table := Vector3(8.52, 0.0, 6.5)
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
	phone.rotation.y = PI
	add_child(phone)
	PropMeshes.telephone(phone)
	_box(table + Vector3(-0.06, 0.785, 0.37), Vector3(0.12, 0.012, 0.09), &"blind_slat", false, Vector3(0.0, 0.2, 0.0))
	_mantel_clock(table + Vector3(0.02, 0.78, 0.02))


func _build_upper_corridor() -> void:
	var wood: Material = HouseMaterials.get_material(&"wood_stairs")
	# Small local pools at the landing and bedroom end; keep the passage clear.
	for point: Vector3 in [Vector3(5.28, UPPER, 7.8), Vector3(5.28, UPPER, 2.8)]:
		_box(point + Vector3(0.0, 0.70, 0.0), Vector3(0.36, 0.045, 0.42), &"wood_stairs", true)
		for offset: Vector3 in [Vector3(-0.13, 0.34, -0.16), Vector3(0.13, 0.34, -0.16), Vector3(-0.13, 0.34, 0.16), Vector3(0.13, 0.34, 0.16)]:
			PropMeshes.cylinder(self, point + offset, 0.014, 0.014, 0.68, wood, Vector3.ZERO, 12)
		_table_lamp(point + Vector3(0.0, 0.73, 0.0))
	# A wooden chair beside Daniel's door, with a blanket thrown over it.
	var chair := Vector3(5.32, UPPER, 9.85)
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
	PropMeshes.framed_picture(self, Vector3(WEST_FACE + 0.004, UPPER + 1.62, 4.31), Vector2(0.44, 0.35), 1.0, 0.0, &"photo_house")
	PropMeshes.framed_picture(self, Vector3(WEST_FACE + 0.004, UPPER + 1.66, 7.19), Vector2(0.52, 0.40), 1.0, deg_to_rad(-2.0), &"painting_landscape")

	# The front window now belongs to the tall foyer; no floating upper props.

	# Small cabinet on the landing against the box-room wall, with a jug.
	var cabinet := Vector3(6.2, UPPER, 2.25 + HouseLayout.INTERIOR_WALL_THICKNESS * 0.5 + 0.15)
	_box(cabinet + Vector3(0.0, 0.40, 0.0), Vector3(0.40, 0.80, 0.30), &"wood_stairs", true)
	_box(cabinet + Vector3(0.0, 0.81, 0.0), Vector3(0.44, 0.03, 0.34), &"wood_stairs")
	PropMeshes.sphere(self, cabinet + Vector3(0.0, 0.55, 0.155), 0.012, HouseMaterials.get_material(&"brass"))
	var glaze: Material = HouseMaterials.get_flat(Color(0.20, 0.34, 0.31))
	PropMeshes.sphere(self, cabinet + Vector3(0.0, 0.90, 0.0), 0.07, glaze, Vector3(1.0, 1.1, 1.0))
	PropMeshes.cylinder(self, cabinet + Vector3(0.0, 1.00, 0.0), 0.035, 0.03, 0.08, glaze, Vector3.ZERO, 16)


## A tall writing bureau standing on a west wall and facing +X: a chest of
## drawers, a sloping writing flap, and an open hutch of books on top, with a
## bottle and a small radio left on it.
func _bureau(wall_point: Vector3) -> void:
	var depth: float = 0.46
	var width: float = 0.96
	var base: Vector3 = wall_point + Vector3(depth * 0.5, 0.0, 0.0)
	# Solid for the player.
	var blocker: Node3D = _box(base + Vector3(0.0, 0.95, 0.0), Vector3(depth, 1.9, width), &"wood_stairs", true)
	(blocker.get_child(1) as MeshInstance3D).visible = false
	# Chest with three drawers.
	_box(base + Vector3(0.0, 0.40, 0.0), Vector3(depth, 0.80, width), &"wood_stairs")
	for i: int in 3:
		var y: float = 0.13 + 0.24 * float(i)
		_box(base + Vector3(depth * 0.5 + 0.004, y, 0.0), Vector3(0.012, 0.19, width - 0.08), &"wood_stairs")
		for side: float in [-0.22, 0.22]:
			PropMeshes.sphere(self, base + Vector3(depth * 0.5 + 0.02, y, side), 0.014, HouseMaterials.get_material(&"brass"))
	# Sloping flap.
	_box(base + Vector3(0.02, 0.92, 0.0), Vector3(depth * 0.9, 0.03, width), &"wood_stairs", false, Vector3(0.0, 0.0, 0.62))
	_box(base + Vector3(-0.10, 0.95, 0.0), Vector3(0.24, 0.30, width), &"wood_stairs")
	# Hutch: back, sides, shelves.
	var hutch_depth: float = 0.26
	var hutch: Vector3 = wall_point + Vector3(hutch_depth * 0.5, 0.0, 0.0)
	_box(hutch + Vector3(-hutch_depth * 0.5 + 0.01, 1.47, 0.0), Vector3(0.02, 0.86, width - 0.06), &"wood_stairs")
	for side: float in [-1.0, 1.0]:
		_box(hutch + Vector3(0.0, 1.47, side * (width * 0.5 - 0.04)), Vector3(hutch_depth, 0.86, 0.025), &"wood_stairs")
	for y: float in [1.10, 1.47, 1.89]:
		_box(hutch + Vector3(0.0, y, 0.0), Vector3(hutch_depth, 0.025, width - 0.06), &"wood_stairs")
	_books(hutch + Vector3(-0.02, 1.1125, 0.0), width - 0.14, 2601)
	_books(hutch + Vector3(-0.02, 1.4825, 0.0), width - 0.14, 2602)
	# On top: a green glass bottle and a small radio.
	var bottle: Material = HouseMaterials.get_flat(Color(0.14, 0.26, 0.18))
	PropMeshes.cylinder(self, hutch + Vector3(0.0, 2.0, -0.28), 0.04, 0.04, 0.2, bottle, Vector3.ZERO, 14)
	PropMeshes.cylinder(self, hutch + Vector3(0.0, 2.14, -0.28), 0.014, 0.035, 0.08, bottle, Vector3.ZERO, 12)
	_flat_box(hutch + Vector3(0.0, 1.98, 0.18), Vector3(0.16, 0.15, 0.28), Color(0.24, 0.17, 0.10))
	_flat_box(hutch + Vector3(0.081, 1.98, 0.13), Vector3(0.004, 0.10, 0.14), Color(0.62, 0.58, 0.44))
	PropMeshes.cylinder(self, hutch + Vector3(0.0, 2.17, 0.27), 0.003, 0.003, 0.28, HouseMaterials.get_material(&"brass"), Vector3(0.0, 0.0, 0.3), 6)


## A row of books standing on a shelf, centred on [param shelf] and running
## along Z, spines facing +X.
func _books(shelf: Vector3, length: float, seed_value: int) -> void:
	var spines: Array[Color] = [
		Color(0.36, 0.13, 0.10), Color(0.16, 0.24, 0.20), Color(0.46, 0.38, 0.22),
		Color(0.15, 0.17, 0.24), Color(0.32, 0.28, 0.22), Color(0.26, 0.10, 0.14),
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var z: float = -length * 0.5
	var limit: float = length * 0.5 - rng.randf_range(0.08, 0.2)
	while z < limit:
		var thickness: float = rng.randf_range(0.025, 0.05)
		var book_height: float = rng.randf_range(0.20, 0.29)
		_flat_box(
			shelf + Vector3(0.0, book_height * 0.5, z + thickness * 0.5),
			Vector3(0.18, book_height, thickness), spines[rng.randi() % spines.size()],
			Vector3(rng.randf_range(-0.03, 0.03), 0.0, 0.0)
		)
		z += thickness + 0.003
	# A couple lying flat at the end.
	for i: int in 2:
		_flat_box(shelf + Vector3(0.0, 0.017 + i * 0.033, length * 0.5 - 0.07),
			Vector3(0.19 - i * 0.02, 0.03, 0.14), spines[(i + 3) % spines.size()], Vector3(0.0, 0.2 * i, 0.0))


## Two shelves of books and a few lying flat, against a west wall.
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
	_books(base + Vector3(0.01, shelves[0] + 0.0125, 0.0), width - 0.06, 2611)
	_books(base + Vector3(0.01, shelves[1] + 0.0125, 0.0), width - 0.06, 2612)


## A cast-iron radiator of vertical sections, standing on the floor in front
## of a wall that runs along X (outer wall to +Z).
func _radiator(at: Vector3, width: float) -> void:
	var iron: Material = HouseMaterials.get_flat(Color(0.58, 0.58, 0.50))
	var sections: int = int(width / 0.075)
	for i: int in sections:
		var x: float = at.x - width * 0.5 + 0.075 * (float(i) + 0.5)
		PropMeshes.capsule(self, Vector3(x, at.y + 0.42, at.z), 0.028, 0.62, iron, Vector3.ZERO, Vector3(1.0, 1.0, 1.6))
	for y: float in [0.16, 0.68]:
		PropMeshes.cylinder(self, Vector3(at.x, at.y + y, at.z), 0.018, 0.018, width, iron, Vector3(0.0, 0.0, PI * 0.5), 10)
	for side: float in [-1.0, 1.0]:
		PropMeshes.cylinder(self, Vector3(at.x + side * (width * 0.5 - 0.03), at.y + 0.06, at.z), 0.012, 0.012, 0.12, iron, Vector3.ZERO, 8)


## A small wooden mantel clock with a cream face, facing -X.
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
	shade.add_to_group("local_lamp_fittings")
	shade.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var shade_material := HouseMaterials.get_material(&"lamp_shade").duplicate() as StandardMaterial3D
	shade_material.emission = Color(0.95, 0.66, 0.36)
	shade_material.emission_energy_multiplier = 0.55
	cover.material = shade_material

	var light := OmniLight3D.new()
	light.add_to_group("electric_lights")
	light.add_to_group("local_lamp_lights")
	light.name = "TableLampLight"
	light.position = base + Vector3(-0.1, 0.40, 0.0)
	light.light_color = Color(0.92, 0.80, 0.55)
	light.light_energy = 0.7
	light.omni_range = 4.5
	light.omni_attenuation = 1.8
	light.shadow_enabled = true
	light.shadow_blur = 2.0
	light.light_volumetric_fog_energy = 1.2
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
