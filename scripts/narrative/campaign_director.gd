class_name CampaignDirector
extends Node
## Runs the authored campaign day by day. It covers Day 1 ("The First Knock")
## and the visits of Day 2 ("Strangers"; docs/Day2Design.md).
##
## It decides what can be done in each 2D room (room actions), brings
## visitors to the door from the campaign's stored timetable
## (GameState.arrival_schedule, ArrivalScheduler), and resolves the
## night. All lasting state goes through GameState.

## Daniel will not go to bed before this.
const EARLIEST_SLEEP_MINUTE: int = 20 * 60
## The last day with authored content; later mornings say so on screen.
const LAST_AUTHORED_DAY: int = 4

var power: PowerIncident
var night: NightSession
var _player_actions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/events/player_actions.json"))
var _watch_confirmation: bool = false
var judgment := ResidentJudgment.new()
var isolation := Isolation.new()
var closure := Day4Closure.new()
var accusation := Accusation.new()
var day4_broadcast := Day4Broadcast.new()
var _watch_confirmation_time: int = -1
var _repair_confirmation: bool = false
var _repair_offer: Dictionary = {}
var _confirmation_day: int = 0
var _confirmation_minute: int = 0
var shelter: ShelterManager

var _dialogue: DialogueRunner
## Visits, sorted by day, then start time, then id: always the live
## campaign's stored timetable, so a new game or a load needs no reload.
var _arrivals: Array[Dictionary]:
	get:
		return GameState.arrival_schedule
## "room|action" of a timed action the player has been warned about once
## because it would outlast the visitor's patience. Pressing it again goes
## ahead.
var _warned_action: String = ""


## Called once by the session scene before play begins.
func setup(dialogue: DialogueRunner) -> void:
	closure.shelter = shelter
	accusation.shelter = shelter
	day4_broadcast.shelter = shelter
	power = PowerIncident.new()
	add_child(power)
	night = NightSession.new()
	night.name = "NightSession"
	add_child(night)
	_dialogue = dialogue
	EventBus.time_changed.connect(_check_power_time)
	EventBus.room_view_closed.connect(func(_room: StringName) -> void: _repair_confirmation = false)
	EventBus.room_view_closed.connect(func(_room: StringName) -> void: _watch_confirmation = false)
	EventBus.room_view_closed.connect(func(_room: StringName) -> void: judgment.cancel())
	EventBus.room_view_closed.connect(func(_room: StringName) -> void: isolation.cancel())
	EventBus.room_view_closed.connect(func(_room: StringName) -> void: closure.cancel())
	EventBus.day_started.connect(func(_day: int) -> void: closure.cancel())
	EventBus.time_changed.connect(func(_day: int, _minutes: int) -> void: _update_arrivals())
	EventBus.front_door_used.connect(_on_front_door_used)
	# A visitor who ran out of patience during a conversation leaves when it ends.
	_dialogue.ended.connect(func(_id: String) -> void: _update_arrivals())
	_update_arrivals()


# --- Room actions -----------------------------------------------------------

## What the player can do in [param room_id] right now.
## Each entry is {"id": String, "label": String} with the label already
## translated.
func get_room_actions(room_id: String) -> Array[Dictionary]:
	room_id = RoomAliases.canonical(room_id)
	var actions: Array[Dictionary] = []
	for action: Dictionary in closure.actions(room_id):
		actions.append(action)
	for id: String in accusation.targets(room_id):
		actions.append({"id": "accuse:" + id, "label": tr("ACC_REREAD" if accusation.recorded(id) else "ACC_ACTION").format({"name": Roster.get_display_name(id)})})
	for action: Dictionary in night.witness.actions(room_id):
		actions.append(action)
	for action: Dictionary in isolation.actions(room_id):
		actions.append({"id": "isolation:" + action["id"], "label": action["label"]})
	for id: String in judgment.targets(room_id):
		actions.append({"id": "expel:" + id, "label": tr("JUDGMENT_EXPEL_ACTION").format({"name": Roster.get_display_name(id)})})
	for entry: Dictionary in judgment.memories(room_id):
		actions.append({"id": "discuss_expulsion:" + entry["witness"] + ":" + entry["subject"], "label": tr("EXPEL_DISCUSS").format({"witness": Roster.get_display_name(entry["witness"]), "name": Roster.get_display_name(entry["subject"])})})
	if room_id == "daniel_bedroom" and Day4Review.available():
		actions.append({"id": "review_last_night", "label": tr("DAY4_REVIEW_ACTION")})
	if room_id == str(night.events.definition["source_room"]) and night.events.can_inspect():
		actions.append({"id": "inspect_pipes", "label": night.events.inspection_label()})
	if GameState.day >= 2 and GameState.day <= 4 and room_id == "daniel_bedroom" and shelter != null:
		actions.append({"id": "manage", "label": tr("SHELTER_TITLE")})
	if room_id == "utility" and GameState.power_incident.has("cause"):
		for id: String in ["panel", "access", "outside", "card", "repair", "defer"]:
			actions.append({"id": "power:" + id, "label": tr("POWER_ACTION_" + id.to_upper()) if id != "repair" else power.repair_label()})
	if room_id == "utility" and GameState.power_incident.has("cause") and power.eligible("marcus_hale"):
		actions.append({"id": "power:explain", "label": tr("POWER_ACTION_EXPLAIN")})
	match room_id:
		"living_room":
			actions.append({"id": "watch_tv", "label": tr("ACTION_WATCH_TV")})
			actions.append({"id": "radio", "label": day4_broadcast.label() if GameState.day == 4 else tr("ACTION_RADIO")})
		"utility":
			actions.append({"id": "check_supplies", "label": tr("ACTION_CHECK_SUPPLIES")})
		"daniel_bedroom":
			if night.can_start():
				actions.append({"id": "watch", "label": tr("WATCH_ACTION")})
			if GameState.night_in_progress():
				actions.append({"id": "wait_watch", "label": tr("WATCH_WAIT_ACTION").format({"time": night.next_clock_text()})})
			if GameState.minutes < GameState.NIGHT_START:
				actions.append({"id": "rest", "label": tr("ACTION_REST").format({"energy": _player_actions["rest"]["energy_per_hour"]})})
			if can_sleep():
				actions.append({"id": "sleep", "label": tr("ACTION_SLEEP")})
			if can_save():
				actions.append({"id": "save", "label": tr("ACTION_SAVE")})
	for npc_id: String in GameState.get_room_occupants(room_id):
		if _dialogue_for(npc_id) != "":
			actions.append({
				"id": "talk:" + npc_id,
				"label": tr("ACTION_TALK").format({"name": Roster.get_display_name(npc_id)}),
			})
	return actions


## Carries out a room action and returns the narration to show, already
## translated. Returns "" for unknown or unavailable actions.
func perform_room_action(room_id: String, action_id: String) -> String:
	room_id = RoomAliases.canonical(room_id)
	var available: bool = false
	for action: Dictionary in get_room_actions(room_id):
		if action["id"] == action_id:
			available = true
			break
	if not available:
		return ""
	if action_id.begins_with("day4:"):
		judgment.cancel()
		isolation.cancel()
		_repair_confirmation = false
		return closure.perform(room_id, action_id.trim_prefix("day4:"))
	closure.cancel()
	if action_id.begins_with("accuse:"):
		judgment.cancel()
		isolation.cancel()
		_repair_confirmation = false
		var id: String = action_id.trim_prefix("accuse:")
		if accusation.recorded(id):
			return accusation.response(id)
		EventBus.accusation_requested.emit(room_id, id)
		return ""
	if action_id.begins_with("witness:"):
		judgment.cancel()
		isolation.cancel()
		_repair_confirmation = false
		return night.witness.interview(room_id, action_id.trim_prefix("witness:"))
	if action_id != "watch":
		_watch_confirmation = false
	if action_id.begins_with("isolation:"):
		judgment.cancel()
		_repair_confirmation = false
		return isolation.perform(room_id, action_id.trim_prefix("isolation:"))
	isolation.cancel()
	if not action_id.begins_with("expel:"):
		judgment.cancel()
	else:
		_repair_confirmation = false
		return judgment.expel(room_id, action_id.trim_prefix("expel:"))
	if action_id.begins_with("discuss_expulsion:"):
		return judgment.discuss(room_id, action_id.get_slice(":", 1), action_id.get_slice(":", 2))

	if action_id.begins_with("power:"):
		var choice: String = action_id.trim_prefix("power:")
		if choice == "repair":
			var current_offer: Dictionary = power.repair_quote()
			var confirmed: bool = _repair_confirmation and _repair_offer == current_offer and _confirmation_day == GameState.day and _confirmation_minute == GameState.minutes
			var result: String = power.repair(confirmed)
			_repair_offer = current_offer
			_confirmation_day = GameState.day
			_confirmation_minute = GameState.minutes
			_repair_confirmation = not confirmed
			return result
		_repair_confirmation = false
		if choice == "explain" and power.eligible("marcus_hale"):
			EvidenceManager.collect("power_marcus", "POWER_MARCUS_CLAIM", "claim")
			return tr("POWER_MARCUS_CLAIM")
		if choice == "card":
			EvidenceManager.collect("power_card", "POWER_CARD")
			return tr("POWER_CARD")
		if choice == "defer":
			return tr("POWER_DEFER")
		return power.inspect(choice)

	_repair_confirmation = false
	if action_id.begins_with("talk:"):
		_warned_action = ""
		_dialogue.start(_dialogue_for(action_id.trim_prefix("talk:")))
		return ""

	# Warn once before an action that would outlast the person at the door.
	if action_id == "watch_tv" and not power.is_powered():
		return tr("POWER_TV_OFF")
	var duration: int = _duration_of(action_id)
	if GameState.day >= 3 and not power.pending() and GameState.minutes + duration > GameState.get_action_time_limit():
		return tr("POWER_TOO_LATE")
	var key: String = "%s|%s" % [room_id, action_id]
	if duration > 0 and _would_lose_visitor(duration) and _warned_action != key:
		_warned_action = key
		return tr("NARR_VISITOR_MAY_LEAVE").format({"name": Roster.get_display_name(GameState.visitor)})
	_warned_action = ""

	match action_id:
		"review_last_night":
			if Day4Review.record_open() != OK:
				return tr("DAY4_REVIEW_SAVE_FAILED")
			EventBus.review_requested.emit(Day4Review.text())
			return ""
		"inspect_pipes":
			return night.events.inspect()
		"watch":
			if not _watch_confirmation or _watch_confirmation_time != GameState.minutes:
				_watch_confirmation = true
				_watch_confirmation_time = GameState.minutes
				return tr("WATCH_CONFIRM")
			_watch_confirmation = false
			if night.begin_watch():
				if power.pending() and GameState.minutes >= GameState.NIGHT_START:
					power.trigger()
				return tr("WATCH_STARTED") + ("\n\n" + tr("POWER_WAKE") if not power.is_powered() else "")
			return ""
		"wait_watch":
			if night.wait_until_boundary():
				if GameState.minutes >= 1860:
					return _resolve_night()
				return tr("WATCH_WAITED").format({"time": GameState.get_clock_text(), "energy": GameState.player["energy"]})
			return ""
		"manage":
			EventBus.shelter_view_requested.emit()
			return ""
		"watch_tv":
			return _broadcast("tv", "NARR_TV_DAY1" if GameState.day == 1 else "NARR_TV_LATER", "NARR_TV_AGAIN")
		"radio":
			return _radio()
		"check_supplies":
			return _with_knock(_spend(10), _supplies_text())
		"rest":
			var started: int = GameState.minutes
			var interrupted: bool = _spend(_duration_of("rest"))
			var elapsed: int = GameState.minutes - started
			var before_energy: int = int(GameState.player["energy"])
			var recovery: int = int(float(_player_actions["rest"]["energy_per_hour"]) * elapsed / 60.0)
			GameState.player["energy"] = mini(100, before_energy + recovery)
			# Power interruption already autosaved inside _spend; finish its snapshot.
			if interrupted and GameState.day == 3 and not power.pending():
				SaveManager.save_game()
			return _with_knock(interrupted, tr("NARR_REST").format({"minutes": elapsed, "energy": int(GameState.player["energy"]) - before_energy}))
		"sleep":
			return _resolve_night()
		"save":
			var error: Error = SaveManager.save_game()
			if error != OK:
				return tr("NARR_SAVE_FAILED")
			return tr("NARR_SAVED").format({"day": GameState.day, "time": GameState.get_clock_text()})
	return ""


## Daniel can save in his own room at any quiet moment: not while someone is
## at the door and not in the middle of a conversation (V-006).
func can_save() -> bool:
	return GameState.visitor == "" and not _dialogue.is_active()


func can_sleep() -> bool:
	return GameState.minutes >= EARLIEST_SLEEP_MINUTE and GameState.visitor == ""


## How long an action takes if nothing interrupts it; 0 for untimed actions.
func _duration_of(action_id: String) -> int:
	match action_id:
		"watch_tv":
			return 5 if GameState.get_flag(_day_flag("tv")) else 20
		"radio":
			if GameState.day == 4:
				return day4_broadcast.duration()
			return 5 if GameState.get_flag(_day_flag("radio")) else 15
		"check_supplies":
			return 10
		"rest":
			return int(_player_actions["rest"]["minutes"])
	return 0


func _day_flag(key: String) -> String:
	return "%s_day_%d" % [key, GameState.day]


## Spends up to [param minutes]. If someone is due at the door before that,
## the action stops at their knock and the rest of the time is not spent
## (docs/Day2Design.md, section 2). Returns true if a knock cut it short.
func _spend(minutes: int) -> bool:
	var spend: int = minutes
	var interrupted: bool = false
	if GameState.visitor == "":
		for arrival: Dictionary in _arrivals:
			if not _is_upcoming(arrival):
				continue
			var until: int = int(arrival["start"]) - GameState.minutes
			if until > 0 and until < spend:
				spend = until
				interrupted = true
			break
	if power.pending() and GameState.minutes + spend >= GameState.NIGHT_START:
		GameState.advance_minutes(maxi(0, GameState.NIGHT_START - GameState.minutes))
		power.trigger()
		return true
	GameState.advance_minutes(spend)
	return interrupted


func _with_knock(interrupted: bool, text: String) -> String:
	return text + ("\n\n" + tr("POWER_WAKE" if GameState.day == 3 else "NARR_KNOCK_INTERRUPTS") if interrupted else "")


## A broadcast is told in full the first time each day and briefly after.
func _broadcast(key: String, first_text: String, again_text: String) -> String:
	var flag: String = _day_flag(key)
	var first: bool = not GameState.get_flag(flag)
	var interrupted: bool = _spend(_duration_of("watch_tv" if key == "tv" else "radio"))
	if interrupted:
		# Cut off before the end: it can be heard properly later.
		return tr("POWER_WAKE" if GameState.day == 3 else "NARR_KNOCK_INTERRUPTS")
	GameState.set_flag(flag)
	return tr(first_text) if first else tr(again_text)


## Day 1 carries the "vessels are down" report. From Day 2 the radio carries
## the memory-loss report until it has been heard once.
func _radio() -> String:
	if GameState.day == 4:
		return day4_broadcast.listen()
	if GameState.day == 1:
		return _broadcast("radio", "NARR_RADIO_DAY1", "NARR_RADIO_AGAIN")
	if GameState.get_flag("heard_memory_loss_report"):
		return _broadcast("radio", "NARR_RADIO_AGAIN", "NARR_RADIO_AGAIN")
	var text: String = _broadcast("radio", "RADIO_D2_MEMORY_LOSS", "RADIO_D2_MEMORY_LOSS")
	if GameState.get_flag(_day_flag("radio")):
		GameState.set_flag("heard_memory_loss_report")
	return text


## Stock on hand, tonight's expected use, and a warning a day ahead if it
## will not stretch.
func _supplies_text() -> String:
	var people: int = GameState.get_headcount()
	var values: Dictionary = GameState.resources.duplicate()
	values["people"] = people
	var text: String = tr("NARR_SUPPLIES").format(values)
	text += "\n\n" + tr("NARR_SUPPLIES_TONIGHT").format({"people": people})
	if int(GameState.resources["food"]) < people or int(GameState.resources["water"]) < people:
		text += " " + tr("NARR_SUPPLIES_SHORT_TONIGHT")
	elif int(GameState.resources["food"]) < people * 2 or int(GameState.resources["water"]) < people * 2:
		text += " " + tr("NARR_SUPPLIES_SHORT_TOMORROW")
	return text


## Which conversation a resident has today, or "" if they have nothing to say.
func _dialogue_for(npc_id: String) -> String:
	var short_name: String = npc_id.get_slice("_", 0)
	var dialogue_id: String = "%s_resident_day%d" % [short_name, GameState.day]
	return dialogue_id if DialogueRunner.exists(dialogue_id) else ""


# --- Visits -----------------------------------------------------------------


func _get_arrival(arrival_id: String) -> Dictionary:
	for arrival: Dictionary in _arrivals:
		if arrival["id"] == arrival_id:
			return arrival
	return {}


## A visit that is still to come today: not yet begun or missed, and its
## character has not already been met, turned away or lost.
func _is_upcoming(arrival: Dictionary) -> bool:
	return (
		arrival["day"] == GameState.day
		and not GameState.is_arrival_resolved(arrival["id"])
		and GameState.get_status(arrival["npc"]) == "unknown"
		and GameState.minutes < int(arrival["end"])
	)


## True if spending [param minutes] now would run past the moment the person
## at the door gives up.
func _would_lose_visitor(minutes: int) -> bool:
	if GameState.visitor == "":
		return false
	var arrival: Dictionary = _get_arrival(GameState.visitor_arrival)
	return not arrival.is_empty() and GameState.minutes + minutes >= int(arrival["end"])


## Brings the clock and the doorstep into agreement: the waiting visitor
## leaves once their time is up, the next due visitor knocks, and a visit
## whose whole window was skipped is recorded as missed. One person at most
## is at the door, and no visit ever happens twice.
func _update_arrivals() -> void:
	if not GameState.active or _dialogue == null:
		return
	if GameState.visitor != "":
		var current: Dictionary = _get_arrival(GameState.visitor_arrival)
		var out_of_time: bool = (
			not current.is_empty()
			and (GameState.day > int(current["day"]) or GameState.minutes >= int(current["end"]))
		)
		if not out_of_time or _dialogue.is_active():
			return
		GameState.remove_npc(GameState.visitor, "left")
		GameState.set_flag("%s_left_unanswered" % current["id"])
		GameState.set_visitor("")
		EventBus.notice_requested.emit(tr("HUD_KNOCKING_STOPPED"))

	for arrival: Dictionary in _arrivals:
		if arrival["day"] != GameState.day or GameState.is_arrival_resolved(arrival["id"]):
			continue
		if GameState.minutes < int(arrival["start"]):
			continue
		GameState.resolve_arrival(arrival["id"])
		# Someone already met, turned away, dead or gone never comes back.
		if GameState.get_status(arrival["npc"]) != "unknown":
			continue
		if GameState.minutes >= int(arrival["end"]):
			# The whole window passed unseen: they came, waited and went.
			GameState.remove_npc(arrival["npc"], "left")
			GameState.set_flag("%s_left_unanswered" % arrival["id"])
			continue
		GameState.set_visitor(arrival["npc"], arrival["id"])
		return


func _on_front_door_used() -> void:
	if _dialogue.is_active() or GameState.visitor == "":
		return
	var arrival: Dictionary = _get_arrival(GameState.visitor_arrival)
	if not arrival.is_empty():
		_dialogue.start(arrival["dialogue"])


# --- Night ------------------------------------------------------------------

## Ends the day. The first two nights are quiet by design: no authored attack
## or sabotage (docs/Day2Design.md, section 8). Returns the morning narration.
func _resolve_night() -> String:
	if power.pending():
		GameState.advance_minutes(maxi(0, GameState.NIGHT_START - GameState.minutes))
		power.trigger()
		return tr("POWER_WAKE")
	if GameState.day >= 4:
		return tr("NARR_END_OF_BUILD")
	var watch_reports: PackedStringArray = shelter.resolve_night() if shelter != null else PackedStringArray()
	var used_watch: bool = GameState.night_in_progress()
	if used_watch:
		if not night.sleep_remaining() or not night.finish():
			return ""
	else:
		GameState.start_next_day()
	SaveManager.save_game()

	var others: int = GameState.get_residents().size()
	var text: String
	if GameState.day == 2:
		var elena_here: bool = GameState.get_status("elena_ward") == "resident"
		text = tr("NARR_MORNING_D2_ELENA") if elena_here else tr("NARR_MORNING_D2_ALONE")
	elif others == 0:
		text = tr("NARR_MORNING_ALONE").format({"day": GameState.day})
	else:
		text = tr("NARR_MORNING_OTHERS").format({"day": GameState.day, "count": others})

	if not watch_reports.is_empty():
		text += "\n\n" + "\n".join(watch_reports)
	if used_watch:
		text += "\n\n" + tr("WATCH_MORNING").format({"energy": GameState.player["energy"]})

	# A shortfall is always reported, never hidden.
	var short: PackedStringArray = []
	for resource: String in ["food", "water"]:
		if GameState.get_flag("shortage_%s_day_%d" % [resource, GameState.day], 0):
			short.append(tr("RESOURCE_" + resource.to_upper()))
	if not short.is_empty():
		text += "\n\n" + tr("NARR_MORNING_SHORTAGE").format({"what": ", ".join(short)})

	if GameState.day == 4:
		text += "\n\n" + tr("RADIO_D4_MORNING_GUIDE")
	if GameState.day > LAST_AUTHORED_DAY:
		text += "\n\n" + tr("NARR_END_OF_BUILD")
	return text

func _check_power_time(_day: int, _minutes: int) -> void:
	if power.pending() and GameState.minutes >= GameState.NIGHT_START:
		power.trigger()
