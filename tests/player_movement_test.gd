extends Node
## Headless test for the first-person controller.
##
## Run with:
##   godot --headless --path . res://tests/player_movement_test.tscn
## Exit code 0 means every check passed.
##
## Checks:
##   1. The player lands on the floor and stays there.
##   2. Holding move_forward walks straight along -Z and through a 0.9 m gap.
##   3. Releasing the key brings the player to a stop.
##   4. Disabling control ignores input.
##   5. Walking up a ramp raises the player onto the 1 m platform.
##   6. walk_fast is faster than normal walking.

const ROOM_SCENE: PackedScene = preload("res://scenes/main/test_room.tscn")

var _player: PlayerController
var _frame: int = 0
var _failures: PackedStringArray = []
var _mark: Vector3
var _walk_distance: float = 0.0


func _ready() -> void:
	var room: Node = ROOM_SCENE.instantiate()
	add_child(room)
	_player = room.get_node("Player") as PlayerController


func _physics_process(_delta: float) -> void:
	_frame += 1
	match _frame:
		30:
			_check(_player.is_on_floor(), "player should be on the floor after settling")
			_check(absf(_player.global_position.y) < 0.02, "player should rest at y = 0")
			_mark = _player.global_position
			Input.action_press(&"move_forward")
		210:
			var moved: Vector3 = _player.global_position - _mark
			_check(moved.z < -6.0, "walking forward 3 s should pass the gap (dz = %.2f)" % moved.z)
			_check(absf(moved.x) < 0.05, "walking forward should not drift sideways (dx = %.3f)" % moved.x)
			Input.action_release(&"move_forward")
		240:
			_check(_player.velocity.length() < 0.01, "player should stop after releasing the key")
			_player.control_enabled = false
			_mark = _player.global_position
			Input.action_press(&"move_back")
		270:
			var drift: float = _player.global_position.distance_to(_mark)
			_check(drift < 0.01, "disabled control should ignore input (moved %.3f)" % drift)
			Input.action_release(&"move_back")
			_player.control_enabled = true
			# Move to the bottom of the ramp lane.
			_player.global_position = Vector3(4.5, 0.05, 2.5)
			_player.velocity = Vector3.ZERO
		290:
			Input.action_press(&"move_forward")
		590:
			var height: float = _player.global_position.y
			_check(height > 0.95, "ramp should lift the player onto the platform (y = %.2f)" % height)
			Input.action_release(&"move_forward")
			# Speed comparison on open floor.
			_player.global_position = Vector3(-4.0, 0.05, 5.0)
			_player.velocity = Vector3.ZERO
		610:
			_mark = _player.global_position
			Input.action_press(&"move_forward")
		670:
			_walk_distance = _player.global_position.distance_to(_mark)
			Input.action_release(&"move_forward")
			_player.global_position = Vector3(-4.0, 0.05, 5.0)
			_player.velocity = Vector3.ZERO
		690:
			_mark = _player.global_position
			Input.action_press(&"move_forward")
			Input.action_press(&"walk_fast")
		750:
			var fast_distance: float = _player.global_position.distance_to(_mark)
			_check(
				fast_distance > _walk_distance * 1.3,
				"walk_fast should be faster (walk %.2f m, fast %.2f m)" % [_walk_distance, fast_distance]
			)
			Input.action_release(&"move_forward")
			Input.action_release(&"walk_fast")
			_finish()


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("PLAYER MOVEMENT TEST: PASS (6 checks)")
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		print("PLAYER MOVEMENT TEST: FAIL (%d)" % _failures.size())
		get_tree().quit(1)
