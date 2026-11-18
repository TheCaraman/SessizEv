extends Node
## FOLEY-001: door open/close cues and footsteps timed by walking.
## Run only through tools/Run-Tests.ps1 (isolated project and user dir).

var checks: int = 0
var failures: int = 0
var _player: PlayerController
var _steps: Footsteps
var _body: BodyCamMotion
var _heard: Array[Dictionary] = []


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
	_test_synthesis()
	var room: Node = load("res://scenes/main/test_room.tscn").instantiate()
	add_child(room)
	_player = room.get_node("Player")
	_steps = _player.get_node("Footsteps") as Footsteps
	_body = _player.get_node("BodyCam") as BodyCamMotion
	check(_steps != null and _steps.stream is AudioStreamRandomizer, "player carries footsteps with several takes")
	check((_steps.stream as AudioStreamRandomizer).streams_count == Foley.footstep_takes().size() and Foley.footstep_takes().size() >= 2, "every take is in the randomizer")
	check((_steps.stream as AudioStreamRandomizer).playback_mode == AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS, "the same take never plays twice in a row")
	_steps.stepped.connect(func(speed: float) -> void:
		_heard.append({"at": Time.get_ticks_msec(), "speed": speed, "phase": _body._phase, "walked": _steps.walked()}))
	await _frames(30)
	await _test_walking()
	await _test_silences()
	await _test_wall()
	room.queue_free()
	await _frames(2)
	await _test_real_door()
	check(Settings.set_number("camera_motion", motion_before) == OK, "camera motion restored")
	if failures == 0:
		print("FOLEY TEST: PASS (%d checks)" % checks)
	else:
		print("FOLEY TEST: FAILED %d of %d checks" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)


func _test_synthesis() -> void:
	var before: Dictionary = GameState.to_dict()
	var takes: Array[AudioStreamWAV] = []
	for variant: int in Foley.FOOTSTEP_VARIANTS:
		takes.append(Foley.make_footstep(variant))
	check(Foley.make_footstep(1).data == takes[1].data and Foley.make_door_open().data == Foley.make_door_open().data, "cues are reproducible")
	var distinct: bool = true
	for a: int in takes.size():
		for b: int in range(a + 1, takes.size()):
			distinct = distinct and takes[a].data != takes[b].data
	check(distinct, "every footstep take is different")
	var open: AudioStreamWAV = Foley.make_door_open()
	var close: AudioStreamWAV = Foley.make_door_close(RoomDoor.CLOSE_SECONDS)
	for cue: AudioStreamWAV in [takes[0], takes[3], open, close]:
		check(cue.mix_rate == Foley.RATE and not cue.stereo and cue.format == AudioStreamWAV.FORMAT_16_BITS, "mono 16-bit cue")
		var peak: int = _peak(cue, 0.0, cue.get_length())
		check(peak > 15000 and peak < 30000, "audible without clipping (peak %d)" % peak)
		check(absi(cue.data.decode_s16(cue.data.size() - 2)) < 200, "cue ends quietly, no click")
	check(takes[0].get_length() < 0.3, "a footstep is short (%.2f s)" % takes[0].get_length())
	check(Foley.peak_time(takes[2]) < 0.06, "a footstep hits at once")
	for take: AudioStreamWAV in takes:
		var bright: float = _brightness(take)
		check(bright < 300.0, "footsteps are dull wood, not a bright click (centre ~%.0f Hz)" % bright)
	# Open: the latch at the very start, then the creak while the leaf swings.
	check(_peak(open, 0.0, 0.03) > 6000, "opening starts with the latch")
	check(_rms(open, 0.15, 0.45) > 250.0 and _rms(open, 0.15, 0.45) < _rms(open, 0.08, 0.12), "the swing is heard, quieter than the latch (rms %.0f)" % _rms(open, 0.15, 0.45))
	check(open.get_length() >= RoomDoor.OPEN_SECONDS, "opening cue covers the swing")
	# Close: the loudest moment is the leaf meeting the frame, at CLOSE_SECONDS.
	var hit: float = Foley.peak_time(close)
	print("door open rms: handle %.0f bolt %.0f swing %.0f | close: swing %.0f hit %.0f tail %.0f" % [_rms(open, 0.0, 0.05), _rms(open, 0.08, 0.12), _rms(open, 0.15, 0.45), _rms(close, 0.05, RoomDoor.CLOSE_SECONDS - 0.05), _rms(close, RoomDoor.CLOSE_SECONDS, RoomDoor.CLOSE_SECONDS + 0.05), _rms(close, RoomDoor.CLOSE_SECONDS + 0.1, close.get_length())])
	check(absf(hit - RoomDoor.CLOSE_SECONDS) < 0.05, "the door hits the frame when the swing ends (%.2f s)" % hit)
	check(_rms(close, 0.05, RoomDoor.CLOSE_SECONDS - 0.1) > 200.0 and _rms(close, 0.05, RoomDoor.CLOSE_SECONDS - 0.1) * 3.0 < _rms(close, RoomDoor.CLOSE_SECONDS, RoomDoor.CLOSE_SECONDS + 0.05), "the swing is heard before the hit, well under it")
	check(close.get_length() > RoomDoor.CLOSE_SECONDS + 0.1, "the latch is heard after the hit")
	check(open.data != close.data and _rms(open, 0.0, 0.4) != _rms(close, 0.0, 0.4), "opening and closing sound different")
	check(GameState.to_dict() == before, "building sounds never changes the campaign")
	_test_recordings()
	if "--export-audio" in OS.get_cmdline_user_args():
		DirAccess.make_dir_recursive_absolute("res://docs/qa/foley")
		for variant: int in takes.size():
			check(takes[variant].save_to_wav("res://docs/qa/foley/footstep-%d.wav" % variant) == OK, "export footstep sample")
		check(open.save_to_wav("res://docs/qa/foley/door-open.wav") == OK, "export door open sample")
		check(close.save_to_wav("res://docs/qa/foley/door-close.wav") == OK, "export door close sample")


## Recorded foley (made by Codex) replaces the synthesized cues when present,
## and must fit the timing the door and footsteps rely on.
func _test_recordings() -> void:
	var open: AudioStream = Foley.recorded_cue("door_open")
	var close: AudioStream = Foley.recorded_cue("door_close")
	check((Foley.door_open() is AudioStreamWAV) if open == null else Foley.door_open() == open, "door opening uses the recording when there is one")
	check((Foley.door_close(RoomDoor.CLOSE_SECONDS) is AudioStreamWAV) if close == null else Foley.door_close(RoomDoor.CLOSE_SECONDS) == close, "door closing uses the recording when there is one")
	if open != null:
		check(open.get_length() >= 0.2 and open.get_length() <= 1.5, "recorded door_open is 0.2-1.5 s (%.2f)" % open.get_length())
	if close != null:
		check(close.get_length() > RoomDoor.CLOSE_SECONDS + 0.05 and close.get_length() <= 1.8, "recorded door_close runs past the hit at %.2f s (%.2f)" % [RoomDoor.CLOSE_SECONDS, close.get_length()])
		if close is AudioStreamWAV:
			var hit: float = Foley.peak_time(close as AudioStreamWAV)
			check(absf(hit - RoomDoor.CLOSE_SECONDS) < 0.06, "recorded door_close hits the frame at %.2f s (%.2f)" % [RoomDoor.CLOSE_SECONDS, hit])
	var recorded_steps: int = 0
	while Foley.recorded_cue("footstep_%d" % recorded_steps) != null:
		var take: AudioStream = Foley.recorded_cue("footstep_%d" % recorded_steps)
		check(take.get_length() >= 0.05 and take.get_length() <= 0.6, "recorded footstep_%d is one short step (%.2f s)" % [recorded_steps, take.get_length()])
		recorded_steps += 1
	check(recorded_steps == 0 or recorded_steps >= 2, "at least two recorded footsteps, so steps can vary")
	check(Foley.footstep_takes().size() == (recorded_steps if recorded_steps > 0 else Foley.FOOTSTEP_VARIANTS), "footsteps use the recordings when there are any")


func _test_walking() -> void:
	_heard.clear()
	var walk: Dictionary = await _walk(false, 2.0)
	var expected: float = walk.walked / Footsteps.STEP_LENGTH
	check(_heard.size() >= 2 and absf(_heard.size() - expected) <= 1.01, "one step per %.2f m walked (%d steps over %.2f m)" % [Footsteps.STEP_LENGTH, _heard.size(), walk.walked])
	var gaps: Array[float] = _gaps(_heard)
	var walk_gap: float = Footsteps.STEP_LENGTH / _player.walk_speed
	var even: bool = not gaps.is_empty()
	for gap: float in gaps:
		even = even and absf(gap - walk_gap) < 0.07
	check(even, "steps come evenly at walking pace (%s s, expected %.2f)" % [str(gaps), walk_gap])
	var in_phase: bool = true
	for step: Dictionary in _heard:
		# BodyCam's dip is deepest at a quarter and three quarters of the cycle.
		var off: float = absf(fmod(float(step.phase), PI) - PI * 0.5)
		in_phase = in_phase and off < 0.45
	check(in_phase, "each step lands at the bottom of the body cam's dip")
	var walk_volume: float = _steps.volume_db

	await _release()
	_heard.clear()
	var fast: Dictionary = await _walk(true, 1.6)
	var fast_gaps: Array[float] = _gaps(_heard)
	check(not fast_gaps.is_empty() and _average(fast_gaps) < _average(gaps) * 0.8, "walking fast makes steps come sooner (%.2f vs %.2f s)" % [_average(fast_gaps), _average(gaps)])
	check(_steps.volume_db > walk_volume + 1.0, "and a little louder (%.1f vs %.1f dB)" % [_steps.volume_db, walk_volume])
	check(fast.walked > walk.walked * 0.9, "fast walk covers ground")

	# Letting go: at most the foot already coming down, then silence.
	_heard.clear()
	Input.action_release(&"move_forward")
	Input.action_release(&"walk_fast")
	var stopped_at: int = 0
	var end: int = Time.get_ticks_msec() + 1500
	while Time.get_ticks_msec() < end:
		await get_tree().process_frame
		if stopped_at == 0 and _player.velocity.length() < 0.01:
			stopped_at = Time.get_ticks_msec()
	check(stopped_at > 0, "the body stops")
	check(_heard.size() <= 1, "stopping makes at most one last step (%d)" % _heard.size())
	var after_stop: int = 0
	for step: Dictionary in _heard:
		if int(step.at) > stopped_at:
			after_stop += 1
	check(after_stop == 0, "no step once standing still")

	_heard.clear()
	await _frames(90)
	check(_heard.is_empty(), "standing still is silent")
	for _i: int in 20:
		_player.rotate_y(0.08)
		await get_tree().physics_frame
	check(_heard.is_empty(), "turning on the spot is silent")


## Holding the key while something else has control never walks.
func _test_silences() -> void:
	# Dialogue, room view, journal, menus: control is taken away.
	_heard.clear()
	_place()
	_player.control_enabled = false
	Input.action_press(&"move_forward")
	await get_tree().create_timer(1.0).timeout
	check(_heard.is_empty(), "no steps while the player has no control (menu, room, dialogue)")
	Input.action_release(&"move_forward")
	_player.control_enabled = true
	await _frames(10)

	# Control comes back mid-stride: the next step is still a full step away.
	_heard.clear()
	var walked_before: float = _steps.walked()
	Input.action_press(&"move_forward")
	await get_tree().create_timer(0.8).timeout
	_player.control_enabled = false
	var count: int = _heard.size()
	await get_tree().create_timer(0.6).timeout
	check(_heard.size() == count, "taking control away mid-walk stops the steps at once")
	check(count >= 1 and float(_heard[0].walked) - walked_before <= Footsteps.STEP_LENGTH + 0.05, "walking resumes the same rhythm")
	Input.action_release(&"move_forward")
	_player.control_enabled = true
	await _release()

	# Paused game.
	_heard.clear()
	_place()
	Input.action_press(&"move_forward")
	await get_tree().create_timer(0.3).timeout
	get_tree().paused = true
	var paused_count: int = _heard.size()
	await get_tree().create_timer(0.8).timeout
	check(_heard.size() == paused_count, "no steps while paused")
	get_tree().paused = false
	Input.action_release(&"move_forward")
	await _release()

	# Door transition: the camera moves into the doorway, the body does not.
	_heard.clear()
	_place()
	Input.action_press(&"move_forward")
	await get_tree().create_timer(0.3).timeout
	EventBus.door_transition_changed.emit(true)
	var door_count: int = _heard.size()
	await get_tree().create_timer(0.8).timeout
	check(_heard.size() == door_count, "no steps during a door transition")
	EventBus.door_transition_changed.emit(false)
	Input.action_release(&"move_forward")
	await _release()

	# Falling (spawn, load above the floor).
	_heard.clear()
	_player.global_position = Vector3(0.0, 6.0, 4.0)
	_player.velocity = Vector3(2.4, 0.0, 0.0)
	await get_tree().create_timer(0.3).timeout
	check(not _player.is_on_floor() or _heard.is_empty(), "no steps in the air")
	await _release()


## Pushing into a wall: the body does not move, so no steps.
func _test_wall() -> void:
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4.0, 3.0, 0.2)
	shape.shape = box
	wall.add_child(shape)
	add_child(wall)
	_place()
	wall.global_position = _player.global_position + Vector3(0.0, 1.5, -0.5)
	await get_tree().physics_frame
	await get_tree().physics_frame
	Input.action_press(&"move_forward")
	await get_tree().create_timer(0.4).timeout
	_heard.clear()
	var walked: float = _steps.walked()
	await get_tree().create_timer(1.2).timeout
	check(_heard.is_empty() and _steps.walked() - walked < 0.1, "pressing into a wall makes no steps (%.2f m)" % (_steps.walked() - walked))
	Input.action_release(&"move_forward")
	wall.queue_free()
	await _release()


## The real house door: one cue as it opens, a different one as it swings shut,
## nothing for blocked presses, and silence when the opening is cancelled.
func _test_real_door() -> void:
	GameState.new_campaign(43)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	var steps: Footsteps = player.get_node("Footsteps")
	var house_steps: Array[float] = []
	steps.stepped.connect(func(speed: float) -> void: house_steps.append(speed))
	var room: RoomView = scene.get_node("RoomView")
	var door: RoomDoor = scene.find_child("Door_living_room", true, false)
	player.global_position = door.to_global(Vector3(0.0, 0.05, 1.3))
	player.global_rotation = Vector3(0.0, door.global_rotation.y, 0.0)
	await _frames(20)
	var cues: Array[StringName] = []
	door.sound_played.connect(func(kind: StringName) -> void: cues.append(kind))
	var sound: AudioStreamPlayer3D = door.get_node("DoorSound")
	check(sound != null and sound.get_parent() == door, "the door carries its own positional sound")
	check(sound.global_position.distance_to(door.global_position + Vector3.UP * 1.05) < 0.01, "sound sits in the doorway")
	var before: Dictionary = GameState.to_dict()
	door.interact(player)
	door.interact(player)
	check(cues == [&"open"], "opening plays the opening cue once")
	check(sound.stream != null and sound.stream.get_length() >= RoomDoor.OPEN_SECONDS * 0.5, "the opening cue is loaded")
	var open_stream: AudioStream = sound.stream
	await get_tree().create_timer(RoomDoor.TRANSITION_SECONDS + 0.4).timeout
	check(room.is_open(), "room reached")
	check(house_steps.is_empty(), "stepping into the doorway makes no footsteps")
	room.close()
	check(cues == [&"open", &"close"], "leaving the room plays the closing cue")
	check(sound.stream != open_stream and sound.stream.get_length() > RoomDoor.CLOSE_SECONDS, "closing has its own cue that lasts the swing")
	door.interact(player)
	check(cues.size() == 2, "a blocked press while it swings shut is silent")
	await get_tree().create_timer(RoomDoor.CLOSE_SECONDS + 0.1).timeout
	check(not door.is_closing(), "door closed")
	# Opening again and cancelling with Escape: the cue stops with the swing.
	door.interact(player)
	check(cues == [&"open", &"close", &"open"], "reopening plays the opening cue again")
	await _frames(3)
	var escape := InputEventAction.new()
	escape.action = &"pause"
	escape.pressed = true
	door._unhandled_input(escape)
	check(not sound.playing and is_zero_approx(door.get_node("Hinge").rotation.y), "cancelling the opening stops its sound")
	check(cues.size() == 3, "cancelling does not play a closing cue")
	var front: RoomDoor = null
	for node: Node in scene.find_children("*", "RoomDoor", true, false):
		if (node as RoomDoor).is_front:
			front = node
	check(front != null, "front door found")
	if front != null:
		var front_cues: Array[StringName] = []
		front.sound_played.connect(func(kind: StringName) -> void: front_cues.append(kind))
		front.interact(player)
		check(front_cues.is_empty(), "the locked front door makes no open sound")
	check(GameState.to_dict() == before, "door sounds use no campaign time")
	scene.queue_free()
	await _frames(3)


func _place() -> void:
	_player.global_position = Vector3(0.0, 0.05, 4.0)
	_player.rotation.y = 0.0
	_player.velocity = Vector3.ZERO


func _walk(fast: bool, seconds: float) -> Dictionary:
	_place()
	await _frames(3)
	var start: float = _steps.walked()
	if fast:
		Input.action_press(&"walk_fast")
	Input.action_press(&"move_forward")
	await get_tree().create_timer(seconds).timeout
	return {"walked": _steps.walked() - start}


func _release() -> void:
	Input.action_release(&"move_forward")
	Input.action_release(&"walk_fast")
	var end: int = Time.get_ticks_msec() + 1500
	while Time.get_ticks_msec() < end and (_player.velocity.length() > 0.01 or not _player.is_on_floor()):
		await get_tree().physics_frame
	await _frames(3)


func _gaps(steps: Array[Dictionary]) -> Array[float]:
	var gaps: Array[float] = []
	for i: int in range(1, steps.size()):
		gaps.append(snappedf((int(steps[i].at) - int(steps[i - 1].at)) / 1000.0, 0.01))
	return gaps


func _average(values: Array[float]) -> float:
	var total: float = 0.0
	for value: float in values:
		total += value
	return total / maxf(values.size(), 1.0)


func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().process_frame


func _peak(cue: AudioStreamWAV, from: float, to: float) -> int:
	var best: int = 0
	for i: int in range(int(from * cue.mix_rate), mini(int(to * cue.mix_rate), cue.data.size() / 2)):
		best = maxi(best, absi(cue.data.decode_s16(i * 2)))
	return best


## Rough spectral centre (Hz) from the energy of the first difference: how
## bright a cue sounds. The first footstep takes measured ~430 Hz and were
## judged too sharp; the wooden ones are ~160-220 Hz.
func _brightness(cue: AudioStreamWAV) -> float:
	var energy: float = 0.0
	var change: float = 0.0
	var last: float = 0.0
	for i: int in cue.data.size() / 2:
		var value: float = cue.data.decode_s16(i * 2)
		energy += value * value
		change += (value - last) * (value - last)
		last = value
	return cue.mix_rate / TAU * sqrt(change / maxf(energy, 1.0))


func _rms(cue: AudioStreamWAV, from: float, to: float) -> float:
	var total: float = 0.0
	var count: int = 0
	for i: int in range(int(from * cue.mix_rate), mini(int(to * cue.mix_rate), cue.data.size() / 2)):
		var value: float = cue.data.decode_s16(i * 2)
		total += value * value
		count += 1
	return sqrt(total / maxf(count, 1.0))
