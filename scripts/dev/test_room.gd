extends Node3D
## Developer test room for the first-person controller.
##
## Not part of the shipped game. It contains a floor, four walls, a partition
## with a 0.9 m door-width gap, and a ramp up to a 1 m platform, so walking,
## door clearance and stair-style ramps can be checked before the house exists.
##
## Geometry is built in code from boxes; the same approach will be used for the
## house blockout (docs/DecisionLog.md, K-009).

const FLOOR_COLOR := Color(0.33, 0.29, 0.22)
const WALL_COLOR := Color(0.55, 0.49, 0.36)
const RAMP_COLOR := Color(0.42, 0.30, 0.22)

@onready var _player: PlayerController = $Player


func _ready() -> void:
	_build_lighting()

	# Floor, 12 x 12 m, top surface at y = 0.
	_add_box(Vector3(0.0, -0.1, 0.0), Vector3(12.0, 0.2, 12.0), FLOOR_COLOR)

	# Outer walls, 2.6 m high.
	_add_box(Vector3(0.0, 1.3, -6.1), Vector3(12.4, 2.6, 0.2), WALL_COLOR)
	_add_box(Vector3(0.0, 1.3, 6.1), Vector3(12.4, 2.6, 0.2), WALL_COLOR)
	_add_box(Vector3(-6.1, 1.3, 0.0), Vector3(0.2, 2.6, 12.0), WALL_COLOR)
	_add_box(Vector3(6.1, 1.3, 0.0), Vector3(0.2, 2.6, 12.0), WALL_COLOR)

	# Partition at z = -2 with a 0.9 m gap centred on x = 0 (minimum door width).
	# It stops at x = 3 so the ramp lane on the east side stays open.
	_add_box(Vector3(-3.225, 1.3, -2.0), Vector3(5.55, 2.6, 0.2), WALL_COLOR)
	_add_box(Vector3(1.725, 1.3, -2.0), Vector3(2.55, 2.6, 0.2), WALL_COLOR)

	# Ramp rising 1 m over 4 m (about 14 degrees) toward -Z, then a platform.
	var ramp_angle: float = atan2(1.0, 4.0)
	_add_box(
		Vector3(4.5, 0.5 - 0.1 * cos(ramp_angle), -1.0),
		Vector3(1.2, 0.2, sqrt(17.0)),
		RAMP_COLOR,
		Vector3(ramp_angle, 0.0, 0.0)
	)
	_add_box(Vector3(4.5, 0.5, -4.5), Vector3(3.0, 1.0, 3.0), RAMP_COLOR)


func _unhandled_input(event: InputEvent) -> void:
	# Until a pause menu exists, the pause key releases or recaptures the mouse.
	if event.is_action_pressed(&"pause"):
		_player.control_enabled = not _player.control_enabled


func _build_lighting() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.05, 0.05, 0.045)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.50, 0.40)
	environment.ambient_light_energy = 0.35
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)

	var lamp := OmniLight3D.new()
	lamp.position = Vector3(0.0, 2.4, 1.5)
	lamp.omni_range = 14.0
	lamp.light_color = Color(1.0, 0.86, 0.62)
	lamp.light_energy = 1.4
	lamp.shadow_enabled = true
	add_child(lamp)


## Adds a solid, visible box. [param euler] is the rotation in radians.
func _add_box(
	center: Vector3, size: Vector3, color: Color, euler: Vector3 = Vector3.ZERO
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = center
	body.rotation = euler

	var shape := BoxShape3D.new()
	shape.size = size
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)

	var mesh := BoxMesh.new()
	mesh.size = size
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 1.0
	mesh.material = material
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = mesh
	body.add_child(mesh_instance)

	add_child(body)
	return body
