class_name NightSession
extends Node
var events: HouseNightEvents
var witness := NightWitness.new()

func _ready() -> void:
	events = HouseNightEvents.new()
	events.name = "HouseNightEvents"
	add_child(events)
## Scene-local owner of the optional Day 3 watch. Durable data is in GameState.

func can_start() -> bool:
	return GameState.active and GameState.day == 3 and GameState.minutes >= 1200 and GameState.minutes <= GameState.LAST_MINUTE and GameState.visitor == "" and GameState.night_session.is_empty()

func begin_watch() -> bool:
	if not can_start():
		return false
	var timeline := NightTimeline.new()
	if not timeline.begin(GameState.day, int(GameState.player["energy"]), maxi(GameState.minutes, GameState.NIGHT_START)):
		return false
	GameState.night_session = timeline.to_dict()
	# Only fresh nights opt in; loading an older active night never backfills a witness.
	GameState.set_flag(NightWitness.PROTOCOL, true)
	GameState.advance_minutes(maxi(0, 1380 - GameState.minutes))
	SaveManager.save_game()
	return true

func next_clock_text() -> String:
	var timeline := NightTimeline.new()
	if not timeline.from_dict(GameState.night_session):
		return ""
	var minute: int = posmod(timeline.next_boundary(), 1440)
	return "%02d:%02d" % [minute / 60, minute % 60]

func wait_until_boundary() -> bool:
	if not GameState.night_in_progress():
		return false
	var timeline := NightTimeline.new()
	if not timeline.from_dict(GameState.night_session):
		return false
	var record: Dictionary = witness.propose(timeline.next_boundary())
	GameState.advance_minutes(maxi(0, timeline.next_boundary() - GameState.minutes))
	if witness.publish(record) != OK:
		EventBus.notice_requested.emit(tr("NARR_SAVE_FAILED"))
	SaveManager.save_game()
	return true

func sleep_remaining() -> bool:
	if not GameState.night_in_progress():
		return false
	var timeline := NightTimeline.new()
	if not timeline.from_dict(GameState.night_session):
		return false
	timeline.advance_to(int(timeline.rules["end"]), true)
	GameState.night_session = timeline.to_dict()
	GameState.player["energy"] = timeline.energy()
	GameState.minutes = int(timeline.rules["end"])
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	EventBus.phase_changed.emit(GameState.get_phase())
	return true

func finish() -> bool:
	if not GameState.night_in_progress():
		return false
	var timeline := NightTimeline.new()
	if not timeline.from_dict(GameState.night_session) or not timeline.claim_morning():
		return false
	GameState.night_session = timeline.to_dict()
	GameState.start_next_day(timeline.energy())
	SaveManager.save_game()
	return true
