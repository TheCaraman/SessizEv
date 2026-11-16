class_name HouseNightEvents
extends Node
## One authored, non-human noise. Never selects a perpetrator or changes infection.
signal observation_emitted(event_id: String)
var definition: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/events/house_night.json"))
var _last_minute: int = 0
var _pending_key: String = ""
var _sound: AudioStreamPlayer3D

func _ready() -> void:
	_sound = AudioStreamPlayer3D.new()
	_sound.name = "PipeRattle"
	_sound.stream = make_rattle()
	_sound.volume_db = -18.0
	_sound.unit_size = 5.0
	_sound.max_distance = 24.0
	var room: Dictionary = HouseLayout.get_room(StringName(definition["source_room"]))
	var rect: Rect2 = room["rects"][0]
	_sound.position = Vector3(rect.get_center().x, float(room["floor"]) * HouseLayout.STOREY_HEIGHT + 1.2, rect.get_center().y)
	add_child(_sound)
	_sync()
	EventBus.day_started.connect(func(_day: int) -> void: _sync())
	EventBus.time_changed.connect(_on_time)

func _sync() -> void:
	_last_minute = GameState.minutes
	_pending_key = ""
	if _sound != null:
		_sound.stop()

func _flag(suffix: String) -> String:
	return str(definition["id"]) + "_" + suffix

func _on_time(day: int, minute: int) -> void:
	var previous: int = _last_minute
	_last_minute = minute
	if day != int(definition["day"]) or not GameState.night_in_progress():
		return
	if GameState.night_session.get("state") != "awake" or GameState.get_flag(_flag("heard")):
		return
	if previous >= int(definition["after_minute"]) or minute < int(definition["after_minute"]):
		return
	GameState.set_flag(_flag("heard"))
	GameState.set_flag(_flag("minute"), minute)
	_pending_key = definition["heard_key"]
	EvidenceManager.collect(str(definition["id"]) + "_sound", _pending_key)
	_sound.play()
	EventBus.notice_requested.emit(tr(_pending_key))
	observation_emitted.emit(definition["id"])

func take_observation() -> String:
	var key: String = _pending_key
	_pending_key = ""
	return tr(key) if key != "" else ""

func can_inspect() -> bool:
	return GameState.get_flag(_flag("heard"), false)

func inspection_label() -> String:
	return tr("PIPE_ACTION_REVIEW" if GameState.get_flag(_flag("inspected")) else "PIPE_ACTION_INSPECT")

func inspect() -> String:
	if not can_inspect():
		return ""
	if not GameState.get_flag(_flag("inspected")):
		var cost: int = int(definition["inspection_minutes"])
		if GameState.minutes + cost > GameState.get_action_time_limit():
			return tr("POWER_TOO_LATE")
		GameState.set_flag(_flag("inspected"))
		GameState.advance_minutes(cost)
		EvidenceManager.collect(str(definition["id"]) + "_source", definition["inspection_key"])
		_sound.play()
		SaveManager.save_game()
	return tr(definition["inspection_key"])

static func make_rattle() -> AudioStreamWAV:
	const RATE: int = 22050
	var data := PackedByteArray()
	data.resize(int(RATE * 0.8) * 2)
	for sample: int in data.size() / 2:
		var time: float = float(sample) / RATE
		var value: float = 0.0
		for onset: float in [0.02, 0.16, 0.41]:
			var age: float = time - onset
			if age >= 0.0 and age < 0.3:
				value += minf(age / 0.001, 1.0) * (sin(TAU * 330.0 * age) * 0.24 + sin(TAU * 719.0 * age) * 0.08) * exp(-age * 25.0)
		data.encode_s16(sample * 2, int(clampf(value, -0.9, 0.9) * 32767))
	var sound := AudioStreamWAV.new()
	sound.format = AudioStreamWAV.FORMAT_16_BITS
	sound.mix_rate = RATE
	sound.data = data
	return sound
