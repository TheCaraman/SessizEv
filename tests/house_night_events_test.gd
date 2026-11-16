extends Node
var checks: int = 0
var failures: int = 0
var cues: int = 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
func prepare() -> void:
	GameState.new_campaign(42)
	GameState.day = 3
	GameState.minutes = 1380
	GameState.power_incident = {"state": "restored", "cause": "loose_connection", "inspected": []}
	var timeline := NightTimeline.new()
	timeline.begin(3, 100)
	GameState.night_session = timeline.to_dict()
func _ready() -> void:
	prepare()
	var night := NightSession.new()
	add_child(night)
	var events: HouseNightEvents = night.events
	events.observation_emitted.connect(func(_id: String) -> void: cues += 1)
	var people: Dictionary = GameState.npcs.duplicate(true)
	var supplies: Dictionary = GameState.resources.duplicate()
	GameState.advance_minutes(120)
	check(cues == 1 and GameState.get_flag("night_pipes_day3_heard"), "empty house gets real non-human event")
	check(GameState.npcs == people and GameState.resources == supplies, "event never invents perpetrator or consumes supplies")
	check(GameState.evidence.size() == 1 and GameState.evidence[0]["key"] == "PIPE_HEARD", "heard fact without cause leak")
	check(events.take_observation() != "" and events.take_observation() == "", "one-shot contextual observation")
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	check(cues == 1, "repeated clock notification silent")
	check(SaveManager.save_game("pipe_event") == OK and SaveManager.load_game("pipe_event"), "save event")
	check(cues == 1 and events.take_observation() == "", "load never replays cue")
	check(events.can_inspect(), "heard source investigable")
	var minute: int = GameState.minutes
	check(events.inspect() == tr("PIPE_SOURCE") and GameState.minutes == minute + 10, "real source inspection costs ten minutes")
	check(GameState.evidence.size() == 2 and GameState.evidence[1]["kind"] == "fact", "source is separate verified fact")
	var inspected: Dictionary = GameState.to_dict()
	events.inspect()
	check(GameState.to_dict() == inspected, "reread is free and idempotent")
	check(not EvidenceManager.journal_text().contains("pressure_shift_in_loose_pipe_support"), "hidden cause identifier not shown")
	prepare()
	night.sleep_remaining()
	check(not GameState.get_flag("night_pipes_day3_heard") and not events.can_inspect(), "sleep does not invent personal observations")
	prepare()
	var timeline := NightTimeline.new()
	timeline.from_dict(GameState.night_session)
	timeline.advance_to(1620)
	GameState.night_session = timeline.to_dict()
	GameState.minutes = 1620
	GameState.from_dict(GameState.to_dict())
	GameState.advance_minutes(120)
	check(not GameState.get_flag("night_pipes_day3_heard"), "legacy mid-night load never retroactively triggers sound")
	prepare()
	GameState.advance_minutes(120)
	GameState.minutes = 1855
	timeline.from_dict(GameState.night_session)
	timeline.advance_to(1855)
	GameState.night_session = timeline.to_dict()
	var before: Dictionary = GameState.to_dict()
	check(events.inspect() == tr("POWER_TOO_LATE") and GameState.to_dict() == before, "late inspection refused atomically")
	var sound: AudioStreamWAV = HouseNightEvents.make_rattle()
	check(sound.data == HouseNightEvents.make_rattle().data and sound.mix_rate == 22050, "original deterministic sound")
	if "--export-audio" in OS.get_cmdline_user_args():
		check(sound.save_to_wav("res://docs/qa/pipe-rattle-placeholder.wav") == OK, "export listening sample")
	SaveManager.delete_save("pipe_event")
	night.free()
	if failures == 0:
		print("HOUSE NIGHT EVENTS TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
