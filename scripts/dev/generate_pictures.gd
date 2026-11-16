extends Node
## Developer tool: writes the corridor picture textures (painting_landscape,
## painting_still_life, photo_house) to assets/textures/. Re-import afterwards.
##
## Run with:
##   godot --headless --path . res://scenes/dev/generate_pictures.tscn


func _ready() -> void:
	TextureGenerator.generate_pictures("res://assets/textures")
	get_tree().quit(0)
