extends Node
## Regression for retiring the two-storey layout: the single floor stays supported.
func _ready() -> void:
	GameState.new_campaign(42)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	for frame: int in 10:
		await get_tree().physics_frame
	var ok: bool = HouseLayout.STAIRS.size == Vector2.ZERO and HouseLayout.VOIDS.is_empty()
	ok = ok and not scene.has_node("House/Stairs") and absf(player.position.y) < 0.1
	ok = ok and HouseLayout.room_at(player.position) == &"vestibule"
	if ok:
		print("STAIRS TEST: PASS (5 checks; retired single-storey staircase)")
	else:
		push_error("FAIL: single-storey spawn or retired staircase")
	scene.queue_free()
	await get_tree().process_frame
	get_tree().quit(0 if ok else 1)