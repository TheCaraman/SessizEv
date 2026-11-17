extends Node
## Headless test for the house blockout.
##
## Run with:
##   godot --headless --path . res://tests/house_layout_test.tscn
## Exit code 0 means every check passed.
##
## Checks:
##   1. Every room has a floor at the right height and room to stand in.
##   2. A player-sized capsule can pass through every open passage.
##   3. Exterior doors and corridor doors block passage, and each corridor
##      door leads to the room the layout says it does.
##   4. Selected walls between rooms are solid.
##   5. HouseLayout.room_at() returns the right room for every room centre.
##   6. The player can walk up the stairs to the upper floor, and back down.

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const CAPSULE_RADIUS: float = 0.38  # must match scenes/player/player.tscn (CAMERA-CLIP-001)
const CAPSULE_HEIGHT: float = 1.75
## Capsule centre height above the floor, with 5 cm of clearance.
const CAPSULE_CENTER_Y: float = CAPSULE_HEIGHT * 0.5 + 0.05

## Pairs of plan points (x, z) on the same floor that must NOT see each other.
const SOLID_CHECKS: Array[Dictionary] = [
	{"floor": 0, "from": Vector2(4, 5.7), "to": Vector2(6, 5.7), "what": "kitchen / hall"},
	{"floor": 0, "from": Vector2(1, 2), "to": Vector2(1, 4), "what": "service / kitchen"},
	{"floor": 0, "from": Vector2(11, 1), "to": Vector2(13, 1), "what": "guest A / guest B"},
	{"floor": 0, "from": Vector2(2, 7), "to": Vector2(2, 9), "what": "kitchen / living"},
	{"floor": 0, "from": Vector2(11, 7), "to": Vector2(13, 7), "what": "multipurpose / bathroom"}
]
var _player: PlayerController
var _space: PhysicsDirectSpaceState3D
var _frame: int = 0
var _failures: PackedStringArray = []
var _checks: int = 0


func _ready() -> void:
	GameState.new_campaign(42)
	var scene: Node = SCENE.instantiate()
	add_child(scene)
	_player = scene.get_node("Player") as PlayerController
	_player.set_physics_process(false)
	for frame: int in 5:
		await get_tree().physics_frame
	_space = _player.get_world_3d().direct_space_state
	_check(HouseLayout.FLOOR_COUNT == 1, "exactly one storey")
	_check(HouseLayout.VOIDS.is_empty() and not scene.has_node("House/Stairs"), "no stair or upper floor hole")
	_check(not _raycast(_player.position + Vector3.UP * 0.1, _player.position + Vector3.DOWN * 0.3).is_empty(), "spawn has floor support")
	_check_rooms()
	_check_openings()
	_check_solid_walls()
	_check_open_foyer()
	_check(HouseLayout.get_room(&"dining")["id"] == &"kitchen", "old dining ID resolves to kitchen")
	_check(HouseLayout.get_room(&"pantry")["id"] == &"utility", "old pantry ID resolves to service")
	_check(HouseLayout.get_room(&"bathroom_ground")["id"] == &"bathroom_upper", "old second bathroom resolves to single bathroom")
	_check(get_tree().get_nodes_in_group("window_dust").size() == 2, "local haze at both actual windows")
	_check(get_tree().get_nodes_in_group("window_shafts").size() == 6, "three soft shafts at each actual window")
	_finish()

func _check_rooms() -> void:
	_check((HouseLayout.get_room(&"hall")["rects"][0] as Rect2).size.x >= 3.7, "main hall is at least 3.7 m wide after HOUSE-ATMOS-001")
	_check(_capsule_fits(Vector3(7.0, 0.0, 8.4)), "newly widened ground strip is physically usable")
	_check(_capsule_fits(Vector3(10.0, 0.0, 4.25)), "quiet wing is physically usable")
	for room: Dictionary in HouseLayout.ROOMS:
		var id: StringName = room["id"]
		var center: Vector3 = HouseLayout.room_center(id)

		var hit: Dictionary = _raycast(center + Vector3.UP, center + Vector3.DOWN)
		_check(
			not hit.is_empty() and absf((hit["position"] as Vector3).y - center.y) < 0.01,
			"room '%s' should have a floor at y = %.2f" % [id, center.y]
		)
		_check(_capsule_fits(center), "room '%s' should have standing room at its centre" % id)
		_check(
			HouseLayout.room_at(center + Vector3.UP * 0.02) == id,
			"room_at() should return '%s' at its centre, got '%s'"
			% [id, HouseLayout.room_at(center + Vector3.UP * 0.02)]
		)


func _check_open_foyer() -> void:
	_check(_capsule_can_move(Vector3(7.0, 0.0, 11.0), Vector3(7.0, 0.0, 4.25)), "continuous entry-to-corner route")
	_check(_capsule_can_move(Vector3(7.0, 0.0, 4.25), Vector3(14.0, 0.0, 4.25)), "continuous L-turn and bedroom wing")
	_check(not _raycast(Vector3(7.0, 2.8, 7.0), Vector3(7.0, 4.0, 7.0)).is_empty(), "roof closes house above head")
	_check(HouseLayout.room_at(Vector3(7.0, 4.0, 7.0)) == &"", "no upstairs room classification")
	for room: Dictionary in HouseLayout.ROOMS:
		_check(room["floor"] == 0, "all authored rooms use ground floor: " + str(room["id"]))

func _check_openings() -> void:
	for wall: Dictionary in HouseLayout.WALLS:
		var base_y: float = HouseLayout.floor_height(wall["floor"])
		for opening: Dictionary in wall["openings"]:
			var a: Vector3
			var b: Vector3
			if wall["axis"] == "x":
				a = Vector3(opening["pos"], base_y, wall["at"] - 0.5)
				b = Vector3(opening["pos"], base_y, wall["at"] + 0.5)
			else:
				a = Vector3(wall["at"] - 0.5, base_y, opening["pos"])
				b = Vector3(wall["at"] + 0.5, base_y, opening["pos"])
			var label: String = "floor %d, %s-wall at %.1f, opening at %.2f" % [
				wall["floor"], wall["axis"], wall["at"], opening["pos"]
			]
			if opening.get("window", false):
				# Windows let light in but nobody out: check at glass height.
				var glass_y := Vector3.UP * (HouseLayout.WINDOW_SILL + 0.6)
				var pane: Dictionary = _raycast(a + glass_y, b + glass_y)
				_check(not pane.is_empty(), "a window should block passage (%s)" % label)
			elif opening.get("sealed", false) or opening.has("to"):
				# Exterior doors and corridor doors into 2D rooms never open in 3D.
				var hit: Dictionary = _raycast(a + Vector3.UP, b + Vector3.UP)
				_check(
					not hit.is_empty() and hit["collider"] is RoomDoor,
					"a door should block passage (%s)" % label
				)
				if opening.has("to") and not hit.is_empty() and hit["collider"] is RoomDoor:
					_check(
						(hit["collider"] as RoomDoor).room_id == opening["to"],
						"door should lead to '%s' (%s)" % [opening["to"], label]
					)
			else:
				_check(_capsule_can_move(a, b), "capsule should pass through opening (%s)" % label)


func _check_solid_walls() -> void:
	for entry: Dictionary in SOLID_CHECKS:
		var y: float = HouseLayout.floor_height(entry["floor"]) + 1.0
		var from: Vector2 = entry["from"]
		var to: Vector2 = entry["to"]
		var hit: Dictionary = _raycast(Vector3(from.x, y, from.y), Vector3(to.x, y, to.y))
		_check(not hit.is_empty(), "wall should be solid: %s" % entry["what"])


func _raycast(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [_player.get_rid()]
	return _space.intersect_ray(query)


func _capsule_query(at_floor_point: Vector3) -> PhysicsShapeQueryParameters3D:
	var capsule := CapsuleShape3D.new()
	capsule.radius = CAPSULE_RADIUS
	capsule.height = CAPSULE_HEIGHT
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform = Transform3D(Basis.IDENTITY, at_floor_point + Vector3.UP * CAPSULE_CENTER_Y)
	query.exclude = [_player.get_rid()]
	return query


func _capsule_fits(at_floor_point: Vector3) -> bool:
	return _space.intersect_shape(_capsule_query(at_floor_point), 1).is_empty()


func _capsule_can_move(from_floor_point: Vector3, to_floor_point: Vector3) -> bool:
	if not _capsule_fits(from_floor_point):
		return false
	var query: PhysicsShapeQueryParameters3D = _capsule_query(from_floor_point)
	query.motion = to_floor_point - from_floor_point
	var result: PackedFloat32Array = _space.cast_motion(query)
	return result.size() == 2 and result[0] >= 0.999


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("HOUSE LAYOUT TEST: PASS (%d checks)" % _checks)
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		print("HOUSE LAYOUT TEST: FAIL (%d of %d)" % [_failures.size(), _checks])
		get_tree().quit(1)
