extends Node
## Persistent user preferences, independent from campaign saves.
const PATH: String = "user://settings.cfg"
const LANGUAGES: Array[String] = ["en", "tr"]
signal preferences_changed
const DEFAULTS: Dictionary = {"brightness": 1.0, "mouse_sensitivity": 0.0022, "fov": 78.0, "master_volume": 1.0, "camera_motion": 1.0}
const LIMITS: Dictionary = {"brightness": Vector2(0.7, 1.6), "mouse_sensitivity": Vector2(0.00055, 0.0066), "fov": Vector2(60.0, 95.0), "master_volume": Vector2(0.0, 1.0), "camera_motion": Vector2(0.0, 1.0)}
var language: String = "en"
var _values: Dictionary = DEFAULTS.duplicate()

func _ready() -> void:
	load_preferences()

func load_preferences() -> void:
	var config := ConfigFile.new()
	var loaded: Error = config.load(PATH)
	var candidate: Variant = config.get_value("interface", "language", "en") if loaded == OK else "en"
	language = candidate if candidate is String and candidate in LANGUAGES else "en"
	_values = DEFAULTS.duplicate()
	for key: String in DEFAULTS:
		var value: Variant = config.get_value("preferences", key, DEFAULTS[key]) if loaded == OK else DEFAULTS[key]
		if _valid_number(key, value):
			_values[key] = float(value)
	_apply_audio()
	TranslationServer.set_locale(language)
	preferences_changed.emit()

func set_language(value: String) -> Error:
	if value not in LANGUAGES:
		return ERR_INVALID_PARAMETER
	return _commit(_values, value)

func get_number(key: String) -> float:
	return float(_values.get(key, 0.0))

func set_number(key: String, value: Variant) -> Error:
	if not _valid_number(key, value):
		return ERR_INVALID_PARAMETER
	var candidate: Dictionary = _values.duplicate()
	candidate[key] = float(value)
	return _commit(candidate, language)

func restore_defaults() -> Error:
	return _commit(DEFAULTS.duplicate(), language)

## Brightness touches world RGB, never world opacity or UI text.
func world_tint(base: Color = Color.WHITE) -> Color:
	var value: float = get_number("brightness")
	return Color(base.r * value, base.g * value, base.b * value, base.a)

func _valid_number(key: String, value: Variant) -> bool:
	if not LIMITS.has(key) or not (value is int or value is float):
		return false
	var limits: Vector2 = LIMITS[key]
	return is_finite(float(value)) and float(value) >= limits.x and float(value) <= limits.y

func _commit(values: Dictionary, locale: String) -> Error:
	var config := ConfigFile.new()
	config.load(PATH)
	config.set_value("interface", "language", locale)
	for key: String in DEFAULTS:
		config.set_value("preferences", key, values[key])
	var error: Error = config.save(PATH)
	if error == OK:
		_values = values.duplicate()
		language = locale
		_apply_audio()
		TranslationServer.set_locale(language)
		preferences_changed.emit()
	return error

func _apply_audio() -> void:
	var master: int = AudioServer.get_bus_index(&"Master")
	if master < 0:
		return
	var volume: float = get_number("master_volume")
	AudioServer.set_bus_volume_linear(master, volume)
	AudioServer.set_bus_mute(master, volume == 0.0)
