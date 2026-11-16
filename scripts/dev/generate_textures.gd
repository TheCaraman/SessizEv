extends Node
## Developer tool: writes the generated corridor textures to assets/textures/.
## Re-import the project afterwards so the engine picks up the new files.
##
## Run with:
##   godot --headless --path . res://scenes/main/generate_textures.tscn


func _ready() -> void:
	TextureGenerator.generate_all("res://assets/textures")
	get_tree().quit(0)
