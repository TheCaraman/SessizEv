extends Node3D
## The play session: the house, the player, the campaign director and the
## interface layers, wired together. (The file keeps its early name; a main
## menu and proper scene flow come later.)
##
## Until a pause menu exists, the pause key releases or recaptures the mouse.

@onready var _player: PlayerController = $Player
@onready var _dialogue: DialogueRunner = $DialogueRunner
@onready var _director: CampaignDirector = $CampaignDirector
@onready var _room_view: RoomView = $RoomView
@onready var _dialogue_view: DialogueView = $DialogueView

var _current_room: StringName = &""
var _mouse_released: bool = false


func _ready() -> void:
	_build_environment()

	_director.setup(_dialogue)
	_room_view.setup(_director)
	_dialogue_view.setup(_dialogue)

	# Tests start their own campaign with a fixed seed before loading this scene.
	if not GameState.active:
		GameState.new_campaign()

	# While a room or a conversation is on screen the player cannot move and
	# the cursor is free.
	EventBus.room_view_opened.connect(func(_id: StringName) -> void: _update_control())
	EventBus.room_view_closed.connect(func(_id: StringName) -> void: _update_control())
	EventBus.dialogue_started.connect(func(_id: String) -> void: _update_control())
	EventBus.dialogue_ended.connect(func(_id: String) -> void: _update_control())


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		_mouse_released = not _mouse_released
		_update_control()


func _physics_process(_delta: float) -> void:
	_current_room = HouseLayout.room_at(_player.global_position)


func get_current_room() -> StringName:
	return _current_room


func _update_control() -> void:
	# Ask the runner, not the view: the view hides a moment after the runner
	# finishes.
	var busy: bool = _room_view.is_open() or _dialogue.is_active()
	if busy:
		_mouse_released = false
	_player.control_enabled = not busy and not _mouse_released


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.01, 0.02, 0.02)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	# Dim, nearly neutral fill light; lamps and daylight supply the colour.
	environment.ambient_light_color = Color(0.44, 0.48, 0.50)
	environment.ambient_light_energy = 0.30
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	# Pale dusty haze that light visibly travels through.
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.03
	environment.volumetric_fog_albedo = Color(0.74, 0.80, 0.82)
	environment.volumetric_fog_emission = Color(0.05, 0.08, 0.09)
	environment.volumetric_fog_emission_energy = 0.15
	environment.volumetric_fog_anisotropy = 0.55
	environment.volumetric_fog_length = 24.0
	environment.volumetric_fog_ambient_inject = 0.4

	# Soft bloom around lit surfaces and soft contact shadows in corners.
	environment.glow_enabled = true
	environment.glow_intensity = 0.45
	environment.glow_bloom = 0.12
	environment.glow_hdr_threshold = 1.1
	environment.ssao_enabled = true
	environment.ssao_radius = 0.8
	environment.ssao_intensity = 2.5

	environment.adjustment_enabled = true
	environment.adjustment_saturation = 1.05
	environment.adjustment_contrast = 1.1

	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
