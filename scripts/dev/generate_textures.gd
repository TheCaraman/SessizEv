extends Node
## Developer tool: writes the generated corridor textures to assets/textures/.
## Re-import the project afterwards so the engine picks up the new files.
##
## Run with:
##   godot --headless --path . res://scenes/main/generate_textures.tscn


func _ready() -> void:
	if "--wall-only" in OS.get_cmdline_user_args():
		var error: Error = TextureGenerator._wallpaper().save_png("res://assets/textures/wallpaper.png")
		get_tree().quit(0 if error == OK else 1)
		return
	if "--corridor-surfaces" in OS.get_cmdline_user_args():
		var error: Error = TextureGenerator._wallpaper().save_png("res://assets/textures/wallpaper.png")
		var floor_error: Error = TextureGenerator.corridor_floorboards().save_png("res://assets/textures/parquet.png")
		get_tree().quit(0 if error == OK and floor_error == OK else 1)
		return
	TextureGenerator.generate_all("res://assets/textures")
	get_tree().quit(0)
