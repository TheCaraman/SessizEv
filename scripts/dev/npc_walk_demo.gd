extends Node
## NPC-ACTOR-3D-001 demo: the real house with Elena (study model) walking
## from room to room on the real routes. Walk around yourself (WASD, mouse);
## Esc pauses. Dev only: it starts a throwaway campaign and the actor is not
## part of the game.
##
## Controls: N sends Elena to the next room now. The HUD line says where she
## is going.

const HOUSE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const MODEL_PATH: String = "res://assets/models/elena_v7/elena_v7.glb"
## Rooms she visits, in order, then it starts over.
const TOUR: Array[StringName] = [&"living_room", &"hall", &"kitchen", &"utility", &"kitchen", &"hall", &"corridor", &"guest_a", &"corridor", &"bathroom_upper", &"storage", &"bathroom_upper", &"corridor", &"multipurpose", &"corridor", &"hall", &"vestibule", &"daniel_bedroom", &"vestibule", &"living_room"]
## Seconds she stands still in each room.
const PAUSE_SECONDS: float = 3.0

var actor: NpcActor3D
var _house: Node
var _stop: int = 0
var _label: Label
var _wait: float = 0.0


func _ready() -> void:
	# Starts a campaign, so it runs only in an isolated copy: a test copy or the
	# playtest copy DENE_NPC_YURUYUS.cmd makes (own custom_user_dir_name).
	var user_dir: String = str(ProjectSettings.get_setting("application/config/custom_user_dir_name", ""))
	if not (ReviewSpots.is_isolated() or user_dir.begins_with("TheQuietHours-Playtests/")):
		push_error("npc_walk_demo runs only through DENE_NPC_YURUYUS.cmd (isolated copy); refusing to touch real saves.")
		get_tree().quit(1)
		return
	GameState.new_campaign(31)
	_house = HOUSE.instantiate()
	add_child(_house)
	actor = NpcActor3D.new()
	_house.add_child(actor)
	if not actor.load_model(MODEL_PATH):
		push_error("The Elena study model is missing: " + MODEL_PATH)
		return
	actor.place(HouseLayout.room_center(TOUR[0]), 0.0)
	actor.arrived.connect(_on_arrived)
	var layer := CanvasLayer.new()
	layer.layer = 60
	add_child(layer)
	_label = Label.new()
	_label.position = Vector2(24, 20)
	_label.add_theme_color_override(&"font_color", Color(1, 1, 1, 0.85))
	_label.add_theme_color_override(&"font_shadow_color", Color(0, 0, 0, 0.9))
	layer.add_child(_label)
	_wait = 1.0
	_update_label()


func _process(delta: float) -> void:
	if actor == null or actor.is_walking():
		return
	if Input.is_physical_key_pressed(KEY_N):
		_wait = 0.0
	_wait -= delta
	if _wait <= 0.0:
		_go_next()


func _go_next() -> void:
	var from: StringName = TOUR[_stop % TOUR.size()]
	_stop += 1
	var to: StringName = TOUR[_stop % TOUR.size()]
	var route: Array[Vector3] = NpcRoutes.route(from, to)
	actor.walk_route(route)
	_update_label()


func _on_arrived() -> void:
	_wait = PAUSE_SECONDS
	_update_label()


func _update_label() -> void:
	var here: StringName = TOUR[_stop % TOUR.size()]
	if actor.is_walking():
		_label.text = "Elena (3D study model) walking to: %s   |   N: next room" % here
	else:
		_label.text = "Elena (3D study model) waiting in: %s   |   N: next room" % here