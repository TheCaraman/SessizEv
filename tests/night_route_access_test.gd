extends Node
var checks: int = 0
var failures: int = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + message)
func _ready() -> void:
	GameState.new_campaign(42)
	var scene: Node3D = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	for frame: int in 5:
		await get_tree().physics_frame
	var access := NightRouteAccess.new(scene)
	var before: Dictionary = GameState.to_dict()
	var proof: Dictionary = access.measure("guest_a", "guest_b")
	check(not proof.is_empty(), "both guests have a physical route to the one bathroom")
	if not proof.is_empty():
		check(proof["route_access"] and proof["sightline"], "route and sightline proven")
		for key: String in ["observer_position_mm", "subject_position_mm"]:
			var point: Array = proof[key]
			check(point[1] == 1350, "observation stays on actual ground floor: " + key)
	check(access.measure("missing_room", "guest_b").is_empty(), "absent room cannot invent a route")
	var door: RoomDoor = scene.find_child("Door_bathroom_upper", true, false)
	door.locked = true
	check(access.measure("guest_a", "guest_b").is_empty(), "locked bathroom blocks route")
	door.locked = false
	check(GameState.to_dict() == before, "geometry queries never mutate campaign")
	scene.queue_free()
	await get_tree().process_frame
	if failures == 0:
		print("NIGHT ROUTE ACCESS TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
