extends Node
func _ready() -> void:
	var menu: MainMenu = load("res://scenes/main/main_menu.tscn").instantiate()
	add_child(menu)
	for locale: String in ["en", "tr"]:
		Settings.set_language(locale)
		for frame: int in 6:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://docs/qa/language-menu-%s.png" % locale)
		print("LANGUAGE MENU CAPTURE: " + locale)
	get_tree().quit()
