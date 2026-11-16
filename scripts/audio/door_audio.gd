class_name DoorAudio
extends AudioStreamPlayer3D
## Original synthesized placeholder, not final foley. One cue per real arrival.
signal arrival_cue(npc_id: String)
var _last_visitor: String = ""

func _ready() -> void:
	stream = make_knock()
	volume_db = -8.0
	unit_size = 5.0
	max_distance = 24.0
	_last_visitor = GameState.visitor
	for wall: Dictionary in HouseLayout.WALLS:
		for opening: Dictionary in wall.get("openings", []):
			if opening.get("front", false):
				position = Vector3(float(opening["pos"]), 1.3, float(wall["at"]) - 0.1)
	EventBus.visitor_changed.connect(_on_visitor)
	# Loading a waiting visitor is not a fresh knock.
	EventBus.day_started.connect(func(_day: int) -> void:
		_last_visitor = GameState.visitor
		stop())

func _on_visitor(id: String) -> void:
	if id == _last_visitor:
		return
	_last_visitor = id
	if id == "":
		stop()
		return
	play()
	arrival_cue.emit(id)

static func make_knock() -> AudioStreamWAV:
	const RATE: int = 22050
	const LENGTH: float = 0.85
	var samples := PackedByteArray()
	samples.resize(int(RATE * LENGTH) * 2)
	var noise := RandomNumberGenerator.new()
	noise.seed = 71031
	var filtered: float = 0.0
	for i: int in samples.size() / 2:
		var time: float = float(i) / RATE
		filtered = filtered * 0.72 + noise.randf_range(-1.0, 1.0) * 0.28
		var value: float = 0.0
		for onset: float in [0.03, 0.27, 0.52]:
			var age: float = time - onset
			if age >= 0.0 and age < 0.25:
				var attack: float = minf(age / 0.002, 1.0)
				value += attack * (sin(TAU * 155.0 * age) * exp(-age * 30.0) * 0.30 + filtered * exp(-age * 65.0) * 0.65)
		samples.encode_s16(i * 2, int(clampf(value, -0.9, 0.9) * 32767))
	var result := AudioStreamWAV.new()
	result.format = AudioStreamWAV.FORMAT_16_BITS
	result.mix_rate = RATE
	result.stereo = false
	result.data = samples
	return result
