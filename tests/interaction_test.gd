extends Node
## Headless test for doors, the interaction prompt and the 2D room view.
##
## Run with:
##   godot --headless --path . res://tests/interaction_test.tscn
## Exit code 0 means every check passed.
##
## Checks:
##   1. Looking at a wall shows no prompt.
##   2. Looking at a room door shows a prompt naming the room.
##   3. Pressing interact opens that room's 2D view and freezes the player.
##   4. A linked room can be opened from inside the view.
##   5. Pressing pause closes the view and returns control.
##   6. The locked front door shows "Locked" and does not open anything.

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")

var _player: PlayerController
var _room_view: RoomView
var _frame: int = 0
var _failures: PackedStringArray = []
var _checks: int = 0
var _prompt: String = ""
var _opened: Array[StringName] = []
var _closed: Array[StringName] = []


func _ready() -> void:
	TranslationServer.set_locale("en")
	var scene: Node = SCENE.instantiate()
	add_child(scene)
	_player = scene.get_node("Player") as PlayerController
	_room_view = scene.get_node("RoomView") as RoomView
	EventBus.interaction_prompt_changed.connect(func(text: String) -> void: _prompt = text)
	EventBus.room_view_opened.connect(func(id: StringName) -> void: _opened.append(id))
	EventBus.room_view_closed.connect(func(id: StringName) -> void: _closed.append(id))


func _physics_process(_delta: float) -> void:
	_frame += 1
	match _frame:
		5:
			# In the hall, facing the stair wall (east): nothing to use.
			_face(Vector3(5.1, 0.05, 8.2), 90.0)
		10:
			_check(_prompt == "", "a plain wall should show no prompt, got '%s'" % _prompt)
			# Facing west, toward the living room door at x = 5, z = 6.
			_face(Vector3(6.2, 0.05, 10.2), 90.0)
		15:
			_check(
				_prompt.contains("Living room") and _prompt.contains("E"),
				"door prompt should name the key and the room, got '%s'" % _prompt
			)
			_send_action(&"interact")
		20:
			_check(not _room_view.is_open() and not _player.control_enabled, "physical opening precedes room view and locks movement")
		# Allow the authored leaf swing AND camera approach before the handoff.
		80:
			_check(_opened == [&"living_room"], "interact should open the living room, got %s" % [_opened])
			_check(_room_view.is_open(), "room view should be visible")
			_check(not _player.control_enabled, "player should be frozen while a room is shown")
			_check(_prompt == "", "prompt should clear while a room is shown, got '%s'" % _prompt)
			# Use the passage to the dining area, as the on-screen button would.
			_room_view.open(&"dining")
		85:
			_check(_room_view.get_room_id() == &"dining", "linked room should be shown")
			_send_action(&"pause")
		90:
			_check(not _room_view.is_open(), "pause should close the room view")
			_check(_closed == [&"dining"], "closing should be announced once, got %s" % [_closed])
			_check(_player.control_enabled, "player should regain control after leaving a room")
			# The front door, from inside the entrance.
			_face(Vector3(7.5, 0.05, 11.5), 180.0)
		95:
			_check(_prompt == "Locked", "front door should read 'Locked', got '%s'" % _prompt)
			_opened.clear()
			_send_action(&"interact")
		100:
			_check(_opened.is_empty(), "a locked door should not open a room view")
			_check(_player.control_enabled, "a locked door should not freeze the player")
			_finish()


## Places the player and turns them. Yaw is in degrees; positive turns left
## from north, so 90 faces west and 180 faces south.
func _face(position: Vector3, yaw_degrees: float) -> void:
	_player.global_position = position
	_player.velocity = Vector3.ZERO
	_player.rotation = Vector3(0.0, deg_to_rad(yaw_degrees), 0.0)


func _send_action(action: StringName) -> void:
	for pressed: bool in [true, false]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = pressed
		Input.parse_input_event(event)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("INTERACTION TEST: PASS (%d checks)" % _checks)
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		print("INTERACTION TEST: FAIL (%d of %d)" % [_failures.size(), _checks])
		get_tree().quit(1)
