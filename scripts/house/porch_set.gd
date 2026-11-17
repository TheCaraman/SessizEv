extends Node3D
## The front porch and the bit of street the peephole sees (IMMERSION I-05).
##
## Authored in world coordinates in front of the main door (x 7.5, z 12.5,
## facing +Z). Nothing here is walkable or collides: it is a set for the door
## view and the front windows, not an open world. The visitor's standing spot
## (x 6.7..8.3, z 12.9..14.0) is kept clear.
##
## Lighting uses the house's existing groups, so day, night and power cuts
## follow the same rules as indoors (scripts/dev/house_blockout.gd):
##   window_lights   - daylight on the porch, scaled by the clock
##   moon_lights     - the street lamp and night sky fill, independent of power
##   electric_lights - the porch lantern, off when the house loses power

const DOOR_X: float = 7.5
const FRONT: float = 12.5
const SLAB_TOP: float = -0.03
const GROUND: float = -0.18

var _materials: Dictionary = {}


func _ready() -> void:
	name = "PorchSet"
	_porch()
	_canopy()
	_lantern()
	_flowers()
	_path_and_gate()
	_street_lamp()
	_kerbs_and_hedge()
	_side_trees()
	_lights()


func _porch() -> void:
	# Concrete slab the width of the door surround, one step down to the path.
	_box(Vector3(DOOR_X, SLAB_TOP - 0.09, 13.45), Vector3(2.7, 0.18, 1.9), &"concrete")
	_box(Vector3(DOOR_X, GROUND + 0.035, 14.65), Vector3(1.6, 0.07, 0.5), &"concrete")
	# Worn coir mat on the threshold.
	_box(Vector3(DOOR_X, SLAB_TOP + 0.008, 12.95), Vector3(0.95, 0.016, 0.55), &"mat")
	# Low side walls where the porch meets the facade.
	for side: float in [-1.0, 1.0]:
		_box(Vector3(DOOR_X + side * 1.32, SLAB_TOP + 0.11, 13.3), Vector3(0.1, 0.22, 1.6), &"brick")


func _canopy() -> void:
	# Small flat canopy over the door on two timber brackets.
	_box(Vector3(DOOR_X, 2.62, 13.18), Vector3(2.3, 0.1, 1.36), &"canopy")
	_box(Vector3(DOOR_X, 2.56, 13.84), Vector3(2.36, 0.12, 0.06), &"trim")
	for side: float in [-1.0, 1.0]:
		var bracket := _box(Vector3(DOOR_X + side * 1.05, 2.3, 12.86), Vector3(0.08, 0.08, 0.72), &"trim")
		bracket.rotation.x = deg_to_rad(35.0)


func _lantern() -> void:
	# Brass wall lantern to the right of the door, frosted glass that glows.
	var base := Vector3(8.42, 2.0, FRONT + 0.1)
	_box(base + Vector3(0.0, 0.0, -0.04), Vector3(0.14, 0.24, 0.04), &"brass")
	_box(base + Vector3(0.0, 0.17, 0.04), Vector3(0.2, 0.04, 0.2), &"brass")
	var glass := _box(base + Vector3(0.0, 0.03, 0.04), Vector3(0.16, 0.26, 0.16), &"lantern_glass")
	glass.add_to_group("electric_fittings")
	glass.add_to_group("local_lamp_fittings")


func _flowers() -> void:
	# Two terracotta pots on the front corners of the porch, framing the view
	# from the door without standing where a visitor waits; a trough under the window.
	for x: float in [6.42, 8.58]:
		var pot := Vector3(x, SLAB_TOP, 14.05)
		_cylinder(pot + Vector3(0.0, 0.17, 0.0), 0.17, 0.13, 0.34, &"terracotta")
		_cylinder(pot + Vector3(0.0, 0.33, 0.0), 0.15, 0.15, 0.02, &"soil")
		_bush(pot + Vector3(0.0, 0.45, 0.0), 0.2, int(x * 10.0))
	var trough := Vector3(9.31, -0.1, FRONT + 0.25)
	_box(trough + Vector3(0.0, 0.18, 0.0), Vector3(1.0, 0.3, 0.3), &"terracotta")
	_bush(trough + Vector3(-0.25, 0.42, 0.0), 0.16, 7)
	_bush(trough + Vector3(0.25, 0.42, 0.0), 0.16, 9)


func _bush(center: Vector3, radius: float, seed_value: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i: int in 5:
		var offset := Vector3(rng.randf_range(-0.6, 0.6), rng.randf_range(-0.2, 0.5), rng.randf_range(-0.6, 0.6)) * radius
		_sphere(center + offset, radius * rng.randf_range(0.55, 0.8), &"leaves")
	for i: int in 6:
		var angle: float = TAU * float(i) / 6.0 + rng.randf() * 0.4
		var at := center + Vector3(cos(angle) * radius * 0.7, radius * rng.randf_range(0.2, 0.6), sin(angle) * radius * 0.7)
		_sphere(at + (at - center).normalized() * radius * 0.25, 0.055, &"blossom_red" if i % 2 == 0 else &"blossom_yellow")


func _path_and_gate() -> void:
	# Garden gate where the path meets the fence, left ajar, and a mailbox.
	var fence_z: float = 20.5
	for x: float in [6.85, 8.15]:
		_box(Vector3(x, 0.6, fence_z), Vector3(0.12, 1.4, 0.12), &"trim")
	var gate := Node3D.new()
	gate.position = Vector3(6.9, 0.0, fence_z)
	gate.rotation.y = deg_to_rad(-35.0)
	add_child(gate)
	for y: float in [0.35, 0.85]:
		_box(Vector3(0.6, y, 0.0), Vector3(1.15, 0.07, 0.05), &"trim", gate)
	for i: int in 6:
		_box(Vector3(0.12 + 0.2 * float(i), 0.6, 0.0), Vector3(0.06, 0.9, 0.035), &"trim", gate)
	# Close the wide gap in the old fence up to the gate posts.
	for span: Vector2 in [Vector2(5.0, 6.8), Vector2(8.2, 12.0)]:
		var mid: float = (span.x + span.y) * 0.5
		for y: float in [0.4, 0.9]:
			_box(Vector3(mid, y, fence_z), Vector3(span.y - span.x, 0.09, 0.07), &"fence")
	var post := Vector3(8.65, 0.0, fence_z - 0.25)
	_box(post + Vector3(0.0, 0.55, 0.0), Vector3(0.08, 1.1, 0.08), &"trim")
	_box(post + Vector3(0.0, 1.18, 0.0), Vector3(0.24, 0.22, 0.4), &"mailbox")


func _street_lamp() -> void:
	# Across the road: a tall lamp post with an arm reaching over the kerb.
	var foot := Vector3(10.6, GROUND, 25.4)
	_cylinder(foot + Vector3(0.0, 2.2, 0.0), 0.06, 0.09, 4.4, &"iron")
	_box(foot + Vector3(0.0, 4.35, -0.45), Vector3(0.06, 0.06, 0.9), &"iron")
	var head := _box(foot + Vector3(0.0, 4.28, -0.85), Vector3(0.32, 0.12, 0.5), &"street_glass")
	head.name = "StreetLampHead"


func _lights() -> void:
	# Daylight on the porch: only through the clock, like the windows.
	var day := OmniLight3D.new()
	day.name = "PorchDaylight"
	day.position = Vector3(DOOR_X, 3.6, 16.0)
	day.light_color = Color(0.86, 0.9, 0.92)
	day.light_energy = 1.6
	day.omni_range = 9.0
	day.shadow_enabled = true
	day.add_to_group("window_lights")
	add_child(day)
	# Porch lantern: household power, so a power cut puts it out.
	var lantern := OmniLight3D.new()
	lantern.name = "PorchLantern"
	lantern.position = Vector3(8.42, 1.95, FRONT + 0.35)
	lantern.light_color = Color(1.0, 0.78, 0.5)
	lantern.light_energy = 1.1
	lantern.omni_range = 4.5
	lantern.omni_attenuation = 1.4
	lantern.shadow_enabled = true
	lantern.add_to_group("electric_lights")
	lantern.add_to_group("local_lamp_lights")
	add_child(lantern)
	# Street lamp: sodium orange, night only, not on the house supply.
	var street := OmniLight3D.new()
	street.name = "StreetLamp"
	street.position = Vector3(10.6, 3.9, 24.5)
	street.light_color = Color(1.0, 0.72, 0.42)
	street.light_energy = 2.4
	street.omni_range = 8.0
	street.shadow_enabled = true
	street.add_to_group("moon_lights")
	add_child(street)


func _material(kind: StringName) -> StandardMaterial3D:
	if _materials.has(kind):
		return _materials[kind]
	var colors: Dictionary = {
		&"concrete": Color(0.55, 0.53, 0.48), &"mat": Color(0.36, 0.27, 0.17), &"brick": Color(0.48, 0.3, 0.24),
		&"canopy": Color(0.3, 0.27, 0.24), &"trim": Color(0.74, 0.73, 0.66), &"brass": Color(0.55, 0.43, 0.22),
		&"lantern_glass": Color(0.95, 0.88, 0.7), &"terracotta": Color(0.62, 0.34, 0.22), &"soil": Color(0.18, 0.13, 0.1),
		&"leaves": Color(0.22, 0.36, 0.2), &"blossom_red": Color(0.72, 0.16, 0.14), &"blossom_yellow": Color(0.86, 0.72, 0.24),
		&"fence": Color(0.32, 0.32, 0.25), &"mailbox": Color(0.24, 0.3, 0.27), &"iron": Color(0.16, 0.17, 0.16),
		&"street_glass": Color(0.95, 0.8, 0.55),
	}
	var material := StandardMaterial3D.new()
	material.albedo_color = colors.get(kind, Color.MAGENTA)
	material.roughness = 0.9
	if kind == &"lantern_glass":
		material.emission_enabled = true
		material.emission = Color(1.0, 0.8, 0.5)
		material.emission_energy_multiplier = 1.6
	if kind == &"street_glass":
		material.emission_enabled = true
		material.emission = Color(1.0, 0.72, 0.42)
		material.emission_energy_multiplier = 1.2
	_materials[kind] = material
	return material


func _box(at: Vector3, size: Vector3, kind: StringName, parent: Node3D = null) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = at
	instance.material_override = _material(kind)
	(parent if parent != null else self).add_child(instance)
	return instance


func _cylinder(at: Vector3, top: float, bottom: float, height: float, kind: StringName) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = top
	mesh.bottom_radius = bottom
	mesh.height = height
	mesh.radial_segments = 14
	instance.mesh = mesh
	instance.position = at
	instance.material_override = _material(kind)
	add_child(instance)
	return instance


func _sphere(at: Vector3, radius: float, kind: StringName) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 6
	instance.mesh = mesh
	instance.position = at
	instance.material_override = _material(kind)
	add_child(instance)
	return instance


func _kerbs_and_hedge() -> void:
	# Lit pavements on both sides of the road (the painted ground does not take
	# light), and a ragged hedge along the fence so the lawn is not one flat sheet.
	_box(Vector3(7.5, GROUND + 0.04, 21.1), Vector3(26.0, 0.08, 0.7), &"concrete")
	_box(Vector3(7.5, GROUND + 0.04, 26.1), Vector3(26.0, 0.08, 1.0), &"concrete")
	var rng := RandomNumberGenerator.new()
	rng.seed = 2117
	for x: float in [1.2, 2.6, 3.9, 5.3, 9.6, 11.0, 12.5, 13.8]:
		_bush(Vector3(x + rng.randf_range(-0.3, 0.3), 0.25, 20.1), rng.randf_range(0.32, 0.45), rng.randi())


func _side_trees() -> void:
	# Dark tree lines past both ends of the painted street, so a wide door view
	# never shows empty black beside it. Flat and unlit like the painted street,
	# and dimmed with it at night (window_backdrops).
	for x: float in [-17.0, 32.0]:
		var trees := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(10.0, 14.0, 12.0)
		trees.mesh = mesh
		trees.position = Vector3(x, 6.8, 24.0)
		var material := StandardMaterial3D.new()
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.albedo_color = Color(0.17, 0.24, 0.19)
		trees.material_override = material
		trees.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		trees.add_to_group("window_backdrops")
		add_child(trees)
