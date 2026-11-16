extends Node3D
## The play session: the house, the player, the campaign director and the
## interface layers, wired together. (The file keeps its early name.)
##
## Normally entered from the main menu, which starts or loads the campaign
## first. Run directly, it starts a new campaign itself.

@onready var _player: PlayerController = $Player
@onready var _pause_menu: PauseMenu = $PauseMenu
@onready var _dialogue: DialogueRunner = $DialogueRunner
@onready var _director: CampaignDirector = $CampaignDirector
@onready var _room_view: RoomView = $RoomView
@onready var _dialogue_view: DialogueView = $DialogueView

@onready var _shelter: ShelterManager = $ShelterManager
@onready var _shelter_view: ShelterView = $ShelterView

var _journal: JournalView
var _door_transition: bool = false

var _current_room: StringName = &""
var _electric_lights: Array[Node3D] = []
var _electric_materials: Array[StandardMaterial3D] = []
var _window_lights: Array[Dictionary] = []
var _window_materials: Array[Dictionary] = []


func _ready() -> void:
	_build_environment()
	_journal = JournalView.new()
	add_child(_journal)
	_journal.closed.connect(_update_control)
	EventBus.door_transition_changed.connect(func(active: bool) -> void:
		_door_transition = active
		_update_control()
	)
	EventBus.review_requested.connect(func(content: String) -> void:
		_room_view.close()
		_journal.open(content)
		_update_control()
	)

	_director.shelter = _shelter
	_shelter_view.setup(_shelter)
	EventBus.shelter_view_requested.connect(_shelter_view.open)
	EventBus.shelter_view_opened.connect(_update_control)
	EventBus.shelter_view_closed.connect(_update_control)
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
	_pause_menu.closed.connect(_update_control)
	var emergency := OmniLight3D.new()
	emergency.name = "EmergencyNavigation"
	emergency.light_energy = 0.22
	emergency.omni_range = 9.0
	emergency.light_color = Color(0.75, 0.82, 0.83)
	_player.add_child(emergency)
	_cache_electric_lighting()
	_director.power.power_changed.connect(_update_electric_lighting)
	EventBus.time_changed.connect(func(_day: int, _minutes: int) -> void: _update_electric_lighting(_director.power.is_powered()))
	EventBus.day_started.connect(func(_day: int) -> void: _update_electric_lighting(_director.power.is_powered()))
	_update_electric_lighting(_director.power.is_powered())
	_update_control()


func _unhandled_input(event: InputEvent) -> void:
	if _door_transition:
		get_viewport().set_input_as_handled()
		return
	# Rooms and conversations take the pause key first; this only runs while
	# the player is walking the corridors.
	if event.is_action_pressed("journal") and not (_room_view.is_open() or _dialogue.is_active() or _shelter_view.is_open() or _pause_menu.is_open()):
		_journal.open()
		_update_control()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"pause"):
		_pause_menu.open()
		get_viewport().set_input_as_handled()


func _physics_process(_delta: float) -> void:
	_current_room = HouseLayout.room_at(_player.global_position)


func _cache_electric_lighting() -> void:
	# Cache this session only; another preview/session must keep its own materials.
	for light: Node in get_tree().get_nodes_in_group("window_lights"):
		if is_ancestor_of(light) and light is Light3D:
			_window_lights.append({"node": light, "energy": light.light_energy})
	for backdrop: Node in get_tree().get_nodes_in_group("window_backdrops"):
		if not is_ancestor_of(backdrop) or not backdrop is MeshInstance3D:
			continue
		var source: Material = backdrop.get_active_material(0)
		if source is StandardMaterial3D:
			var local_material: StandardMaterial3D = source.duplicate()
			backdrop.material_override = local_material
			_window_materials.append({"material": local_material, "color": local_material.albedo_color, "emission": local_material.emission})
	for light: Node in get_tree().get_nodes_in_group("electric_lights"):
		if is_ancestor_of(light) and light is Node3D:
			_electric_lights.append(light)
	for fitting: Node in get_tree().get_nodes_in_group("electric_fittings"):
		if not is_ancestor_of(fitting) or not fitting is MeshInstance3D:
			continue
		var source: Material = fitting.get_active_material(0)
		if source is StandardMaterial3D:
			var local_material: StandardMaterial3D = source.duplicate()
			fitting.material_override = local_material
			_electric_materials.append(local_material)


func _update_electric_lighting(powered: bool) -> void:
	var daylight: float = daylight_factor(GameState.minutes)
	for entry: Dictionary in _window_lights:
		entry["node"].light_energy = float(entry["energy"]) * daylight
	for entry: Dictionary in _window_materials:
		var material: StandardMaterial3D = entry["material"]
		material.albedo_color = entry["color"] * daylight
		material.emission = entry["emission"] * daylight
	for light: Node3D in _electric_lights:
		light.visible = powered
	for material: StandardMaterial3D in _electric_materials:
		material.emission_enabled = powered


## Weak exterior light remains at night, independent of household power.
## Always multiply cached originals; repeated clock events cannot darken them again.
static func daylight_factor(minutes: int) -> float:
	minutes = posmod(minutes, 1440)
	if minutes < 420:
		return 0.08
	if minutes < 480:
		return lerpf(0.08, 1.0, float(minutes - 420) / 60.0)
	if minutes < 1080:
		return 1.0
	if minutes < 1320:
		return lerpf(1.0, 0.08, float(minutes - 1080) / 240.0)
	return 0.08


func get_current_room() -> StringName:
	return _current_room


func _update_control() -> void:
	# Ask the runner, not the view: the view hides a moment after the runner
	# finishes.
	var busy: bool = _door_transition or _journal.visible or _room_view.is_open() or _dialogue.is_active() or _shelter_view.is_open()
	# Assigning also re-applies the mouse mode, which the pause menu changes.
	_player.control_enabled = not busy


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color(0.01, 0.02, 0.02)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	# Dim, nearly neutral fill light; lamps and daylight supply the colour.
	environment.ambient_light_color = Color(0.35, 0.47, 0.40)
	environment.ambient_light_energy = 0.22
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	# Pale dusty haze that light visibly travels through.
	environment.volumetric_fog_enabled = true
	environment.volumetric_fog_density = 0.006
	environment.volumetric_fog_albedo = Color(0.74, 0.80, 0.82)
	environment.volumetric_fog_emission = Color(0.05, 0.08, 0.09)
	environment.volumetric_fog_emission_energy = 0.15
	environment.volumetric_fog_anisotropy = 0.55
	environment.volumetric_fog_length = 24.0
	environment.volumetric_fog_ambient_inject = 0.4

	# Soft bloom around lit surfaces and soft contact shadows in corners.
	environment.glow_enabled = true
	environment.glow_intensity = 0.22
	environment.glow_bloom = 0.12
	environment.glow_hdr_threshold = 1.1
	environment.ssao_enabled = true
	environment.ssao_radius = 0.8
	environment.ssao_intensity = 1.5

	environment.adjustment_enabled = true
	environment.adjustment_saturation = 0.86
	environment.adjustment_contrast = 1.1

	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)
