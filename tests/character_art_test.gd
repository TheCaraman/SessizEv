extends Node
var checks: int = 0
var failures: int = 0

func check(ok: bool, text: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + text)

func _ready() -> void:
	var room_path: String = CharacterArt.texture_path("elena_ward")
	var arrival_path: String = CharacterArt.texture_path("elena_ward", &"arrival")
	check(room_path != arrival_path, "room and first arrival have different poses")
	for path: String in [room_path, arrival_path]:
		var texture := load(path) as Texture2D
		check(texture != null and texture.get_size() == Vector2(1024, 1536), "real full-body sprite " + path)
		var image: Image = texture.get_image()
		check(image.get_pixel(0, 0).a == 0.0, "transparent corner " + path)
		check(image.get_pixel(510, 750).a > 0.9, "solid figure " + path)
	check(CharacterArt.texture_path("marcus_hale", &"arrival").ends_with("marcus_hale/default.png"), "unconverted characters retain existing art")
	check(CharacterArt.texture_path("elena_ward", &"not_authored") == room_path, "unknown context falls back to authored room pose")
	GameState.new_campaign(42)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	var runner: DialogueRunner = scene.get_node("DialogueRunner")
	var dialogue: DialogueView = scene.get_node("DialogueView")
	for infected: bool in [false, true]:
		GameState.npcs["elena_ward"]["infected"] = infected
		var before: Dictionary = GameState.to_dict().duplicate(true)
		check(runner.start("elena_arrival"), "arrival dialogue starts")
		runner.choose(0)
		check((dialogue._figure.texture as AtlasTexture).atlas.resource_path == arrival_path, "guarded figure in arrival dialogue regardless of infection")
		check(dialogue._text.text == tr("D1_ELENA_HELLO"), "same guarded authored greeting regardless of infection")
		check(GameState.to_dict() == before, "figure and greeting do not mutate campaign")
		runner.cancel()
		var picture: Control = RoomWorld.make_figure("elena_ward")
		check(picture.get("texture").resource_path == room_path, "ordinary room uses calmer pose regardless of infection")
		picture.free()
	var front: RoomDoor
	for body: Node in scene.find_children("*", "StaticBody3D", true, false):
		if body is RoomDoor and body.is_front:
			front = body
	GameState.visitor = "elena_ward"
	player.control_enabled = true
	var target: PeepholeInteraction = front.get_node("Peephole")
	target.interact(player)
	check(target.view.visitor_slot.get_child(0).get("texture").resource_path == arrival_path, "optical view uses same guarded arrival pose")
	target.view.close()
	for locale: String in ["en", "tr"]:
		TranslationServer.set_locale(locale)
		for key: String in ["D1_ELENA_DOORSTEP", "D1_ELENA_HELLO", "D1_ELENA_WHO", "D1_ELENA_WHERE", "D1_ELENA_ALONE", "D1_ELENA_PROOF"]:
			check(tr(key) != key and not tr(key).is_empty(), "localized guarded dialogue " + locale + " " + key)
	scene.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	if failures == 0:
		print("CHARACTER ART TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
