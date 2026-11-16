extends Node3D
## Developer scene: the house blockout with the player inside.
##
## Until a pause menu exists, the pause key releases or recaptures the mouse.
## The current room id is printed whenever the player changes room, which is
## the first use of HouseLayout.room_at().

@onready var _player: PlayerController = $Player

var _current_room: StringName = &""


func _ready() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.03, 0.035, 0.04)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.46, 0.40, 0.28)
	environment.ambient_light_energy = 0.10
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	# Thin murky haze so distant corners sink into brown rather than black.
	environment.fog_enabled = true
	environment.fog_light_color = Color(0.16, 0.13, 0.08)
	environment.fog_density = 0.045
	environment.adjustment_enabled = true
	environment.adjustment_saturation = 0.85
	environment.adjustment_contrast = 1.08
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		_player.control_enabled = not _player.control_enabled


func _physics_process(_delta: float) -> void:
	var room: StringName = HouseLayout.room_at(_player.global_position)
	if room != _current_room:
		_current_room = room
		print("Room: ", room if room != &"" else &"(outside)")
