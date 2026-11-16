extends Node
## Headless test for the campaign systems and the Day 1 flow.
##
## Run with:
##   godot --headless --path . res://tests/campaign_test.tscn
## Exit code 0 means every check passed.
##
## Checks:
##   1. Infection assignment obeys its rules for 500 seeds and is repeatable.
##   2. The clock, phases and the evening knock work.
##   3. Admitting Elena: conversation, questions asked once, resident, room.
##   4. Sleeping: only when allowed, moves to Day 2, uses supplies, autosaves.
##   5. A save survives a round trip unchanged.
##   6. Rejecting Elena and ignoring the door both leave a valid campaign.

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const TEST_SLOT: String = "test_slot"

var _scene: Node
var _director: CampaignDirector
var _dialogue: DialogueRunner
var _room_view: RoomView
var _hud: CanvasLayer
var _frame: int = 0
var _failures: PackedStringArray = []
var _checks: int = 0


func _ready() -> void:
	TranslationServer.set_locale("en")
	_check_infection_rules()
	GameState.new_campaign(42)
	_scene = SCENE.instantiate()
	add_child(_scene)
	_director = _scene.get_node("CampaignDirector") as CampaignDirector
	_dialogue = _scene.get_node("DialogueRunner") as DialogueRunner
	_room_view = _scene.get_node("RoomView") as RoomView
	_hud = _scene.get_node("Hud") as CanvasLayer


func _physics_process(_delta: float) -> void:
	_frame += 1
	if _frame == 5:
		_check_admit_path()
		_check_save_round_trip()
		_check_reject_path()
		_check_ignored_door()
		SaveManager.delete_save(TEST_SLOT)
		_finish()


func _check_infection_rules() -> void:
	var early: Array[String] = []
	for npc: Dictionary in Roster.NPCS:
		if npc["can_be_infected"] and npc["arrival_order"] <= Roster.EARLY_ARRIVAL_LIMIT:
			early.append(npc["id"])
	var bad_count: int = 0
	var lily_infected: int = 0
	var no_early: int = 0
	var counts: Dictionary = {}
	for campaign_seed: int in 500:
		var result: Dictionary = InfectionAssigner.assign(campaign_seed)
		var count: int = 0
		var has_early: bool = false
		for id: String in result:
			if result[id]:
				count += 1
				if early.has(id):
					has_early = true
		counts[count] = true
		if count < InfectionAssigner.MIN_INFECTED or count > InfectionAssigner.MAX_INFECTED:
			bad_count += 1
		if result["lily_reed"]:
			lily_infected += 1
		if not has_early:
			no_early += 1
	_check(bad_count == 0, "infected count must be 3 to 5 (%d seeds broke it)" % bad_count)
	_check(lily_infected == 0, "Lily must never be infected (%d seeds broke it)" % lily_infected)
	_check(no_early == 0, "an early arrival must be infected (%d seeds broke it)" % no_early)
	_check(counts.size() == 3, "all of 3, 4 and 5 infected should occur, got %s" % [counts.keys()])
	_check(
		InfectionAssigner.assign(1234) == InfectionAssigner.assign(1234),
		"the same seed must give the same assignment"
	)
	_check(
		InfectionAssigner.assign(1) != InfectionAssigner.assign(2)
		or InfectionAssigner.assign(2) != InfectionAssigner.assign(3),
		"different seeds should not all give the same assignment"
	)


func _check_admit_path() -> void:
	_check(GameState.day == 1 and GameState.minutes == 7 * 60, "campaign should start on day 1 at 07:00")
	_check(GameState.get_phase() == GameState.Phase.MORNING, "07:00 is morning")
	_check(
		(_hud.call(&"get_clock_text") as String).contains("07:00"),
		"HUD clock should show 07:00, got '%s'" % _hud.call(&"get_clock_text")
	)
	_check(GameState.npcs.size() == 18, "all 18 characters should have a state")

	# Morning: the television costs time, once.
	_room_view.open(&"living_room")
	_check(_room_view.get_action_ids().has("watch_tv"), "the living room should offer the television")
	_room_view.perform_action("watch_tv")
	_check(GameState.minutes == 7 * 60 + 20, "the first broadcast should take 20 minutes")
	_check(_room_view.get_narration_text().contains("EMERGENCY"), "the broadcast text should be shown")
	_room_view.perform_action("watch_tv")
	_check(GameState.minutes == 7 * 60 + 25, "watching again should take 5 minutes")
	_room_view.close()

	# Nobody knocks before evening, and Daniel will not sleep in the morning.
	GameState.advance_minutes(17 * 60 + 55 - GameState.minutes)
	_check(GameState.visitor == "", "nobody should knock before 18:00")
	_check(not _director.can_sleep(), "sleeping should not be offered in the afternoon")
	_room_view.open(&"daniel_bedroom")
	_check(not _room_view.get_action_ids().has("sleep"), "the bedroom should not offer sleep yet")
	_room_view.perform_action("sleep")
	_check(GameState.day == 1, "an unavailable action must do nothing")
	_room_view.close()

	GameState.advance_minutes(10)
	_check(GameState.get_phase() == GameState.Phase.EVENING, "18:05 is evening")
	_check(GameState.visitor == "elena_ward", "Elena should knock in the evening")
	_check(
		(_hud.call(&"get_subtitle_text") as String).contains("knocking"),
		"the knock should be subtitled, got '%s'" % _hud.call(&"get_subtitle_text")
	)

	# Answer the door and ask everything.
	EventBus.front_door_used.emit()
	_check(_dialogue.is_active(), "answering the door should start a conversation")
	_check(not (_scene.get_node("Player") as PlayerController).control_enabled, "player should be frozen in conversation")
	_dialogue.choose(0)
	_dialogue.choose(0)
	_check(_dialogue.get_node_id() == "hub", "after the greeting the choices should appear")
	_check(_dialogue.get_current()["choices"].size() == 6, "six replies at first")
	var before: int = GameState.minutes
	for question: String in ["who", "where", "alone", "proof"]:
		_check(_dialogue.choose_by_id(question), "question '%s' should be available" % question)
		while _dialogue.is_active() and _dialogue.get_node_id() != "hub":
			_dialogue.choose(0)
	_check(GameState.minutes == before + 20, "four questions should take 20 minutes")
	_check(_dialogue.get_current()["choices"].size() == 2, "asked questions should disappear")
	_check(not _dialogue.choose_by_id("who"), "a question cannot be asked twice")

	_check(_dialogue.choose_by_id("admit"), "admitting should be possible")
	while _dialogue.is_active():
		_dialogue.choose(0)
	_check(GameState.get_status("elena_ward") == "resident", "Elena should be a resident")
	_check(GameState.npcs["elena_ward"]["room"] == "guest_a", "Elena should have the middle bedroom")
	_check(GameState.visitor == "", "nobody should be at the door afterwards")
	var residents: Array[String] = GameState.get_residents()
	_check(residents.size() == 1 and residents[0] == "elena_ward", "one resident")
	_check((_scene.get_node("Player") as PlayerController).control_enabled, "player should regain control")

	# She is in her room and can be spoken to.
	_room_view.open(&"guest_a")
	_check(_room_view.get_action_ids().has("talk:elena_ward"), "Elena's room should offer a conversation")
	_room_view.perform_action("talk:elena_ward")
	_check(_dialogue.get_dialogue_id() == "elena_resident_day1", "the resident conversation should start")
	var trust_before: int = GameState.npcs["elena_ward"]["trust"]
	_dialogue.choose_by_id("need")
	_dialogue.choose(0)
	_check(GameState.npcs["elena_ward"]["trust"] == trust_before + 3, "kindness should raise trust")
	_dialogue.choose_by_id("goodnight")
	while _dialogue.is_active():
		_dialogue.choose(0)
	_room_view.close()

	# Night.
	if GameState.minutes < 20 * 60:
		GameState.advance_minutes(20 * 60 - GameState.minutes)
	_room_view.open(&"daniel_bedroom")
	_check(_room_view.get_action_ids().has("sleep"), "sleep should be offered at night")
	SaveManager.delete_save()
	_room_view.perform_action("sleep")
	_check(GameState.day == 2 and GameState.minutes == 7 * 60, "sleeping should lead to day 2, 07:00")
	_check(GameState.resources["food"] == 10, "two people should use two food, got %d" % GameState.resources["food"])
	_check(GameState.resources["water"] == 12, "two people should use two water")
	_check(_room_view.get_narration_text().contains("Day 2"), "the morning should be narrated")
	_check(SaveManager.has_save(), "the new day should be autosaved")
	_room_view.close()


func _check_save_round_trip() -> void:
	var before: String = JSON.stringify(GameState.to_dict())
	_check(SaveManager.save_game(TEST_SLOT) == OK, "saving should succeed")
	GameState.new_campaign(999)
	_check(JSON.stringify(GameState.to_dict()) != before, "a new campaign should differ from the save")
	_check(SaveManager.load_game(TEST_SLOT), "loading should succeed")
	_check(JSON.stringify(GameState.to_dict()) == before, "a loaded save should equal what was saved")
	_check(GameState.campaign_seed == 42, "the seed should be restored exactly")
	_check(typeof(GameState.resources["food"]) == TYPE_INT, "numbers should come back as integers")
	_check(not SaveManager.load_game("no_such_slot"), "loading a missing save should fail cleanly")


func _check_reject_path() -> void:
	GameState.new_campaign(7)
	GameState.advance_minutes(11 * 60)
	_check(GameState.visitor == "elena_ward", "Elena should knock in the second campaign too")
	EventBus.front_door_used.emit()
	_dialogue.choose(0)
	_dialogue.choose(0)
	_check(_dialogue.choose_by_id("reject"), "rejecting should be possible")
	while _dialogue.is_active():
		_dialogue.choose(0)
	_check(GameState.get_status("elena_ward") == "rejected", "Elena should be recorded as rejected")
	_check(GameState.get_residents().is_empty(), "nobody should live in the house")
	_check(GameState.visitor == "", "the step should be empty")
	GameState.advance_minutes(3 * 60)
	_check(GameState.visitor == "", "a rejected visitor should not knock again")
	_room_view.open(&"daniel_bedroom")
	_room_view.perform_action("sleep")
	_check(GameState.day == 2, "the campaign should continue without her")
	_check(GameState.resources["food"] == 11, "one person should use one food")
	_check(_room_view.get_narration_text().contains("Nothing has moved"), "the lonely morning should be narrated")
	_room_view.close()


func _check_ignored_door() -> void:
	GameState.new_campaign(8)
	GameState.advance_minutes(11 * 60)
	_check(GameState.visitor == "elena_ward", "Elena should knock in the third campaign")
	_check(not _director.can_sleep(), "Daniel cannot sleep while someone is knocking")
	GameState.advance_minutes(4 * 60)
	_check(GameState.visitor == "", "an unanswered visitor should give up")
	_check(GameState.get_status("elena_ward") == "left", "she should be recorded as having left")
	_check(_director.can_sleep(), "sleep should be possible once she has gone")
	_check(GameState.minutes <= GameState.LAST_MINUTE, "the clock should stop at 23:59")


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("CAMPAIGN TEST: PASS (%d checks)" % _checks)
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		print("CAMPAIGN TEST: FAIL (%d of %d)" % [_failures.size(), _checks])
		get_tree().quit(1)
