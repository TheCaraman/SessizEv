class_name BodyCamSway
extends Node
## A light body-camera feel for the player's view (HOUSE-ATMOS-003): the
## camera breathes a little when standing, and rocks with the steps when
## walking, as if worn on the chest rather than held in a steady hand.
##
## It only offsets the Camera3D's own rotation and position. Looking and
## moving stay in PlayerController; the Head's aim is untouched, so turning
## the sway off restores the exact old view. Set [member enabled] to false to
## turn it off (camera-motion accessibility setting).

## Master switch; also respects any later accessibility setting.
@export var enabled: bool = true
## Overall strength, 0..1.
@export_range(0.0, 1.0) var strength: float = 1.0
## Idle breathing amplitude in degrees.
@export var idle_degrees: float = 0.35
## Extra rock per step in degrees while walking.
@export var step_degrees: float = 0.9
## Vertical bob per step in metres.
@export var step_bob: float = 0.018
## Steps per second at normal walking speed.
@export var step_rate: float = 1.9

var _camera: Camera3D
var _player: CharacterBody3D
var _noise := FastNoiseLite.new()
var _time: float = 0.0
var _phase: float = 0.0
var _walk: float = 0.0
var _rest_position: Vector3


func _ready() -> void:
	_camera = get_parent() as Camera3D
	_player = owner as CharacterBody3D
	_noise.seed = 4127
	_noise.frequency = 0.35
	if _camera != null:
		_rest_position = _camera.position


func _process(delta: float) -> void:
	if _camera == null:
		return
	if not enabled or strength <= 0.0:
		_camera.rotation = Vector3.ZERO
		_camera.position = _rest_position
		return
	_time += delta
	var speed: float = 0.0
	if _player != null:
		speed = Vector2(_player.velocity.x, _player.velocity.z).length()
	# Ease in and out of walking so starting and stopping do not snap.
	_walk = move_toward(_walk, clampf(speed / 2.4, 0.0, 1.4), delta * 3.0)
	_phase += delta * step_rate * TAU * maxf(_walk, 0.0)

	var idle: float = deg_to_rad(idle_degrees) * strength
	var step: float = deg_to_rad(step_degrees) * strength * _walk
	var pitch: float = _noise.get_noise_2d(_time, 0.0) * idle + absf(sin(_phase)) * step * 0.35
	var yaw: float = _noise.get_noise_2d(0.0, _time) * idle * 0.8 + sin(_phase * 0.5) * step * 0.25
	var roll: float = _noise.get_noise_2d(_time, 50.0) * idle * 1.2 + sin(_phase * 0.5) * step * 0.6
	_camera.rotation = Vector3(pitch, yaw, roll)
	_camera.position = _rest_position + Vector3(0.0, -absf(sin(_phase)) * step_bob * strength * _walk, 0.0)
