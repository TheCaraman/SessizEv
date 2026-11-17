extends CanvasLayer
var _material: ShaderMaterial

func _ready() -> void:
	_material = ($Screen.material as ShaderMaterial).duplicate()
	$Screen.material = _material
	Settings.preferences_changed.connect(_apply)
	_apply()

func _apply() -> void:
	_material.set_shader_parameter("brightness", Settings.get_number("brightness"))
	_material.set_shader_parameter("vignette_strength", Settings.get_number("vignette"))
