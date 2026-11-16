extends Node
## Persistent user preferences, independent from campaign saves.
const PATH: String = "user://settings.cfg"
const LANGUAGES: Array[String] = ["en", "tr"]
var language: String = "en"

func _ready() -> void:
	load_preferences()

func load_preferences() -> void:
	var config := ConfigFile.new()
	var loaded: Error = config.load(PATH)
	var candidate: Variant = config.get_value("interface", "language", "en") if loaded == OK else "en"
	language = candidate if candidate is String and candidate in LANGUAGES else "en"
	TranslationServer.set_locale(language)

func set_language(value: String) -> Error:
	if value not in LANGUAGES:
		return ERR_INVALID_PARAMETER
	var config := ConfigFile.new()
	config.set_value("interface", "language", value)
	var error: Error = config.save(PATH)
	if error == OK:
		language = value
		TranslationServer.set_locale(language)
	return error
