extends Node
## SINGLE-STOREY-AUDIT-001: developer capture helpers follow the current plan
## and refuse to run outside an isolated copy. Run only through Run-Tests.

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


## DEV-HELPER-GUARDS-001: any developer scene that runs the campaign session or
## can write saves or settings must refuse to run outside an isolated copy.
## house_blockout.gd is the game session itself, not a helper.
const RISKY: Array[String] = ["house_blockout.tscn", "SaveManager", "Settings.set_", "Settings.restore_defaults", "CampaignDirector", "commit_candidate"]
const NOT_HELPERS: Array[String] = ["house_blockout.gd"]


func _check_dev_scene_guards() -> void:
	var risky_count: int = 0
	for file: String in DirAccess.get_files_at("res://scripts/dev"):
		if not file.ends_with(".gd") or file in NOT_HELPERS:
			continue
		var source: String = FileAccess.get_file_as_string("res://scripts/dev/" + file)
		var risky: bool = false
		for token: String in RISKY:
			risky = risky or source.contains(token)
		if not risky:
			continue
		risky_count += 1
		var guarded: bool = source.contains("ReviewSpots.isolated(") or source.contains("custom_user_dir_name")
		check(guarded, "%s runs the session or writes state, so it must guard isolation" % file)
	check(risky_count >= 8, "guard scan found the session-running helpers (%d)" % risky_count)
	for file: String in ["peephole_review.gd", "porch_review.gd"]:
		check(FileAccess.get_file_as_string("res://scripts/dev/" + file).contains("ReviewSpots.isolated("), "%s is guarded" % file)

func _ready() -> void:
	# Isolation check: true in this Run-Tests copy, false for the real game's
	# user dir. Only the in-memory setting changes; the user dir in use was
	# fixed at startup, so nothing outside the copy is touched.
	check(ReviewSpots.is_isolated(), "Run-Tests copy counts as isolated")
	var setting: String = "application/config/custom_user_dir_name"
	var before: Variant = ProjectSettings.get_setting(setting, "")
	ProjectSettings.set_setting(setting, "The Quiet Hours")
	check(not ReviewSpots.is_isolated(), "the real user dir is refused")
	ProjectSettings.set_setting(setting, "")
	check(not ReviewSpots.is_isolated(), "an empty user dir is refused")
	ProjectSettings.set_setting(setting, before)
	check(ReviewSpots.is_isolated(), "setting restored")

	_check_dev_scene_guards()
	check(ReviewSpots.has_floor(0), "floor 0 exists")
	check(ReviewSpots.has_floor(HouseLayout.FLOOR_COUNT - 1), "top floor exists")

	GameState.new_campaign(42)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var front: RoomDoor = null
	for node: Node in scene.find_children("*", "RoomDoor", true, false):
		if (node as RoomDoor).is_front:
			front = node
	var door: Dictionary = ReviewSpots.front_door()
	check(front != null and Vector2(front.global_position.x, front.global_position.z).distance_to(Vector2(door["x"], door["z"])) < 0.01, "front_door() is the real front door")
	var inside: Vector3 = ReviewSpots.inside_front_door(1.0)
	check(HouseLayout.room_at(inside) == &"vestibule", "inside_front_door() stands in the entrance")

	var player: PlayerController = scene.get_node("Player")
	var capsule: CapsuleShape3D = (player.get_node("CollisionShape3D") as CollisionShape3D).shape
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.exclude = [player.get_rid()]
	query.collision_mask = player.collision_mask
	var space: PhysicsDirectSpaceState3D = player.get_world_3d().direct_space_state
	var spots: Dictionary = {}
	for shot: Dictionary in load("res://scripts/dev/capture_screenshots.gd").shots():
		spots["screenshot " + shot["name"]] = shot["position"]
	for id: StringName in [&"hall", &"landing", &"vestibule", &"corridor"]:
		spots["room spot " + id] = ReviewSpots.room_spot(id)
	spots["entrance 0.75"] = ReviewSpots.inside_front_door(0.75)
	spots["entrance 1.6"] = ReviewSpots.inside_front_door(1.6)
	for label: String in spots:
		var p: Vector3 = spots[label]
		check(HouseLayout.room_at(p) in HouseLayout.WALKABLE_ROOMS, "%s is in a walkable area (%s)" % [label, HouseLayout.room_at(p)])
		query.transform = Transform3D(Basis.IDENTITY, p + Vector3(0.0, capsule.height * 0.5 + 0.02, 0.0))
		check(space.intersect_shape(query, 1).is_empty(), "%s leaves room for the player body" % label)
	check(ReviewSpots.yaw_toward(Vector3.ZERO, Vector3(0.0, 0.0, -1.0)) == 0.0, "yaw 0 faces -Z")
	check(is_equal_approx(ReviewSpots.yaw_toward(Vector3.ZERO, Vector3(1.0, 0.0, 0.0)), -PI * 0.5), "yaw faces +X")
	scene.queue_free()
	await get_tree().process_frame
	if failures == 0:
		print("DEV HELPERS TEST: PASS (%d checks)" % checks)
	else:
		print("DEV HELPERS TEST: FAILED %d of %d checks" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)
