extends Node3D
## Developer session scene: the house corridors, the player, the HUD and the
## 2D room view wired together. A proper game scene replaces this once the
## campaign systems exist.
##
## Until a pause menu exists, the pause key releases or recaptures the mouse.

@onready var _player: PlayerController = $Player

var _current_room: StringName = &""


func _ready() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.01, 0.02, 0.02)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	# Cold teal fill light everywhere; warm lamps only make small pools in it.
	environment.ambient_light_color = Color(0.20, 0.48, 0.58)
	environment.ambient_light_energy = 0.45
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	# Thick teal haze that light visibly travels through.
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.07
	environment.volumetric_fog_albedo = Color(0.40, 0.75, 0.88)
	environment.volumetric_fog_emission = Color(0.04, 0.22, 0.28)
	environment.volumetric_fog_emission_energy = 0.35
	environment.volumetric_fog_anisotropy = 0.55
	environment.volumetric_fog_length = 24.0
	environment.volumetric_fog_ambient_inject = 0.4

	# Soft bloom around lit surfaces and soft contact shadows in corners.
	environment.glow_enabled = true
	environment.glow_intensity = 0.7
	environment.glow_bloom = 0.12
	environment.glow_hdr_threshold = 0.9
	environment.ssao_enabled = true
	environment.ssao_radius = 0.8
	environment.ssao_intensity = 2.5

	environment.adjustment_enabled = true
	environment.adjustment_saturation = 1.2
	environment.adjustment_contrast = 1.1
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)

	# While a room is shown in 2D the player cannot move and the cursor is free.
	EventBus.room_view_opened.connect(func(_id: StringName) -> void: _player.control_enabled = false)
	EventBus.room_view_closed.connect(func(_id: StringName) -> void: _player.control_enabled = true)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		_player.control_enabled = not _player.control_enabled


func _physics_process(_delta: float) -> void:
	var room: StringName = HouseLayout.room_at(_player.global_position)
	if room != _current_room:
		_current_room = room
		print("Room: ", room if room != &"" else &"(outside)")
