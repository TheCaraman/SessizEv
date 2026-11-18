class_name NpcActor3D
extends Node3D
## NPC-ACTOR-3D-001: a rigged 3D resident that walks the house.
##
## Loads any imported character scene that carries an AnimationPlayer with an
## idle and a walk clip (the Elena study model: Idle_8fps / Walk_8fps, an
## in-place loop that faces +Z). The actor moves itself along a route with an
## NpcWalker and sets the walk clip's playback speed from the pace actually
## walked, so feet do not skate: a walk at the clip's own speed plays it at
## 1x, a faster walk plays it faster and a slowed corner slower.
##
## It knows nothing about the campaign: callers give it routes (see
## NpcRoutes) and listen to [signal arrived]. Whether a resident is shown in
## the 3D house at all is a separate, later decision.

## Emitted when a route ends. The actor is idling again.
signal arrived
## Emitted when the clip changes: &"idle" or &"walk".
signal gait_changed(gait: StringName)

const IDLE_CLIP: StringName = &"Idle_8fps"
const WALK_CLIP: StringName = &"Walk_8fps"
const BLEND_SECONDS: float = 0.2
## Ground speed (m/s) the walk clip was authored for. Measured from the Elena
## V7 clip's foot travel (see tests/npc_actor_3d_test.gd): the foot slides back
## 0.28 m in 0.69 s, so the clip is a slow, short-stepped gait.
const CLIP_SPEED: float = 0.4
## How fast a resident walks through the house by default, m/s. The clip then
## plays at about 2.2x, which keeps the feet planted.
const WALK_PACE: float = 0.9
## Slowest and fastest playback so a tiny speed never freezes the clip.
const MIN_PLAYBACK: float = 0.25
const MAX_PLAYBACK: float = 2.5

var model: Node3D
var animation: AnimationPlayer
var walker: NpcWalker = NpcWalker.new()
var gait: StringName = &""

var _walking: bool = false


## Loads the character scene at [param scene_path] under this node. Returns
## false (and leaves the actor empty) when it is missing or has no usable
## animations.
func load_model(scene_path: String) -> bool:
	if not ResourceLoader.exists(scene_path):
		return false
	var scene: PackedScene = load(scene_path) as PackedScene
	if scene == null:
		return false
	var instance: Node3D = scene.instantiate() as Node3D
	if instance == null:
		return false
	var players: Array[Node] = instance.find_children("*", "AnimationPlayer", true, false)
	if players.is_empty():
		instance.free()
		return false
	var player: AnimationPlayer = players[0] as AnimationPlayer
	if not player.has_animation(IDLE_CLIP) or not player.has_animation(WALK_CLIP):
		instance.free()
		return false
	if model != null:
		model.queue_free()
	model = instance
	animation = player
	add_child(model)
	animation.get_animation(IDLE_CLIP).loop_mode = Animation.LOOP_LINEAR
	animation.get_animation(WALK_CLIP).loop_mode = Animation.LOOP_LINEAR
	animation.playback_default_blend_time = BLEND_SECONDS
	_set_gait(&"idle")
	return true


func is_walking() -> bool:
	return _walking


## Puts the actor on the floor at [param point], facing [param yaw].
func place(point: Vector3, yaw: float = 0.0) -> void:
	_stop_walking()
	walker.position = point
	walker.yaw = yaw
	_apply_pose()


## Walks the route at [param speed] m/s. The first point is where the actor
## stands now (the actor is moved there). An empty or one-point route just
## places it.
func walk_route(points: Array[Vector3], speed: float = WALK_PACE) -> void:
	if points.size() < 2:
		if points.size() == 1:
			place(points[0], walker.yaw)
		return
	walker.speed = speed
	walker.start(points)
	_walking = true
	_apply_pose()
	_set_gait(&"walk")


## Ends the walk where the actor stands.
func stop() -> void:
	_stop_walking()


func _stop_walking() -> void:
	walker.stop()
	_walking = false
	_set_gait(&"idle")


func _physics_process(delta: float) -> void:
	if not _walking:
		return
	var done: bool = walker.advance(delta)
	_apply_pose()
	if animation != null:
		animation.speed_scale = clampf(walker.current_speed / CLIP_SPEED, MIN_PLAYBACK, MAX_PLAYBACK) if walker.current_speed > 0.0 else 1.0
	if done:
		_walking = false
		_set_gait(&"idle")
		arrived.emit()


func _apply_pose() -> void:
	position = walker.position
	rotation.y = walker.yaw


func _set_gait(next: StringName) -> void:
	if next == gait:
		return
	gait = next
	if animation != null:
		animation.speed_scale = 1.0
		animation.play(WALK_CLIP if next == &"walk" else IDLE_CLIP)
	gait_changed.emit(next)
