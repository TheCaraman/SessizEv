extends Control
## Temporary boot scene used to verify the project opens and autoloads run.
## It is replaced by the main menu in a later phase. The text here is
## developer-facing and intentionally not localized.

@onready var _label: Label = $Label


func _ready() -> void:
	var version: Dictionary = Engine.get_version_info()
	var lines: PackedStringArray = [
		"THE QUIET HOURS",
		"Project version: %s" % ProjectSettings.get_setting("application/config/version"),
		"Engine: %s" % version.get("string", "unknown"),
		"",
		"Registered actions:",
	]
	for action: StringName in InputSetup.DEFAULT_BINDINGS:
		var key: Key = InputSetup.get_bound_key(action)
		lines.append("  %s -> %s" % [action, OS.get_keycode_string(key)])
	_label.text = "\n".join(lines)
	print(_label.text)
