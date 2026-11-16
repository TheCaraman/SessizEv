extends Node
func _ready() -> void:
	call_deferred("capture")
func capture() -> void:
	GameState.new_campaign(7)
	GameState.day = 2
	for pair: Array in [["elena_ward", "guest_a_1"], ["marcus_hale", "guest_b_1"], ["arthur_bell", "multipurpose_1"]]:
		GameState.admit(pair[0], pair[1])
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	TranslationServer.set_locale("tr")
	scene.get_node("ShelterView").open()
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/qa"))
	get_viewport().get_texture().get_image().save_png("res://docs/qa/DAY2-003-screen.png")
	get_tree().quit()
