class_name PropMeshes
extends RefCounted
## Small shaped meshes for the corridor props, so they stop reading as boxes
## (CORRIDOR-REFERENCE-002).
##
## Everything here is generated from primitives or a few lines of geometry;
## no external model files. Builders return a MeshInstance3D ready to be
## positioned by the caller, or add parts under a given parent node.

## A hanging cloth panel with vertical folds: curtains, coats, a towel.
## The panel spans X from -top_width/2 to +top_width/2 at the top and to
## +-bottom_width/2 at the hem, hangs from y = 0 down to y = -height, and its
## folds bulge along Z by up to [param depth]. [param seed_value] varies the
## hem and the fold rhythm so two panels are never identical.
static func cloth_mesh(
	top_width: float, bottom_width: float, height: float, folds: int, depth: float, seed_value: int
) -> ArrayMesh:
	var columns: int = maxi(folds * 6, 6)
	var rows: int = 14
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var phase: float = rng.randf() * TAU
	# Each fold gets its own small irregularity in depth.
	var fold_scale := PackedFloat32Array()
	for i: int in folds + 2:
		fold_scale.append(rng.randf_range(0.7, 1.15))
	var hem := PackedFloat32Array()
	for i: int in columns + 1:
		hem.append(rng.randf_range(0.0, 0.025))

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for row: int in rows + 1:
		var v: float = float(row) / float(rows)
		var width: float = lerpf(top_width, bottom_width, v)
		for column: int in columns + 1:
			var u: float = float(column) / float(columns)
			var along: float = u * float(folds)
			var fold_index: int = mini(int(along), folds)
			# Folds are tighter at the top where the cloth is gathered.
			var bulge: float = sin(along * TAU + phase) * depth * fold_scale[fold_index]
			bulge *= lerpf(0.75, 1.0, v)
			var y: float = -v * height
			if row == rows:
				y += hem[column]
			st.set_uv(Vector2(u, v))
			st.add_vertex(Vector3((u - 0.5) * width, y, bulge))
	for row: int in rows:
		for column: int in columns:
			var a: int = row * (columns + 1) + column
			var b: int = a + 1
			var c: int = a + columns + 1
			var d: int = c + 1
			st.add_index(a)
			st.add_index(c)
			st.add_index(b)
			st.add_index(b)
			st.add_index(c)
			st.add_index(d)
	st.generate_normals()
	return st.commit()


## A cylinder or cone part. [param segments] = 4 gives a square frustum.
static func cylinder(
	parent: Node3D, center: Vector3, top_radius: float, bottom_radius: float, height: float,
	material: Material, euler: Vector3 = Vector3.ZERO, segments: int = 24
) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = segments
	mesh.rings = 1
	mesh.material = material
	return _place(parent, mesh, center, euler)


## A capsule part, optionally squashed with [param scale].
static func capsule(
	parent: Node3D, center: Vector3, radius: float, height: float, material: Material,
	euler: Vector3 = Vector3.ZERO, scale: Vector3 = Vector3.ONE
) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 16
	mesh.rings = 6
	mesh.material = material
	var part: MeshInstance3D = _place(parent, mesh, center, euler)
	part.scale = scale
	return part


## A sphere part, optionally squashed with [param scale].
static func sphere(
	parent: Node3D, center: Vector3, radius: float, material: Material,
	scale: Vector3 = Vector3.ONE
) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 18
	mesh.rings = 9
	mesh.material = material
	var part: MeshInstance3D = _place(parent, mesh, center, Vector3.ZERO)
	part.scale = scale
	return part


## A plain box part.
static func box(
	parent: Node3D, center: Vector3, size: Vector3, material: Material,
	euler: Vector3 = Vector3.ZERO
) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	return _place(parent, mesh, center, euler)


## An old desk telephone with a rotary dial and a curled cord, built around
## [param root] with its base on y = 0, facing +X.
static func telephone(root: Node3D) -> void:
	var body: Material = HouseMaterials.get_flat(Color(0.09, 0.09, 0.085))
	var dial: Material = HouseMaterials.get_flat(Color(0.55, 0.53, 0.46))
	# A sloping body: a four-sided frustum turned so its faces line up.
	cylinder(root, Vector3(0.0, 0.035, 0.0), 0.075, 0.11, 0.07, body, Vector3(0.0, PI * 0.25, 0.0), 4)
	cylinder(root, Vector3(0.0, 0.085, 0.0), 0.05, 0.075, 0.03, body, Vector3(0.0, PI * 0.25, 0.0), 4)
	# Dial on the front slope.
	cylinder(root, Vector3(0.062, 0.062, 0.0), 0.04, 0.04, 0.008, dial, Vector3(0.0, 0.0, -PI * 0.5 + 0.55))
	cylinder(root, Vector3(0.066, 0.064, 0.0), 0.012, 0.012, 0.010, body, Vector3(0.0, 0.0, -PI * 0.5 + 0.55))
	# Handset lying across the cradle.
	capsule(root, Vector3(-0.005, 0.118, 0.0), 0.017, 0.22, body, Vector3(PI * 0.5, 0.0, 0.0))
	for side: float in [-1.0, 1.0]:
		cylinder(root, Vector3(-0.005, 0.108, side * 0.09), 0.032, 0.026, 0.035, body)
	# The cord coils down beside the body.
	for i: int in 9:
		var t: float = float(i) / 8.0
		sphere(root, Vector3(-0.05 - 0.05 * t, 0.06 - 0.055 * t, 0.10 + 0.05 * sin(t * PI)), 0.011, body)


## One shoe with its toe pointing +X, sole on y = 0.
static func shoe(root: Node3D, center: Vector3, color: Color, yaw: float) -> void:
	var shoe_root := Node3D.new()
	shoe_root.position = center
	shoe_root.rotation.y = yaw
	root.add_child(shoe_root)
	var leather: Material = HouseMaterials.get_flat(color)
	var sole: Material = HouseMaterials.get_flat(Color(0.05, 0.045, 0.04))
	capsule(shoe_root, Vector3(0.0, 0.012, 0.0), 0.045, 0.27, sole, Vector3(0.0, 0.0, PI * 0.5), Vector3(1.0, 1.0, 0.27))
	capsule(shoe_root, Vector3(0.02, 0.045, 0.0), 0.042, 0.22, leather, Vector3(0.0, 0.0, PI * 0.5), Vector3(0.7, 1.0, 1.0))
	# Heel counter, a little taller at the back.
	sphere(shoe_root, Vector3(-0.075, 0.06, 0.0), 0.042, leather, Vector3(1.0, 1.2, 1.0))
	# Opening.
	sphere(shoe_root, Vector3(-0.045, 0.085, 0.0), 0.028, sole, Vector3(1.4, 0.25, 0.9))


## A coat hanging from a hook at [param hook], hanging toward +Z off the wall.
static func coat(root: Node3D, hook: Vector3, color: Color, length: float, seed_value: int) -> void:
	var cloth: Material = HouseMaterials.get_material(&"coat_cloth").duplicate()
	(cloth as StandardMaterial3D).albedo_color = color
	# Hung by its loop, a coat pinches in at the collar and falls open below.
	var body := MeshInstance3D.new()
	body.mesh = cloth_mesh(0.12, 0.40, length, 4, 0.03, seed_value)
	body.mesh.surface_set_material(0, cloth)
	body.position = hook + Vector3(0.0, -0.02, 0.06)
	root.add_child(body)
	# A second, shorter layer over the top reads as the folded-over collar
	# and the tops of the sleeves.
	var collar := MeshInstance3D.new()
	collar.mesh = cloth_mesh(0.10, 0.30, length * 0.32, 3, 0.02, seed_value + 3)
	collar.mesh.surface_set_material(0, cloth)
	collar.position = hook + Vector3(0.0, -0.025, 0.085)
	root.add_child(collar)
	# Hanging loop.
	cylinder(root, hook + Vector3(0.0, 0.0, 0.05), 0.006, 0.006, 0.05, HouseMaterials.get_flat(color.darkened(0.4)), Vector3.ZERO, 6)


## A furled umbrella leaning at an angle, tip on y = 0.
static func umbrella(root: Node3D, tip: Vector3, color: Color, lean: Vector3) -> void:
	var umbrella_root := Node3D.new()
	umbrella_root.position = tip
	umbrella_root.rotation = lean
	root.add_child(umbrella_root)
	var fabric: Material = HouseMaterials.get_flat(color)
	var metal: Material = HouseMaterials.get_material(&"brass")
	cylinder(umbrella_root, Vector3(0.0, 0.03, 0.0), 0.004, 0.002, 0.06, metal)
	# The furled canopy: a long cone, fattest a third of the way up.
	cylinder(umbrella_root, Vector3(0.0, 0.20, 0.0), 0.035, 0.008, 0.28, fabric, Vector3.ZERO, 8)
	cylinder(umbrella_root, Vector3(0.0, 0.46, 0.0), 0.012, 0.035, 0.24, fabric, Vector3.ZERO, 8)
	cylinder(umbrella_root, Vector3(0.0, 0.70, 0.0), 0.007, 0.007, 0.25, metal)
	# Crook handle.
	var handle: Material = HouseMaterials.get_material(&"wood_stairs")
	var torus := TorusMesh.new()
	torus.inner_radius = 0.025
	torus.outer_radius = 0.042
	torus.rings = 16
	torus.ring_segments = 8
	torus.material = handle
	var crook := _place(umbrella_root, torus, Vector3(0.033, 0.83, 0.0), Vector3(PI * 0.5, 0.0, 0.0))
	crook.scale = Vector3(1.0, 1.0, 1.0)


## A framed picture on a wall, facing [param facing] (+X or -X), with a
## pale mat around the image. The frame has real depth and bevels.
static func framed_picture(
	root: Node3D, center: Vector3, size: Vector2, facing: float, tilt: float, picture_kind: StringName
) -> Node3D:
	var frame_root := Node3D.new()
	frame_root.position = center
	# Local space: X out of the wall, Y up, Z along the wall.
	frame_root.rotation = Vector3(tilt, 0.0 if facing > 0.0 else PI, 0.0)
	root.add_child(frame_root)
	var wood: Material = HouseMaterials.get_material(&"picture_frame")
	var mat: Material = HouseMaterials.get_flat(Color(0.70, 0.66, 0.55))
	var border: float = 0.035
	# Four moulded sides: a flat back strip and a rounded lip.
	for side: float in [-1.0, 1.0]:
		box(frame_root, Vector3(0.012, side * (size.y - border) * 0.5, 0.0), Vector3(0.024, border, size.x), wood)
		box(frame_root, Vector3(0.012, 0.0, side * (size.x - border) * 0.5), Vector3(0.024, size.y, border), wood)
		cylinder(frame_root, Vector3(0.025, side * (size.y * 0.5 - border + 0.006), 0.0), 0.007, 0.007, size.x - border * 2.0 + 0.012, wood, Vector3(PI * 0.5, 0.0, 0.0), 8)
		cylinder(frame_root, Vector3(0.025, 0.0, side * (size.x * 0.5 - border + 0.006)), 0.007, 0.007, size.y - border * 2.0 + 0.012, wood, Vector3.ZERO, 8)
	box(frame_root, Vector3(0.004, 0.0, 0.0), Vector3(0.008, size.y - border * 2.0, size.x - border * 2.0), mat)
	# The image itself, set into the mat.
	var image := QuadMesh.new()
	var inset: float = 0.04
	image.size = Vector2(size.x - (border + inset) * 2.0, size.y - (border + inset) * 2.0)
	image.material = HouseMaterials.get_material(picture_kind)
	var face := _place(frame_root, image, Vector3(0.0095, 0.0, 0.0), Vector3(0.0, PI * 0.5, 0.0))
	face.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return frame_root


static func _place(parent: Node3D, mesh: Mesh, center: Vector3, euler: Vector3) -> MeshInstance3D:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	part.position = center
	part.rotation = euler
	parent.add_child(part)
	return part
