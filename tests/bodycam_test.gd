extends Node
## BODYCAM-002: body-worn camera motion (scripts/player/body_cam_motion.gd).
## Run only through tools/Run-Tests.ps1 (it writes settings in an isolated
## user dir and restores them).

var checks: int = 0
var failures: int = 0
var _player: PlayerController
var _camera: Camera3D
var _body: BodyCamMotion


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameState.new_campaign(42)
	var motion_before: float = Settings.get_number("camera_motion")
	check(Settings.set_number("camera_motion", 1.0) == OK, "camera motion on")
	var room: Node = load("res://scenes/main/test_room.tscn").instantiate()
	add_child(room)
	_player = room.get_node("Player")
	_camera = _player.get_node("Head/Camera3D")
	_body = _player.get_node("BodyCam")
	check(_body is BodyCamMotion, "player carries the body cam")
	await _frames(30)
	check(_player.is_on_floor(), "player settled")
	check(_camera.transform.is_equal_approx(Transform3D.IDENTITY), "standing still keeps the camera on the head")

	var walk: Dictionary = await _walk(false, 1.4)
	check(walk.dip > BodyCamMotion.BOB_HEIGHT * 0.6 and walk.dip < 0.06, "walking dips the view with each step (%.3f m)" % walk.dip)
	check(walk.side > BodyCamMotion.SWAY_SIDE * 0.5 and walk.side < 0.06, "walking shifts the view side to side (%.3f m)" % walk.side)
	check(walk.roll > deg_to_rad(BodyCamMotion.SWAY_ROLL_DEGREES * 0.4) and walk.roll < deg_to_rad(4.0), "walking rolls the view a little (%.2f°)" % rad_to_deg(walk.roll))
	check(walk.forward < 0.005, "the camera never moves forward or back")
	check(walk.reach <= BodyCamMotion.MAX_OFFSET + 0.0001, "offset stays within the wall clearance bound")
	check(walk.ray_follows, "interaction ray points where the camera points")
	check(walk.look_follows, "look direction is the camera's direction")
	check(walk.cycles >= 2, "several steps while walking (%d dips)" % walk.cycles)

	var settle: Dictionary = await _release_and_settle()
	check(settle.rested, "stopping lets the view settle back to the head")
	check(settle.max_jump < 0.006, "settling is smooth, no snap (%.4f m/frame)" % settle.max_jump)
	check(settle.frames > 3, "settling takes a moment instead of snapping (%d frames)" % settle.frames)

	var fast: Dictionary = await _walk(true, 1.0)
	check(fast.dip > walk.dip * 1.15, "walking fast sways more than walking (%.3f vs %.3f)" % [fast.dip, walk.dip])
	check(fast.reach <= BodyCamMotion.MAX_OFFSET + 0.0001, "fast sway still within bound")
	await _release_and_settle()

	# Turning on the spot (mouse look turns the body with rotate_y).
	var lean: float = 0.0
	var lag: float = 0.0
	for _i: int in 25:
		_player.rotate_y(-0.05)  # 3 rad/s at the fixed 60Hz physics rate
		await get_tree().physics_frame
		lean = minf(lean, _camera.rotation.z)
		lag = maxf(lag, _camera.rotation.y)
	check(lean < -deg_to_rad(0.5), "turning leans the view into the turn (%.2f°)" % rad_to_deg(lean))
	check(lean > -deg_to_rad(BodyCamMotion.TURN_LEAN_MAX_DEGREES + 0.6), "lean stays controlled")
	check(lag > deg_to_rad(0.3) and lag < deg_to_rad(BodyCamMotion.TURN_LAG_MAX_DEGREES + 0.4), "the view trails the turn slightly (%.2f°)" % rad_to_deg(lag))
	await get_tree().create_timer(1.0).timeout
	check(_camera.transform.origin.length() < 0.002 and absf(_camera.rotation.z) < deg_to_rad(0.1), "lean settles after the turn")

	# Control taken away mid-stride (dialogue, room, shelter, journal).
	await _start_walking()
	check(_camera.position.length() > 0.002, "swaying before the dialogue")
	_player.control_enabled = false
	check(_camera.transform.is_equal_approx(Transform3D.IDENTITY), "losing control rests the camera at once")
	_camera.position = Vector3(0.0, 0.0, -0.1)
	await _frames(5)
	check(_camera.position.is_equal_approx(Vector3(0.0, 0.0, -0.1)), "without control the body cam leaves the camera alone")
	_camera.position = Vector3.ZERO
	_player.control_enabled = true
	await _release_and_settle()

	# Pause mid-stride.
	await _start_walking()
	get_tree().paused = true
	await _frames(2)
	check(_camera.transform.is_equal_approx(Transform3D.IDENTITY), "pause rests the camera within a frame")
	await _frames(5)
	check(_camera.transform.is_equal_approx(Transform3D.IDENTITY), "paused camera stays still")
	get_tree().paused = false
	await _release_and_settle()

	# Door transition mid-stride: rest synchronously, then never write.
	await _start_walking()
	EventBus.door_transition_changed.emit(true)
	check(_camera.transform.is_equal_approx(Transform3D.IDENTITY), "door transition rests the camera before the door records it")
	var door_pose := Transform3D(Basis.from_euler(Vector3(0.0, 0.4, 0.0)), Vector3(0.0, -0.2, -0.3))
	_camera.transform = door_pose
	await _frames(5)
	check(_camera.transform.is_equal_approx(door_pose), "body cam never fights the door tween")
	_camera.transform = Transform3D.IDENTITY
	EventBus.door_transition_changed.emit(false)
	await _release_and_settle()

	# Setting off: no motion at all.
	check(Settings.set_number("camera_motion", 0.0) == OK, "camera motion off")
	var off: Dictionary = await _walk(false, 1.0)
	check(off.reach == 0.0 and off.roll == 0.0, "camera motion off: the camera never moves")
	for _i: int in 15:
		_player.rotate_y(-0.05)
		await get_tree().physics_frame
		check(_camera.transform == Transform3D.IDENTITY, "camera motion off: no turn lean")
	Input.action_release(&"move_forward")
	check(Settings.set_number("camera_motion", 1.0) == OK, "camera motion back on")
	room.queue_free()
	await _frames(2)

	await _real_door_handoff()

	check(Settings.set_number("camera_motion", motion_before) == OK, "setting restored")
	if failures == 0:
		print("BODYCAM TEST: PASS (%d checks)" % checks)
	else:
		print("BODYCAM TEST: FAILED %d of %d checks" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)


## The real RoomDoor while the view is leaning: the transition starts from the
## plain head pose and hands the camera back to it.
func _real_door_handoff() -> void:
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	var camera: Camera3D = player.get_node("Head/Camera3D")
	player.position = Vector3(5.1, 0.05, 7.0)
	player.rotation.y = deg_to_rad(90.0)
	await _frames(20)
	for _i: int in 12:
		player.rotate_y(0.05)
		await get_tree().physics_frame
	check(camera.transform.origin.length() > 0.0 or absf(camera.rotation.z) > deg_to_rad(0.3), "house view leans while turning")
	var door: RoomDoor = scene.find_child("Door_living_room", true, false)
	var room: RoomView = scene.get_node("RoomView")
	door.interact(player)
	check(camera.transform.is_equal_approx(Transform3D.IDENTITY), "door opening starts from the plain head pose")
	var head_pose: Transform3D = player.get_node("Head").global_transform
	await get_tree().create_timer(1.2).timeout
	check(room.is_open() and not player.control_enabled, "real door reaches the room")
	check(camera.global_transform.origin.distance_to(head_pose.origin) < 0.001, "door hands the camera back to the head")
	room.close()
	await get_tree().create_timer(RoomDoor.CLOSE_SECONDS + 0.1).timeout
	check(player.control_enabled, "control returns after the room")
	for _i: int in 12:
		player.rotate_y(0.05)
		await get_tree().physics_frame
	check(absf(camera.rotation.z) > deg_to_rad(0.3), "body cam resumes after the room")
	scene.queue_free()
	await _frames(2)


func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().process_frame


func _start_walking() -> void:
	_player.global_position = Vector3(0.0, 0.05, 4.0)
	_player.rotation.y = 0.0
	_player.velocity = Vector3.ZERO
	Input.action_press(&"move_forward")
	await get_tree().create_timer(0.7).timeout


func _walk(fast: bool, seconds: float) -> Dictionary:
	_player.global_position = Vector3(0.0, 0.05, 4.0)
	_player.rotation.y = 0.0
	_player.velocity = Vector3.ZERO
	await _frames(3)
	if fast:
		Input.action_press(&"walk_fast")
	Input.action_press(&"move_forward")
	var result: Dictionary = {"dip": 0.0, "side": 0.0, "roll": 0.0, "forward": 0.0, "reach": 0.0, "ray_follows": true, "look_follows": true, "cycles": 0}
	var ray: RayCast3D = _camera.get_node("InteractionRay")
	var was_low: bool = false
	var end: int = Time.get_ticks_msec() + int(seconds * 1000.0)
	while Time.get_ticks_msec() < end:
		await get_tree().process_frame
		var offset: Vector3 = _camera.position
		result.dip = maxf(result.dip, -offset.y)
		result.side = maxf(result.side, absf(offset.x))
		result.roll = maxf(result.roll, absf(_camera.rotation.z))
		result.forward = maxf(result.forward, absf(offset.z))
		result.reach = maxf(result.reach, offset.length())
		var view: Vector3 = -_camera.global_transform.basis.z
		if (-ray.global_transform.basis.z).dot(view) < 0.99999:
			result.ray_follows = false
		if _player.get_look_direction().dot(view) < 0.99999:
			result.look_follows = false
		var low: bool = offset.y < -0.01
		if low and not was_low:
			result.cycles += 1
		was_low = low
	Input.action_release(&"move_forward")
	Input.action_release(&"walk_fast")
	return result


func _release_and_settle() -> Dictionary:
	Input.action_release(&"move_forward")
	Input.action_release(&"walk_fast")
	var last: Vector3 = _camera.position
	var max_jump: float = 0.0
	var frame: int = 0
	var end: int = Time.get_ticks_msec() + 2000
	while Time.get_ticks_msec() < end:
		await get_tree().process_frame
		frame += 1
		max_jump = maxf(max_jump, _camera.position.distance_to(last))
		last = _camera.position
		if _camera.position.length() < 0.001 and absf(_camera.rotation.z) < deg_to_rad(0.05) and _player.velocity.length() < 0.01:
			return {"rested": true, "max_jump": max_jump, "frames": frame}
	return {"rested": false, "max_jump": max_jump, "frames": frame}
