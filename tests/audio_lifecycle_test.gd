extends Node
## Hardware-backed gate. Dummy playback is deliberately not accepted as proof
## that the output mixer has released a voice after scene destruction.

var checks: int = 0
var failures: int = 0
var arrivals: int = 0
var noises: int = 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _ready() -> void:
	var expected: String = ""
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--expected-driver="):
			expected = arg.trim_prefix("--expected-driver=")
	var actual: String = AudioServer.get_driver_name()
	print("AUDIO LIFECYCLE DRIVER: " + actual)
	check(expected != "" and actual == expected, "requested audio backend is actually active")
	check(actual != "Dummy", "Dummy cannot satisfy the hardware lifecycle gate")
	if failures > 0:
		get_tree().quit(2)
		return
	for cycle: int in 3:
		await _cycle(cycle)
	if failures == 0:
		print("AUDIO LIFECYCLE TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)

func _cycle(cycle: int) -> void:
	GameState.new_campaign(42 + cycle)
	var world := Node3D.new()
	add_child(world)
	var camera := Camera3D.new()
	camera.current = true
	world.add_child(camera)
	var door := DoorAudio.new()
	world.add_child(door)
	door.volume_db = -80.0
	door.arrival_cue.connect(func(_id: String) -> void: arrivals += 1)
	GameState.set_visitor("elena_ward", "day1_elena")
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(door.playing, "arrival voice really starts on cycle %d" % cycle)
	check(arrivals == cycle + 1, "previous scene has no surviving arrival callback")
	var door_refs: Array[WeakRef] = _voice_refs(door)
	check(door_refs.size() == 2, "arrival owns a real stream and playback")
	world.queue_free()
	await get_tree().process_frame
	await _wait_release(door_refs)
	check(door_refs.size() == 2 and door_refs[0].get_ref() == null, "arrival stream released after active scene removal")
	check(door_refs.size() == 2 and door_refs[1].get_ref() == null, "arrival playback released after active scene removal")

	GameState.new_campaign(142 + cycle)
	GameState.day = 3
	GameState.minutes = 1380
	GameState.power_incident = {"state": "restored", "cause": "loose_connection", "inspected": []}
	var timeline := NightTimeline.new()
	check(timeline.begin(3, 100), "authored awake night fixture starts")
	GameState.night_session = timeline.to_dict()
	var events := HouseNightEvents.new()
	add_child(events)
	events._sound.volume_db = -80.0
	events.observation_emitted.connect(func(_id: String) -> void: noises += 1)
	GameState.advance_minutes(120)
	await get_tree().physics_frame
	await get_tree().physics_frame
	check(events._sound.playing, "real pipe event starts its voice")
	check(noises == cycle + 1, "removed event scene never observes later clocks")
	var pipe_refs: Array[WeakRef] = _voice_refs(events._sound)
	check(pipe_refs.size() == 2, "pipe owns a real stream and playback")
	events.queue_free()
	await get_tree().process_frame
	await _wait_release(pipe_refs)
	check(pipe_refs.size() == 2 and pipe_refs[0].get_ref() == null, "pipe stream released after active scene removal")
	check(pipe_refs.size() == 2 and pipe_refs[1].get_ref() == null, "pipe playback released after active scene removal")

## Separate synchronous scope prevents a coroutine local keeping a strong
## playback reference alive across the destruction we are trying to measure.
func _voice_refs(player: AudioStreamPlayer3D) -> Array[WeakRef]:
	var playback: AudioStreamPlayback = player.get_stream_playback()
	if player.stream == null or playback == null:
		return []
	return [weakref(player.stream), weakref(playback)]

func _wait_release(refs: Array[WeakRef]) -> void:
	var deadline: int = Time.get_ticks_msec() + 1000
	while Time.get_ticks_msec() < deadline:
		var released: bool = true
		for reference: WeakRef in refs:
			if reference.get_ref() != null:
				released = false
		if released:
			return
		await get_tree().create_timer(0.02).timeout
