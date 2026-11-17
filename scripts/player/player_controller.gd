class_name PlayerController
extends CharacterBody3D
## First-person controller for Daniel.
##
## Grounded walking only: no jump, no sprint stamina (GDD section 14).
## Stairs are expected to use ramp-shaped collision, so no step-up logic
## is needed here.
##
## Expected children:
##   Head (Node3D)           - pitches up and down
##   Head/Camera3D           - the view (BodyCam moves it locally)
##   BodyCam (BodyCamMotion) - walking sway, turn lean, soft settle

@export_group("Movement")
## Normal walking speed in metres per second.
@export var walk_speed: float = 2.4
## Speed while the walk_fast action is held.
@export var fast_speed: float = 3.8
## How quickly the body reaches its target speed (m/s^2).
@export var acceleration: float = 14.0
## How quickly the body stops when there is no input (m/s^2).
@export var deceleration: float = 18.0

@export_group("Look")
## Radians of rotation per pixel of mouse movement.
@export var mouse_sensitivity: float = 0.0022
## Maximum up/down look angle in degrees.
@export_range(10.0, 89.0) var pitch_limit_degrees: float = 85.0

## When false the player cannot move or look and the mouse cursor is released.
## UI screens and dialogue set this.
var control_enabled: bool = true:
	set(value):
		var changed: bool = value != control_enabled
		control_enabled = value
		_apply_mouse_mode()
		if changed:
			control_changed.emit(value)

## Emitted when control_enabled actually changes.
signal control_changed(enabled: bool)

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var _head: Node3D = $Head


func _ready() -> void:
	_apply_mouse_mode()
	Settings.preferences_changed.connect(_apply_preferences)
	_apply_preferences()

func _apply_preferences() -> void:
	mouse_sensitivity = Settings.get_number("mouse_sensitivity")
	($Head/Camera3D as Camera3D).fov = Settings.get_number("fov")


func _unhandled_input(event: InputEvent) -> void:
	if not control_enabled:
		return
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var motion := event as InputEventMouseMotion
		rotate_y(-motion.relative.x * mouse_sensitivity)
		var limit: float = deg_to_rad(pitch_limit_degrees)
		_head.rotation.x = clampf(
			_head.rotation.x - motion.relative.y * mouse_sensitivity, -limit, limit
		)


func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	var wants_fast := false
	if control_enabled:
		input_dir = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
		wants_fast = Input.is_action_pressed(&"walk_fast")

	var direction: Vector3 = global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)
	direction.y = 0.0
	direction = direction.normalized()

	var speed: float = fast_speed if wants_fast else walk_speed
	var target: Vector3 = direction * speed
	var rate: float = acceleration if direction != Vector3.ZERO else deceleration
	velocity.x = move_toward(velocity.x, target.x, rate * delta)
	velocity.z = move_toward(velocity.z, target.z, rate * delta)

	if not is_on_floor():
		velocity.y -= _gravity * delta

	move_and_slide()


## Returns the direction the camera is looking, in world space (body-cam motion
## included, so it matches the InteractionRay).
func get_look_direction() -> Vector3:
	return -($Head/Camera3D as Camera3D).global_transform.basis.z


func _apply_mouse_mode() -> void:
	Input.mouse_mode = (
		Input.MOUSE_MODE_CAPTURED if control_enabled else Input.MOUSE_MODE_VISIBLE
	)
