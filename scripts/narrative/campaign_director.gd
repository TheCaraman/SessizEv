class_name CampaignDirector
extends Node
## Runs the authored campaign day by day. At present it covers Day 1,
## "The First Knock": the broadcasts, Elena's arrival in the evening, the
## first night and the morning of Day 2.
##
## It decides what can be done in each 2D room (room actions), reacts to the
## clock, and resolves the night. All lasting state goes through GameState.

const ELENA: String = "elena_ward"
## Elena knocks once it is evening on Day 1.
const ELENA_ARRIVAL_MINUTE: int = GameState.EVENING_START
## If nobody answers by then she gives up and leaves.
const ELENA_GIVES_UP_MINUTE: int = 21 * 60 + 30
## Daniel will not go to bed before this.
const EARLIEST_SLEEP_MINUTE: int = 20 * 60

var _dialogue: DialogueRunner


## Called once by the session scene before play begins.
func setup(dialogue: DialogueRunner) -> void:
	_dialogue = dialogue
	EventBus.time_changed.connect(_on_time_changed)
	EventBus.front_door_used.connect(_on_front_door_used)


## What the player can do in [param room_id] right now.
## Each entry is {"id": String, "label": String} with the label already
## translated.
func get_room_actions(room_id: String) -> Array[Dictionary]:
	var actions: Array[Dictionary] = []
	match room_id:
		"living_room":
			actions.append({"id": "watch_tv", "label": tr("ACTION_WATCH_TV")})
			actions.append({"id": "radio", "label": tr("ACTION_RADIO")})
		"pantry":
			actions.append({"id": "check_supplies", "label": tr("ACTION_CHECK_SUPPLIES")})
		"daniel_bedroom":
			if GameState.minutes < GameState.NIGHT_START:
				actions.append({"id": "rest", "label": tr("ACTION_REST")})
			if can_sleep():
				actions.append({"id": "sleep", "label": tr("ACTION_SLEEP")})
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
	var available: bool = false
	for action: Dictionary in get_room_actions(room_id):
		if action["id"] == action_id:
			available = true
			break
	if not available:
		return ""

	if action_id.begins_with("talk:"):
		_dialogue.start(_dialogue_for(action_id.trim_prefix("talk:")))
		return ""

	match action_id:
		"watch_tv":
			return _once_per_day("tv", 20, "NARR_TV_DAY1", "NARR_TV_AGAIN")
		"radio":
			return _once_per_day("radio", 15, "NARR_RADIO_DAY1", "NARR_RADIO_AGAIN")
		"check_supplies":
			GameState.advance_minutes(10)
			return tr("NARR_SUPPLIES").format(GameState.resources)
		"rest":
			GameState.advance_minutes(60)
			return tr("NARR_REST")
		"sleep":
			return _resolve_night()
	return ""


func can_sleep() -> bool:
	return GameState.minutes >= EARLIEST_SLEEP_MINUTE and GameState.visitor == ""


## Narrates something the first time each day and a shorter line afterwards.
## Only the first time costs the full amount of time.
func _once_per_day(key: String, minutes: int, first_text: String, again_text: String) -> String:
	var flag: String = "%s_day_%d" % [key, GameState.day]
	if GameState.get_flag(flag):
		GameState.advance_minutes(5)
		return tr(again_text)
	GameState.set_flag(flag)
	GameState.advance_minutes(minutes)
	return tr(first_text)


## Which conversation a resident has today, or "" if they have nothing to say.
func _dialogue_for(npc_id: String) -> String:
	if npc_id == ELENA and GameState.day == 1:
		return "elena_resident_day1"
	return ""


func _on_time_changed(day: int, minutes: int) -> void:
	if day != 1:
		return
	if (
		minutes >= ELENA_ARRIVAL_MINUTE
		and not GameState.get_flag("elena_arrived")
		and GameState.get_status(ELENA) == "unknown"
	):
		GameState.set_flag("elena_arrived")
		GameState.set_visitor(ELENA)
		return
	# Nobody answered: she leaves, and the campaign goes on without her.
	if (
		GameState.visitor == ELENA
		and minutes >= ELENA_GIVES_UP_MINUTE
		and not _dialogue.is_active()
	):
		GameState.remove_npc(ELENA, "left")
		GameState.set_flag("elena_left_unanswered")
		GameState.set_visitor("")
		EventBus.notice_requested.emit(tr("HUD_KNOCKING_STOPPED"))


func _on_front_door_used() -> void:
	if _dialogue.is_active():
		return
	if GameState.visitor == ELENA:
		_dialogue.start("elena_arrival")


## Ends the day. The first night is quiet by design (GDD: Day 1). Returns the
## morning narration.
func _resolve_night() -> String:
	GameState.start_next_day()
	SaveManager.save_game()

	var text: String
	if GameState.day == 2:
		var elena_here: bool = GameState.get_status(ELENA) == "resident"
		text = tr("NARR_MORNING_D2_ELENA") if elena_here else tr("NARR_MORNING_D2_ALONE")
	else:
		text = tr("NARR_MORNING_GENERIC").format({"day": GameState.day})
	# Nothing is authored past the first morning yet.
	return text + "\n\n" + tr("NARR_END_OF_BUILD")
