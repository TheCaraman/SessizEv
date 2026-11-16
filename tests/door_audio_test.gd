extends Node
var cues: Array[String] = []
var failures: int = 0
var checks: int = 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
func _ready() -> void:
	GameState.new_campaign(42)
	var before: Dictionary = GameState.to_dict()
	var first: AudioStreamWAV = DoorAudio.make_knock()
	var second: AudioStreamWAV = DoorAudio.make_knock()
	check(first.data == second.data, "reproducible original cue")
	check(GameState.to_dict() == before, "audio synthesis never changes campaign")
	check(first.mix_rate == 22050 and not first.stereo and first.get_length() > 0.8, "valid mono positional cue")
	if "--export-audio" in OS.get_cmdline_user_args():
		check(first.save_to_wav("res://docs/qa/door-knock-placeholder.wav") == OK, "export listening sample")
	var peak: int = 0
	for i: int in first.data.size() / 2:
		peak = maxi(peak, absi(first.data.decode_s16(i * 2)))
	check(peak > 1000 and peak < 30000, "audible data without clipping")
	var audio := DoorAudio.new()
	add_child(audio)
	audio.arrival_cue.connect(func(id: String) -> void: cues.append(id))
	check(audio.position.is_equal_approx(Vector3(7.5, 1.3, 12.4)), "cue at authored front door")
	GameState.set_visitor("elena_ward", "day1_elena")
	check(cues == ["elena_ward"], "arrival plays once")
	EventBus.visitor_changed.emit("elena_ward")
	check(cues.size() == 1, "repeat notification silent")
	GameState.from_dict(GameState.to_dict())
	check(cues.size() == 1, "load does not invent arrival")
	GameState.set_visitor("")
	check(cues.size() == 1 and not audio.playing, "clear visitor stops cue")
	GameState.set_visitor("marcus_hale", "day2_marcus")
	check(cues == ["elena_ward", "marcus_hale"], "next visitor plays")
	audio.free()
	if failures == 0:
		print("DOOR AUDIO TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
