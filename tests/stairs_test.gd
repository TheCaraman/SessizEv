extends Node
## IMMERSION I-03: walking down (and up) the stairs with the real player body
## never snags. Lanes across the stair width, straight and angled headings,
## the turn into the hall at the bottom, and two physics rates.

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const FRAMES: int = 260

var checks: int = 0
var failures: int = 0
var _player: PlayerController
var _report: Array[String] = []


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	GameState.new_campaign(7)
	var scene: Node = SCENE.instantiate()
	add_child(scene)
	_player = scene.get_node("Player") as PlayerController
	await _frames(5)
	for rate: int in [60, 30]:
		Engine.physics_ticks_per_second = rate
		await _run_all(rate)
	Engine.physics_ticks_per_second = 60
	for line: String in _report:
		print(line)
	if failures == 0:
		print("STAIRS TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)


func _run_all(rate: int) -> void:
	var top_y: float = HouseLayout.STOREY_HEIGHT + 0.05
	# Down from the landing: lanes across the width, straight and angled.
	for lane: float in [8.95, 9.5, 10.02]:
		for yaw: float in [180.0, 195.0]:
			var end: Vector3 = await _walk(Vector3(lane, top_y, 2.9), yaw, &"move_forward", FRAMES)
			var ok: bool = end.y < 0.1 and end.z > 9.3
			_report.append("rate %d down lane %.2f yaw %.0f -> (%.2f, %.2f, %.2f) %s" % [rate, lane, yaw, end.x, end.y, end.z, "ok" if ok else "STUCK"])
			check(ok, "down the stairs at %d Hz, lane %.2f, heading %.0f" % [rate, lane, yaw])
	# Up from the hall, the same lanes.
	for lane: float in [8.95, 9.5, 10.02]:
		var end: Vector3 = await _walk(Vector3(lane, 0.05, 10.0), 0.0, &"move_forward", FRAMES)
		var ok: bool = absf(end.y - HouseLayout.STOREY_HEIGHT) < 0.1 and end.z < 3.8
		_report.append("rate %d up lane %.2f -> (%.2f, %.2f, %.2f) %s" % [rate, lane, end.x, end.y, end.z, "ok" if ok else "STUCK"])
		check(ok, "up the stairs at %d Hz, lane %.2f" % [rate, lane])
	# Off the bottom step and round into the hall (west), as a player does.
	for lane: float in [8.95, 9.5, 10.02]:
		var start: Vector3 = await _walk(Vector3(lane, top_y, 2.9), 180.0, &"move_forward", FRAMES)
		var end: Vector3 = await _walk(start, 90.0, &"move_forward", 150)
		var ok: bool = end.x < 7.5 and end.y < 0.1
		_report.append("rate %d bottom turn from lane %.2f -> (%.2f, %.2f, %.2f) %s" % [rate, lane, end.x, end.y, end.z, "ok" if ok else "STUCK"])
		check(ok, "turn from the stair foot into the hall at %d Hz, lane %.2f" % [rate, lane])
	# Stepping off the bottom step and turning west at once, beside the hall
	# guard: where the old slanted barrier box stuck out past the stair foot.
	for z: float in [9.5, 9.6]:
		var end: Vector3 = await _walk(Vector3(9.15, 0.05, z), 90.0, &"move_forward", 150)
		var ok: bool = end.x < 7.5
		_report.append("rate %d early west turn at z %.2f -> (%.2f, %.2f, %.2f) %s" % [rate, z, end.x, end.y, end.z, "ok" if ok else "STUCK"])
		check(ok, "early turn west off the stair foot at %d Hz, z %.2f" % [rate, z])
	# Diagonal approach to the top from the upstairs corridor (south-west).
	for start_x: float in [8.2]:
		var end: Vector3 = await _walk(Vector3(start_x, top_y, 2.6), 135.0, &"move_forward", FRAMES)
		var ok: bool = end.y < 0.1 or end.z > 4.5
		_report.append("rate %d diagonal entry from x %.2f -> (%.2f, %.2f, %.2f) %s" % [rate, start_x, end.x, end.y, end.z, "ok" if ok else "STUCK"])
		check(ok, "diagonal entry to the stairs at %d Hz from x %.2f" % [rate, start_x])


## Places the player, faces [param yaw_deg] (0 = north, 180 = south, 90 = west),
## holds [param action] for [param frames] physics frames, returns the position.
func _walk(from: Vector3, yaw_deg: float, action: StringName, frames: int) -> Vector3:
	_player.global_position = from
	_player.velocity = Vector3.ZERO
	_player.rotation.y = deg_to_rad(yaw_deg)
	await _frames(2)
	Input.action_press(action)
	await _frames(frames)
	Input.action_release(action)
	await _frames(2)
	return _player.global_position


func _frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame
