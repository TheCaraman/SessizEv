class_name Footsteps
extends AudioStreamPlayer
## FOLEY-001: Daniel's footsteps, timed by the distance actually walked.
##
## A foot lands every STEP_LENGTH metres of walking on the floor, at the same
## points of the gait as BodyCam's dip (the gait cycle is BodyCamMotion.STRIDE,
## two steps). Speed comes from the body's velocity after it slid along walls,
## so pushing into a wall makes no steps, and walking faster makes them come
## sooner (and a little louder).
##
## No steps while the player has no control (dialogue, room view, shelter,
## journal, menus), while the game is paused, during a door transition (the
## camera moves, the body does not), in the air, or below MIN_SPEED.

## Emitted for every audible footstep, with the walking speed.
signal stepped(speed: float)

const STEP_LENGTH: float = BodyCamMotion.STRIDE * 0.5
## The first foot lands a quarter cycle in, where BodyCam's dip is deepest.
const FIRST_STEP: float = BodyCamMotion.STRIDE * 0.25
## Slower than this (m/s), a footfall makes no sound (shuffling to a stop).
const MIN_SPEED: float = 0.6
const WALK_VOLUME_DB: float = -21.0
const FAST_VOLUME_DB: float = -17.5
## Random pitch range of each step (AudioStreamRandomizer.random_pitch).
const PITCH_SPREAD: float = 1.04

var _player: PlayerController
var _door_transition: bool = false
## Metres walked on the floor while the player had control. Never reset, so
## the step timing stays in phase with BodyCam.
var _distance: float = 0.0
var _next_step: float = FIRST_STEP


func _ready() -> void:
	_player = get_parent() as PlayerController
	# One stream holding every take: a new step never cuts off the previous
	# one, and the same take is never heard twice in a row.
	var takes := AudioStreamRandomizer.new()
	takes.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
	takes.random_pitch = PITCH_SPREAD
	takes.random_volume_offset_db = 1.0
	for take: AudioStream in Foley.footstep_takes():
		takes.add_stream(-1, take)
	stream = takes
	max_polyphony = 2
	volume_db = WALK_VOLUME_DB
	EventBus.door_transition_changed.connect(_on_door_transition)


## Stop the voice before the node goes, so quitting mid-step releases the
## playback (the hardware audio run checks for leaked objects at exit).
func _exit_tree() -> void:
	stop()


## Whether walking right now can make steps.
func is_listening() -> bool:
	return _player.control_enabled and not _door_transition and not get_tree().paused


## Metres walked so far (only counted while listening).
func walked() -> float:
	return _distance


func _on_door_transition(active: bool) -> void:
	_door_transition = active


func _process(delta: float) -> void:
	if delta <= 0.0 or not is_listening() or not _player.is_on_floor():
		return
	var speed: float = Vector2(_player.velocity.x, _player.velocity.z).length()
	_distance += speed * delta
	# Several steps in one long frame play once; the rest are skipped.
	if _distance < _next_step:
		return
	while _next_step <= _distance:
		_next_step += STEP_LENGTH
	if speed >= MIN_SPEED:
		_play_step(speed)


func _play_step(speed: float) -> void:
	var fast: float = clampf(inverse_lerp(_player.walk_speed, _player.fast_speed, speed), 0.0, 1.0)
	volume_db = lerpf(WALK_VOLUME_DB, FAST_VOLUME_DB, fast)
	play()
	stepped.emit(speed)
