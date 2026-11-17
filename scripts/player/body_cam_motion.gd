class_name BodyCamMotion
extends Node
## BODYCAM-002: body-worn camera motion for Daniel's view.
##
## Walking rocks the camera with each step (a dip, a side shift and a small
## roll), turning makes it lean into the turn and trail the body a little, and
## stopping lets it settle softly instead of snapping. Mechanics only: no blur,
## pixelation or colour effect.
##
## The motion lives in Head/Camera3D's *local* transform, so the mouse look
## (Player yaw, Head pitch) is untouched and the InteractionRay, a child of the
## camera, always points where the view points.
##
## The camera is returned to rest at once, and left alone, while the player has
## no control (dialogue, room view, shelter, journal), while the game is paused
## and during a door transition (RoomDoor tweens the camera itself). The
## camera_motion setting below 0.5 turns all of it off.

## Metres walked per full gait cycle (two steps).
const STRIDE: float = 1.5
## Vertical dip of each step at normal walking speed, metres.
const BOB_HEIGHT: float = 0.022
## Side shift over a gait cycle at walking speed, metres.
const SWAY_SIDE: float = 0.013
## Roll that follows the side shift, degrees.
const SWAY_ROLL_DEGREES: float = 0.75
## Small nod with each step, degrees.
const STEP_PITCH_DEGREES: float = 0.3
## Lean into a turn, degrees of roll per radian per second of turning.
const TURN_LEAN: float = 0.6
const TURN_LEAN_MAX_DEGREES: float = 1.6
## How far the view trails behind the body while turning, degrees per rad/s.
const TURN_LAG: float = 0.5
const TURN_LAG_MAX_DEGREES: float = 1.1
## Upper bound on the camera offset from the head, metres. The body radius is
## 0.38 m and the near-plane corners reach 0.122 m at FOV 95, so the view
## stays clear of walls (CAMERA-CLIP-001).
const MAX_OFFSET: float = 0.06
## Spring for the turn lean and lag. Slightly under-damped, so the end of a
## turn settles with a soft, small overshoot.
const STIFFNESS: float = 110.0
const DAMPING_RATIO: float = 0.78
## How fast the gait strength follows the walking speed (1/s).
const GAIT_RESPONSE: float = 7.0
## How fast the measured turn rate follows the mouse (1/s).
const TURN_RESPONSE: float = 10.0
## A yaw change larger than this in one frame is a teleport, not a turn.
const TELEPORT_TURN: float = 0.6
## Below this (metres / radians) the motion counts as rest.
const REST_EPSILON: float = 0.0002

var _player: PlayerController
var _camera: Camera3D
var _strength: float = 1.0
var _door_transition: bool = false
## True while the body cam is running (used to restart the turn measurement).
var _applied: bool = false
## True when the camera currently carries an offset written by this node.
var _moved: bool = false
var _phase: float = 0.0
var _gait: float = 0.0
var _yaw_rate: float = 0.0
var _last_yaw: float = 0.0
var _rotation: Vector3 = Vector3.ZERO
var _rotation_speed: Vector3 = Vector3.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = get_parent() as PlayerController
	_camera = _player.get_node("Head/Camera3D") as Camera3D
	_last_yaw = _player.rotation.y
	Settings.preferences_changed.connect(_read_setting)
	EventBus.door_transition_changed.connect(_on_door_transition)
	_player.control_changed.connect(_on_control_changed)
	_read_setting()


## Whether the camera is free to move right now.
func is_active() -> bool:
	return (
		_strength > 0.0 and not _door_transition and _player.control_enabled
		and not get_tree().paused
	)


## Current camera offset from the head (local position, metres).
func get_offset() -> Vector3:
	return _camera.position


func _read_setting() -> void:
	var value: float = Settings.get_number("camera_motion")
	_strength = value if value >= 0.5 else 0.0
	if _strength == 0.0 and not _door_transition:
		_rest()


func _on_door_transition(active: bool) -> void:
	_door_transition = active
	# RoomDoor records the camera pose right after emitting this, then tweens
	# the camera; rest it first so the recorded pose is the plain head pose.
	if active:
		_rest()


func _on_control_changed(enabled: bool) -> void:
	# Dialogue, rooms, shelter and journal take control: rest before they draw.
	if not enabled and not _door_transition:
		_rest()


func _process(delta: float) -> void:
	if not is_active():
		if _applied:
			_rest()
		return
	if delta <= 0.0:
		return
	if not _applied:
		_last_yaw = _player.rotation.y
		_applied = true

	var horizontal := Vector2(_player.velocity.x, _player.velocity.z)
	var speed: float = horizontal.length() if _player.is_on_floor() else 0.0
	var wanted_gait: float = clampf(speed / maxf(_player.walk_speed, 0.01), 0.0, 1.6)
	_gait = lerpf(_gait, wanted_gait, 1.0 - exp(-GAIT_RESPONSE * delta))
	_phase = fmod(_phase + speed / STRIDE * TAU * delta, TAU)

	var yaw: float = _player.rotation.y
	var turned: float = angle_difference(_last_yaw, yaw)
	# A jump this large in one frame is a teleport (spawn, load), not a turn.
	var rate: float = 0.0 if absf(turned) > TELEPORT_TURN else turned / delta
	_last_yaw = yaw
	_yaw_rate = lerpf(_yaw_rate, rate, 1.0 - exp(-TURN_RESPONSE * delta))

	# Gait pose follows the steps directly; its strength (_gait) eases in and
	# out, which is what makes a stop settle softly.
	var amp: float = _gait * _strength
	var gait_position := Vector3(
		SWAY_SIDE * amp * sin(_phase),
		-BOB_HEIGHT * amp * (0.5 - 0.5 * cos(2.0 * _phase)),
		0.0
	)
	var gait_rotation := Vector3(
		deg_to_rad(STEP_PITCH_DEGREES) * amp * sin(2.0 * _phase),
		0.0,
		-deg_to_rad(SWAY_ROLL_DEGREES) * amp * sin(_phase)
	)

	# Turn lean and lag ride a spring, so they lag the mouse and settle.
	var lean_limit: float = deg_to_rad(TURN_LEAN_MAX_DEGREES)
	var lag_limit: float = deg_to_rad(TURN_LAG_MAX_DEGREES)
	var turn_target := Vector3(
		0.0,
		clampf(-_yaw_rate * deg_to_rad(TURN_LAG), -lag_limit, lag_limit) * _strength,
		clampf(_yaw_rate * deg_to_rad(TURN_LEAN), -lean_limit, lean_limit) * _strength
	)
	# Sub-stepped so a slow frame cannot make the spring unstable.
	var steps: int = maxi(1, ceili(delta / (1.0 / 120.0)))
	var h: float = delta / steps
	var damping: float = 2.0 * DAMPING_RATIO * sqrt(STIFFNESS)
	for _i: int in steps:
		_rotation_speed += ((turn_target - _rotation) * STIFFNESS - _rotation_speed * damping) * h
		_rotation += _rotation_speed * h

	var offset: Vector3 = gait_position.limit_length(MAX_OFFSET)
	var turn: Vector3 = gait_rotation + _rotation
	if offset.length() < REST_EPSILON and turn.length() < REST_EPSILON:
		# At rest: put the camera exactly on the head once, then leave it alone
		# so other code (peephole aiming, captures) may set it.
		if _moved:
			_camera.transform = Transform3D.IDENTITY
			_moved = false
		return
	_camera.transform = Transform3D(Basis.from_euler(turn), offset)
	_moved = true


## Puts the camera back on the head and forgets all motion.
func _rest() -> void:
	_applied = false
	_gait = 0.0
	_yaw_rate = 0.0
	_rotation = Vector3.ZERO
	_rotation_speed = Vector3.ZERO
	if _camera != null and _moved:
		_camera.transform = Transform3D.IDENTITY
	_moved = false
	if _player != null:
		_last_yaw = _player.rotation.y
