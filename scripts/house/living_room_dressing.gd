class_name LivingRoomDressing
extends Node3D
## Furniture, clutter and lighting for the living room.
##
## This is the project's visual target room (docs/ArtBible.md, section 2):
## one bare bulb, a flickering television, a curtained window and worn
## furniture. Everything is built from boxes in house space, where the living
## room spans x 0..5 and z 4.5..10 on the ground floor.
##
## Known stand-in: the window is a glowing panel on the wall, not a real
## opening. Real windows come with the door and window pass.

const BULB_POSITION := Vector3(2.5, 2.1, 7.3)
const TV_POSITION := Vector3(2.5, 0.0, 9.55)

var _tv_light: OmniLight3D
var _tv_screen_material: StandardMaterial3D
var _tv_noise := FastNoiseLite.new()
var _time: float = 0.0


func _ready() -> void:
	_tv_noise.seed = 7
	_tv_noise.frequency = 1.3
	_build_carpet()
	_build_sofa()
	_build_coffee_table()
	_build_armchair()
	_build_television()
	_build_bookshelf()
	_build_window()
	_build_radiator()
	_build_wall_pictures()
	_build_cardboard_boxes()
	_build_ceiling_bulb()


func _process(delta: float) -> void:
	# The television is the only moving light in the room.
	_time += delta
	var flicker: float = 0.5 + 0.5 * _tv_noise.get_noise_1d(_time * 6.0)
	var jump: float = 0.25 if _tv_noise.get_noise_1d(_time * 0.7 + 100.0) > 0.35 else 0.0
	_tv_light.light_energy = 0.25 + 0.45 * flicker + jump
	_tv_screen_material.emission_energy_multiplier = 0.9 + 0.9 * flicker + jump


func _build_carpet() -> void:
	_box(Vector3(2.5, 0.01, 7.75), Vector3(3.2, 0.02, 2.5), &"carpet")


func _build_sofa() -> void:
	# Faces south, toward the television.
	_box(Vector3(2.5, 0.21, 6.3), Vector3(2.0, 0.42, 0.85), &"fabric_olive", true)
	_box(Vector3(2.5, 0.60, 5.96), Vector3(2.0, 0.55, 0.18), &"fabric_olive", true)
	_box(Vector3(1.39, 0.33, 6.3), Vector3(0.22, 0.66, 0.85), &"fabric_olive", true)
	_box(Vector3(3.61, 0.33, 6.3), Vector3(0.22, 0.66, 0.85), &"fabric_olive", true)
	# Seat cushions, slightly uneven.
	_box(Vector3(2.04, 0.47, 6.36), Vector3(0.86, 0.11, 0.66), &"fabric_olive", false, Vector3(0.0, 0.0, 0.02))
	_box(Vector3(2.96, 0.46, 6.36), Vector3(0.86, 0.10, 0.66), &"fabric_olive", false, Vector3(0.0, 0.03, -0.02))
	# A folded blanket left on one end.
	_box(Vector3(3.2, 0.54, 6.3), Vector3(0.42, 0.06, 0.5), &"fabric_curtain", false, Vector3(0.0, 0.2, 0.0))


func _build_coffee_table() -> void:
	var center := Vector3(2.5, 0.0, 7.95)
	_box(center + Vector3(0.0, 0.40, 0.0), Vector3(1.0, 0.05, 0.55), &"wood_dark", true)
	for dx: float in [-0.44, 0.44]:
		for dz: float in [-0.22, 0.22]:
			_box(center + Vector3(dx, 0.19, dz), Vector3(0.05, 0.38, 0.05), &"wood_dark")
	# Clutter: a tin, a mug, a plate and a folded newspaper.
	_box(center + Vector3(-0.30, 0.48, 0.05), Vector3(0.07, 0.11, 0.07), &"metal_dull")
	_flat_box(center + Vector3(0.22, 0.47, -0.12), Vector3(0.08, 0.09, 0.08), Color(0.50, 0.46, 0.36))
	_flat_box(center + Vector3(0.05, 0.43, 0.12), Vector3(0.20, 0.015, 0.20), Color(0.58, 0.55, 0.45))
	_box(center + Vector3(-0.05, 0.43, -0.14), Vector3(0.30, 0.012, 0.21), &"paper", false, Vector3(0.0, 0.3, 0.0))


func _build_armchair() -> void:
	# Angled toward the television from the west side of the room.
	var chair := Node3D.new()
	chair.name = "Armchair"
	chair.position = Vector3(0.85, 0.0, 8.75)
	chair.rotation.y = deg_to_rad(-125.0)
	add_child(chair)
	_box(Vector3(0.0, 0.21, 0.0), Vector3(0.8, 0.42, 0.75), &"fabric_curtain", true, Vector3.ZERO, chair)
	_box(Vector3(0.0, 0.62, 0.32), Vector3(0.8, 0.62, 0.16), &"fabric_curtain", true, Vector3.ZERO, chair)
	_box(Vector3(-0.36, 0.33, 0.0), Vector3(0.14, 0.62, 0.75), &"fabric_curtain", false, Vector3.ZERO, chair)
	_box(Vector3(0.36, 0.33, 0.0), Vector3(0.14, 0.62, 0.75), &"fabric_curtain", false, Vector3.ZERO, chair)


func _build_television() -> void:
	# Stand against the south wall, screen facing north.
	_box(TV_POSITION + Vector3(0.0, 0.25, 0.0), Vector3(1.2, 0.5, 0.5), &"wood_dark", true)
	_box(TV_POSITION + Vector3(0.0, 0.80, 0.0), Vector3(0.76, 0.60, 0.55), &"plastic_dark")
	# The screen gets its own material instance so only this television flickers.
	_tv_screen_material = HouseMaterials.get_material(&"tv_screen").duplicate() as StandardMaterial3D
	var screen: MeshInstance3D = _mesh_only(
		TV_POSITION + Vector3(-0.06, 0.82, -0.28), Vector3(0.54, 0.42, 0.02)
	)
	(screen.mesh as BoxMesh).material = _tv_screen_material
	# Control strip and aerial.
	_box(TV_POSITION + Vector3(0.30, 0.82, -0.28), Vector3(0.10, 0.42, 0.02), &"metal_dull")
	_box(TV_POSITION + Vector3(-0.12, 1.32, 0.05), Vector3(0.012, 0.45, 0.012), &"metal_dull", false, Vector3(0.0, 0.0, 0.35))
	_box(TV_POSITION + Vector3(0.12, 1.32, 0.05), Vector3(0.012, 0.45, 0.012), &"metal_dull", false, Vector3(0.0, 0.0, -0.35))

	_tv_light = OmniLight3D.new()
	_tv_light.name = "TelevisionLight"
	_tv_light.position = TV_POSITION + Vector3(0.0, 0.85, -0.6)
	_tv_light.light_color = Color(0.50, 0.62, 0.80)
	_tv_light.omni_range = 4.5
	_tv_light.omni_attenuation = 1.6
	_tv_light.shadow_enabled = true
	add_child(_tv_light)


func _build_bookshelf() -> void:
	# Against the east wall, between the hall door and the south wall.
	var origin := Vector3(4.77, 0.0, 8.9)
	var depth: float = 0.32
	var width: float = 1.4
	var height: float = 1.9
	_box(origin + Vector3(0.0, height * 0.5, 0.0), Vector3(depth, height, width), &"wood_dark", true).visible = false
	_box(origin + Vector3(depth * 0.5 - 0.01, height * 0.5, 0.0), Vector3(0.02, height, width), &"wood_dark")
	for side: float in [-1.0, 1.0]:
		_box(origin + Vector3(0.0, height * 0.5, side * (width * 0.5 - 0.015)), Vector3(depth, height, 0.03), &"wood_dark")
	var shelf_heights: Array[float] = [0.04, 0.48, 0.92, 1.36, 1.86]
	for shelf_y: float in shelf_heights:
		_box(origin + Vector3(0.0, shelf_y, 0.0), Vector3(depth, 0.03, width), &"wood_dark")

	var book_colors: Array[Color] = [
		Color(0.35, 0.12, 0.10), Color(0.16, 0.22, 0.18), Color(0.42, 0.34, 0.18),
		Color(0.14, 0.15, 0.22), Color(0.30, 0.26, 0.20), Color(0.24, 0.10, 0.14),
	]
	var rng := RandomNumberGenerator.new()
	rng.seed = 1997
	for shelf_index: int in 4:
		var z: float = -width * 0.5 + 0.06
		var shelf_y: float = shelf_heights[shelf_index] + 0.015
		# Leave part of each shelf empty; a full shelf looks too tidy.
		var limit: float = width * 0.5 - rng.randf_range(0.1, 0.55)
		while z < limit:
			var thickness: float = rng.randf_range(0.03, 0.07)
			var book_height: float = rng.randf_range(0.24, 0.38)
			var lean: float = rng.randf_range(-0.04, 0.04)
			_flat_box(
				origin + Vector3(-0.03, shelf_y + book_height * 0.5, z + thickness * 0.5),
				Vector3(0.2, book_height, thickness),
				book_colors[rng.randi() % book_colors.size()],
				Vector3(lean, 0.0, 0.0)
			)
			z += thickness + 0.004


func _build_window() -> void:
	# West wall. A pale overcast glow behind half-drawn curtains.
	var center := Vector3(0.11, 1.5, 7.6)
	_mesh_only(center, Vector3(0.02, 1.2, 1.5)).mesh.surface_set_material(
		0, HouseMaterials.get_material(&"window_glow")
	)
	# Frame and a cross of glazing bars.
	_box(center + Vector3(0.02, 0.63, 0.0), Vector3(0.06, 0.07, 1.64), &"door_panel")
	_box(center + Vector3(0.02, -0.63, 0.0), Vector3(0.10, 0.07, 1.64), &"door_panel")
	_box(center + Vector3(0.02, 0.0, -0.78), Vector3(0.06, 1.2, 0.07), &"door_panel")
	_box(center + Vector3(0.02, 0.0, 0.78), Vector3(0.06, 1.2, 0.07), &"door_panel")
	_box(center + Vector3(0.02, 0.0, 0.0), Vector3(0.04, 1.2, 0.04), &"door_panel")
	_box(center + Vector3(0.02, 0.1, 0.0), Vector3(0.04, 0.04, 1.5), &"door_panel")
	# Curtain rail and two curtains, one pulled further across than the other.
	_box(center + Vector3(0.10, 0.78, 0.0), Vector3(0.025, 0.025, 2.0), &"metal_dull")
	_box(center + Vector3(0.10, -0.02, -0.62), Vector3(0.05, 1.6, 0.62), &"fabric_curtain")
	_box(center + Vector3(0.10, -0.02, 0.78), Vector3(0.05, 1.6, 0.36), &"fabric_curtain")

	var daylight := OmniLight3D.new()
	daylight.name = "WindowLight"
	daylight.position = center + Vector3(0.5, 0.0, 0.1)
	daylight.light_color = Color(0.55, 0.64, 0.70)
	daylight.light_energy = 0.35
	daylight.omni_range = 3.5
	daylight.omni_attenuation = 1.4
	add_child(daylight)


func _build_radiator() -> void:
	var center := Vector3(0.2, 0.42, 7.6)
	for i: int in 10:
		_box(center + Vector3(0.0, 0.0, -0.45 + i * 0.1), Vector3(0.09, 0.56, 0.06), &"radiator")
	_box(center + Vector3(0.0, 0.26, 0.0), Vector3(0.05, 0.03, 1.0), &"radiator")
	_box(center + Vector3(0.0, -0.26, 0.0), Vector3(0.05, 0.03, 1.0), &"radiator")


func _build_wall_pictures() -> void:
	# South wall, either side of the television. One hangs crooked.
	_picture(Vector3(0.95, 1.62, 9.87), Vector2(0.48, 0.62), 0.0)
	_picture(Vector3(4.0, 1.55, 9.87), Vector2(0.62, 0.44), deg_to_rad(5.0))


func _picture(center: Vector3, size: Vector2, tilt: float) -> void:
	var euler := Vector3(0.0, 0.0, tilt)
	_box(center, Vector3(size.x, size.y, 0.03), &"wood_dark", false, euler)
	_box(center + Vector3(0.0, 0.0, -0.012), Vector3(size.x - 0.08, size.y - 0.08, 0.02), &"canvas_dark", false, euler)


func _build_cardboard_boxes() -> void:
	# North-east corner, beside the archway.
	_box(Vector3(4.45, 0.22, 5.05), Vector3(0.55, 0.44, 0.5), &"cardboard", true, Vector3(0.0, 0.15, 0.0))
	_box(Vector3(4.5, 0.60, 5.05), Vector3(0.45, 0.32, 0.4), &"cardboard", false, Vector3(0.0, -0.3, 0.0))
	_box(Vector3(3.85, 0.15, 4.95), Vector3(0.4, 0.3, 0.35), &"cardboard", false, Vector3(0.0, 0.5, 0.0))


func _build_ceiling_bulb() -> void:
	var ceiling_y: float = HouseBuilder.WALL_HEIGHT
	var cord_length: float = ceiling_y - BULB_POSITION.y - 0.08
	# The fitting must not cast shadows: the light sits just below it and would
	# throw a large black disc onto the ceiling.
	var cord := _box(
		Vector3(BULB_POSITION.x, ceiling_y - cord_length * 0.5, BULB_POSITION.z),
		Vector3(0.015, cord_length, 0.015), &"plastic_dark"
	) as MeshInstance3D
	cord.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var socket := _box(
		BULB_POSITION + Vector3(0.0, 0.06, 0.0), Vector3(0.04, 0.05, 0.04), &"metal_dull"
	) as MeshInstance3D
	socket.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	var sphere := SphereMesh.new()
	sphere.radius = 0.045
	sphere.height = 0.09
	sphere.radial_segments = 8
	sphere.rings = 4
	sphere.material = HouseMaterials.get_material(&"bulb")
	var bulb := MeshInstance3D.new()
	bulb.mesh = sphere
	bulb.position = BULB_POSITION
	bulb.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(bulb)

	var light := OmniLight3D.new()
	light.name = "BulbLight"
	light.position = BULB_POSITION + Vector3(0.0, -0.08, 0.0)
	light.light_color = Color(1.0, 0.76, 0.42)
	light.light_energy = 1.5
	light.omni_range = 6.5
	light.omni_attenuation = 1.5
	light.shadow_enabled = true
	add_child(light)


# --- Helpers ----------------------------------------------------------------

## Adds a box. With [param solid] it also blocks the player.
func _box(
	center: Vector3, size: Vector3, material: StringName, solid: bool = false,
	euler: Vector3 = Vector3.ZERO, parent: Node3D = self
) -> Node3D:
	var mesh_instance: MeshInstance3D = _make_mesh(size, HouseMaterials.get_material(material))
	if not solid:
		mesh_instance.position = center
		mesh_instance.rotation = euler
		parent.add_child(mesh_instance)
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
	parent.add_child(body)
	return body


## Adds a non-solid box with a plain colour.
func _flat_box(center: Vector3, size: Vector3, color: Color, euler: Vector3 = Vector3.ZERO) -> void:
	var mesh_instance: MeshInstance3D = _make_mesh(size, HouseMaterials.get_flat(color))
	mesh_instance.position = center
	mesh_instance.rotation = euler
	add_child(mesh_instance)


## Adds a non-solid box with no material yet; the caller assigns one.
func _mesh_only(center: Vector3, size: Vector3) -> MeshInstance3D:
	var mesh_instance: MeshInstance3D = _make_mesh(size, null)
	mesh_instance.position = center
	add_child(mesh_instance)
	return mesh_instance


func _make_mesh(size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	return mesh_instance
