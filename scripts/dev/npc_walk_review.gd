extends Node
## NPC-ACTOR-3D-001 review: renders the walking actor inside the real house
## from a few fixed cameras and saves PNGs (native, windowed run only; the
## headless renderer draws nothing). Output folder: the NPC_REVIEW_OUT
## environment variable, else user://npc-walk-review.
##
## Run through a kept isolated project copy of tools/Run-Tests.ps1, never in
## the live project folder.

const HOUSE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const MODEL_PATH: String = "res://assets/models/elena_v7/elena_v7.glb"
## [seconds into the walk, camera position, look-at point, file name]
const SHOTS: Array = [
	[2.2, Vector3(8.6, 1.35, 9.0), Vector3(7.0, 1.0, 8.6), "side"],
	[4.0, Vector3(7.0, 1.5, 3.8), Vector3(7.0, 1.0, 7.0), "front"],
	[5.6, Vector3(5.6, 1.4, 5.0), Vector3(7.0, 1.0, 6.4), "corner"],
]

var _out: String
var _house: Node
var _actor: NpcActor3D
var _camera: Camera3D
var _time: float = 0.0
var _next_shot: int = 0
var _busy: bool = false


func _ready() -> void:
	if not ReviewSpots.isolated(get_tree()):
		return
	_out = OS.get_environment("NPC_REVIEW_OUT")
	if _out == "":
		_out = ProjectSettings.globalize_path("user://npc-walk-review")
	DirAccess.make_dir_recursive_absolute(_out)
	GameState.new_campaign(31)
	_house = HOUSE.instantiate()
	add_child(_house)
	_actor = NpcActor3D.new()
	_house.add_child(_actor)
	if not _actor.load_model(MODEL_PATH):
		push_error("model missing")
		get_tree().quit(1)
		return
	_camera = Camera3D.new()
	_camera.fov = 60.0
	_house.add_child(_camera)
	_camera.current = true
	var route: Array[Vector3] = NpcRoutes.route(&"vestibule", &"landing")
	_actor.place(route[0], PI)
	_actor.walk_route(route)


func _process(delta: float) -> void:
	_time += delta
	if _busy:
		return
	if _next_shot >= SHOTS.size():
		get_tree().quit(0)
		return
	var shot: Array = SHOTS[_next_shot]
	if _time < float(shot[0]):
		return
	_camera.global_position = shot[1]
	_camera.look_at(shot[2])
	# The picture is taken on the frame after the camera moved.
	_busy = true
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("%s/%s.png" % [_out, shot[3]])
	print("NPC WALK REVIEW: saved %s at %.1f s, actor at %s facing %.2f" % [shot[3], _time, str(_actor.position), _actor.rotation.y])
	_next_shot += 1
	_busy = false
