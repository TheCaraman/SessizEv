extends Node
## Headless test for Day 2: Marcus's and Arthur's visits, beds, the radio
## report, supplies, and the version 2 save (docs/Day2Design.md, section 11).
##
## Run with:
##   godot --headless --path . res://tests/day2_test.tscn
## Exit code 0 means every check passed.
##
## Covered acceptance items:
##    1-2  All 27 combinations of Elena / Marcus / Arthur being admitted,
##         turned away or never answered reach Day 3 in a valid state.
##    3    Infection never changes through play, bed choice or loading.
##    4    Resting across a visit's start stops at the knock; an unanswered
##         visitor leaves exactly once.
##    5    Loading does not duplicate a visitor or bring one back.
##    6    One person per bed; a full house refuses with an explanation.
##   10    Supplies on Day 3 match the head count; shortage is reported.
##   11    With nobody in the house the day still completes; missing the
##         radio report does not lock it away.
##   12    A version 1 save migrates without changing infection, trust, the
##         clock or any decision; a version 2 save round-trips unchanged.
## Not covered here (later task DAY2-003, or manual): items 7-9 (management
## screen and jobs) and 13-14 (layout at 1080p/1440p, hands-on play).

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const MODES: Array[String] = ["admit", "reject", "miss"]
const TEST_SLOT: String = "day2_test_slot"

var _scene: Node
var _director: CampaignDirector
var _dialogue: DialogueRunner
var _room_view: RoomView
var _frame: int = 0
var _failures: PackedStringArray = []
var _checks: int = 0


func _ready() -> void:
	TranslationServer.set_locale("en")
	_start_campaign(1)
	_scene = SCENE.instantiate()
	add_child(_scene)
	_director = _scene.get_node("CampaignDirector") as CampaignDirector
	_dialogue = _scene.get_node("DialogueRunner") as DialogueRunner
	_room_view = _scene.get_node("RoomView") as RoomView


func _physics_process(_delta: float) -> void:
	_frame += 1
	if _frame == 5:
		_check_all_combinations()
		_check_interrupt_and_warning()
		_check_waiting_keeps_visitor()
		_check_full_house()
		_check_bed_rules()
		_check_loading_during_visit()
		_check_radio()
		_check_shortage_is_reported()
		_check_version_1_migration()
		SaveManager.delete_save(TEST_SLOT)
		SaveManager.delete_save()
		_finish()


# --- Helpers ----------------------------------------------------------------

func _go_to(minute_of_day: int) -> void:
	if GameState.minutes < minute_of_day:
		GameState.advance_minutes(minute_of_day - GameState.minutes)


func _sleep() -> void:
	_go_to(20 * 60)
	_room_view.open(&"daniel_bedroom")
	_room_view.perform_action("sleep")
	_room_view.close()


func _finish_dialogue() -> void:
	var guard: int = 0
	while _dialogue.is_active() and guard < 20:
		_dialogue.choose(0)
		guard += 1


## Opens the door to whoever is waiting and reaches the list of replies.
func _answer_door() -> void:
	EventBus.front_door_used.emit()
	_dialogue.choose(0)
	_dialogue.choose(0)


## Deals with the visitor at the door in the given way.
func _handle_visitor(mode: String, end_minute: int) -> void:
	match mode:
		"admit":
			_answer_door()
			if GameState.visitor == "elena_ward":
				_dialogue.choose_by_id("admit")
			else:
				_dialogue.choose_by_id("admit")
				var choices: Array = _dialogue.get_current()["choices"]
				_dialogue.choose_by_id(choices[0]["id"])
			_finish_dialogue()
		"reject":
			_answer_door()
			_dialogue.choose_by_id("reject")
			if _dialogue.is_active() and _dialogue.get_node_id() == "reject_confirm":
				_dialogue.choose_by_id("confirm")
			_finish_dialogue()
		"miss":
			_go_to(end_minute)


func _expected_status(mode: String) -> String:
	return {"admit": "resident", "reject": "rejected", "miss": "left"}[mode]


func _infection_map() -> Dictionary:
	var map: Dictionary = {}
	for id: String in GameState.npcs:
		map[id] = GameState.npcs[id]["infected"]
	return map


# --- Items 1, 2, 3, 6, 10, 11, 12 -------------------------------------------

func _check_all_combinations() -> void:
	var campaign_seed: int = 100
	for elena: String in MODES:
		for marcus: String in MODES:
			for arthur: String in MODES:
				campaign_seed += 1
				_run_combination(campaign_seed, elena, marcus, arthur)


func _run_combination(campaign_seed: int, elena: String, marcus: String, arthur: String) -> void:
	var label: String = "[elena %s, marcus %s, arthur %s]" % [elena, marcus, arthur]
	_start_campaign(campaign_seed)
	var infected: Dictionary = _infection_map()

	# Day 1.
	_go_to(18 * 60 + 5)
	_check(GameState.visitor == "elena_ward", "%s Elena should knock on Day 1" % label)
	_handle_visitor(elena, 21 * 60 + 30)
	_check(GameState.get_status("elena_ward") == _expected_status(elena), "%s Elena's status" % label)
	_sleep()
	_check(GameState.day == 2, "%s should reach Day 2" % label)
	_check(GameState.visitor == "", "%s nobody should be at the door at dawn" % label)

	# Day 2: Marcus in the morning.
	_go_to(9 * 60 + 59)
	_check(GameState.visitor == "", "%s Marcus should not knock before 10:00" % label)
	_go_to(10 * 60)
	_check(GameState.visitor == "marcus_hale", "%s Marcus should knock at 10:00" % label)
	_handle_visitor(marcus, 13 * 60)
	_check(GameState.get_status("marcus_hale") == _expected_status(marcus), "%s Marcus's status" % label)
	_check(GameState.visitor == "", "%s the step should be empty after Marcus" % label)

	# Arthur in the afternoon.
	_go_to(15 * 60)
	_check(GameState.visitor == "arthur_bell", "%s Arthur should knock at 15:00" % label)
	_handle_visitor(arthur, 18 * 60)
	_check(GameState.get_status("arthur_bell") == _expected_status(arthur), "%s Arthur's status" % label)

	# Nobody comes twice.
	_go_to(19 * 60 + 30)
	_check(GameState.visitor == "", "%s nobody should knock again in the evening" % label)

	# Beds: one each, in a real bed, room matching.
	var residents: Array[String] = GameState.get_residents()
	var expected_residents: int = [elena, marcus, arthur].count("admit")
	_check(residents.size() == expected_residents, "%s resident count" % label)
	_check(GameState.beds.size() == expected_residents, "%s one bed per resident" % label)
	for id: String in residents:
		var bed_id: String = GameState.get_bed_of(id)
		_check(GameState.BEDS.has(bed_id), "%s %s should have a real bed" % [label, id])
		_check(GameState.npcs[id]["room"] == GameState.bed_room(bed_id), "%s %s room should match bed" % [label, id])
	if elena == "admit":
		_check(GameState.get_bed_of("elena_ward") == "guest_a_1", "%s Elena should keep her Day 1 bed" % label)

	# Supplies after two nights.
	var first_night: int = 1 + (1 if elena == "admit" else 0)
	var second_night: int = 1 + expected_residents
	var save_before_sleep: String = JSON.stringify(GameState.to_dict())
	_sleep()
	_check(GameState.day == 3 and GameState.minutes == GameState.DAY_START, "%s should reach Day 3, 07:00" % label)
	_check(
		GameState.resources["food"] == 12 - first_night - second_night,
		"%s food on Day 3 (got %d)" % [label, GameState.resources["food"]]
	)
	_check(
		GameState.resources["water"] == 14 - first_night - second_night,
		"%s water on Day 3 (got %d)" % [label, GameState.resources["water"]]
	)
	_check(save_before_sleep != JSON.stringify(GameState.to_dict()), "%s the night should change the state" % label)

	# Infection is untouched by everything above, and by saving and loading.
	_check(_infection_map() == infected, "%s infection must not change through play" % label)
	var saved: String = JSON.stringify(GameState.to_dict())
	_check(SaveManager.save_game(TEST_SLOT) == OK, "%s saving should work" % label)
	_start_campaign(999999)
	_check(SaveManager.load_game(TEST_SLOT), "%s loading should work" % label)
	_check(JSON.stringify(GameState.to_dict()) == saved, "%s a version 2 save should round-trip unchanged" % label)
	_check(_infection_map() == infected, "%s infection must not change through loading" % label)


# --- Item 4 -----------------------------------------------------------------

func _check_interrupt_and_warning() -> void:
	_start_campaign(31)
	_go_to(18 * 60 + 5)
	_handle_visitor("reject", 0)
	_sleep()

	# Resting from 09:40 stops at Marcus's knock at 10:00.
	_go_to(9 * 60 + 40)
	_room_view.open(&"daniel_bedroom")
	_room_view.perform_action("rest")
	_check(GameState.minutes == 10 * 60, "rest from 09:40 should stop at 10:00, got %s" % GameState.get_clock_text())
	_check(GameState.visitor == "marcus_hale", "Marcus should be at the door when the rest is cut short")
	_check(_room_view.get_narration_text().contains("knock"), "the interruption should be explained")

	# With him waiting, an action that would outlast him warns first and costs nothing.
	_go_to(12 * 60 + 30)
	_room_view.perform_action("rest")
	_check(GameState.minutes == 12 * 60 + 30, "the warning must not spend time")
	_check(_room_view.get_narration_text().contains("Marcus Hale"), "the warning should name who is waiting")
	_check(GameState.visitor == "marcus_hale", "he should still be there after the warning")
	# Choosing it again goes ahead; he gives up at 13:00 and is gone for good.
	_room_view.perform_action("rest")
	_check(GameState.minutes == 13 * 60 + 30, "the second press should spend the hour")
	_check(GameState.get_status("marcus_hale") == "left", "Marcus should have left, not been rejected")
	_check(GameState.visitor == "", "the step should be empty")
	_room_view.close()
	_go_to(14 * 60 + 59)
	_check(GameState.visitor == "", "Marcus should not return the same day")
	_check(GameState.get_status("marcus_hale") == "left", "Marcus stays 'left'")


func _check_waiting_keeps_visitor() -> void:
	_start_campaign(32)
	_go_to(18 * 60 + 5)
	_handle_visitor("miss", 21 * 60 + 30)
	_sleep()
	_go_to(10 * 60)
	_answer_door()
	_dialogue.choose_by_id("origin")
	_dialogue.choose(0)
	_check(_dialogue.choose_by_id("wait"), "closing the door for a moment should be possible")
	_finish_dialogue()
	_check(GameState.visitor == "marcus_hale", "closing the conversation must not turn him away")
	_check(GameState.get_status("marcus_hale") == "unknown", "he is neither admitted nor rejected yet")
	# Coming back: the question already asked is gone, the rest remain.
	_answer_door()
	_check(not _dialogue.choose_by_id("origin"), "an asked question should not be offered again")
	_check(_dialogue.choose_by_id("reject"), "rejecting should lead to a confirmation")
	_check(_dialogue.get_node_id() == "reject_confirm", "rejection needs confirming")
	_check(_dialogue.choose_by_id("back"), "the confirmation can be cancelled")
	_check(GameState.get_status("marcus_hale") == "unknown", "cancelling must change nothing")
	_dialogue.choose_by_id("admit")
	_check(_dialogue.get_node_id() == "beds", "admitting should ask for a bed")
	_check(_dialogue.choose_by_id("back"), "the bed choice can be cancelled")
	_check(GameState.get_status("marcus_hale") == "unknown", "cancelling the bed choice admits nobody")
	_dialogue.choose_by_id("wait")
	_finish_dialogue()


# --- Item 6 -----------------------------------------------------------------

func _check_full_house() -> void:
	_start_campaign(33)
	_go_to(18 * 60 + 5)
	_handle_visitor("admit", 0)
	_sleep()
	# Fill the remaining five beds with characters who arrive later in the story.
	var fillers: Array[String] = ["noah_reed", "maya_collins", "grace_miller", "victor_shaw", "sophie_lane"]
	var free: Array[String] = GameState.get_free_beds()
	for i: int in fillers.size():
		_check(GameState.admit(fillers[i], free[i]), "filler %d should get a bed" % i)
	_check(GameState.get_free_beds().is_empty(), "the house should be full")

	_go_to(10 * 60)
	_answer_door()
	_check(_dialogue.choose_by_id("admit"), "the admit reply stays visible when the house is full")
	_check(_dialogue.get_node_id() == "no_room", "a full house should be explained, got '%s'" % _dialogue.get_node_id())
	_check(GameState.get_status("marcus_hale") == "unknown", "nobody is admitted without a bed")
	_dialogue.choose(0)
	_check(_dialogue.get_node_id() == "hub", "after the explanation the choices return")
	_dialogue.choose_by_id("wait")
	_finish_dialogue()
	_check(GameState.get_residents().size() == 6, "nobody was quietly removed to make room")


func _check_bed_rules() -> void:
	_start_campaign(34)
	_check(GameState.admit("elena_ward", "guest_a_1"), "a free bed can be given")
	_check(not GameState.admit("marcus_hale", "guest_a_1"), "an occupied bed cannot be given again")
	_check(GameState.get_status("marcus_hale") == "unknown", "a refused admission changes nothing")
	_check(not GameState.admit("marcus_hale", "isolation_1"), "the box room is not a normal bed")
	_check(not GameState.admit("nobody_at_all", "guest_b_1"), "an unknown character cannot be admitted")
	_check(GameState.admit("marcus_hale", "guest_a_2"), "the second bed of a room can be given")
	_check(GameState.get_room_occupants("guest_a").size() == 2, "two people now share the middle bedroom")
	GameState.remove_npc("elena_ward", "expelled")
	_check(not GameState.beds.has("guest_a_1"), "leaving frees the bed")
	_check(GameState.get_bed_of("elena_ward") == "", "someone who left has no bed")
	_check(GameState.get_free_beds().size() == 5, "five beds free again")


# --- Item 5 -----------------------------------------------------------------

func _check_loading_during_visit() -> void:
	_start_campaign(35)
	_go_to(18 * 60 + 5)
	_handle_visitor("reject", 0)
	_sleep()
	_go_to(10 * 60 + 20)
	_check(GameState.visitor == "marcus_hale", "Marcus should be waiting")
	_check(SaveManager.save_game(TEST_SLOT) == OK, "saving with a visitor waiting should work")
	var saved: String = JSON.stringify(GameState.to_dict())

	_start_campaign(36)
	_check(SaveManager.load_game(TEST_SLOT), "loading should work")
	_check(JSON.stringify(GameState.to_dict()) == saved, "the waiting visitor should be restored exactly")
	_check(GameState.visitor == "marcus_hale" and GameState.visitor_arrival == "d2_marcus", "same person, same visit")
	_check(GameState.resolved_arrivals.count("d2_marcus") == 1, "the visit is recorded once, not twice")
	# He still gives up at the same time as before.
	_go_to(12 * 60 + 59)
	_check(GameState.visitor == "marcus_hale", "he should still be waiting at 12:59")
	_go_to(13 * 60)
	_check(GameState.get_status("marcus_hale") == "left", "he should leave at 13:00 as before the load")

	# Loading the earlier save again must not let a later knock duplicate him.
	SaveManager.load_game(TEST_SLOT)
	_handle_visitor("reject", 0)
	_check(GameState.get_status("marcus_hale") == "rejected", "rejected after the reload")
	SaveManager.save_game(TEST_SLOT)
	SaveManager.load_game(TEST_SLOT)
	_go_to(12 * 60)
	_check(GameState.visitor == "", "a rejected visitor does not reappear after loading")
	# Rejected Elena from Day 1 is not brought back either.
	_check(GameState.get_status("elena_ward") == "rejected", "Elena stays rejected across loads")


# --- Item 11 ----------------------------------------------------------------

func _check_radio() -> void:
	_start_campaign(37)
	_go_to(18 * 60 + 5)
	_handle_visitor("miss", 21 * 60 + 30)
	_sleep()
	_check(not GameState.get_flag("heard_memory_loss_report"), "nothing heard yet on Day 2")
	_room_view.open(&"living_room")
	_room_view.perform_action("radio")
	_check(_room_view.get_narration_text().contains("unverified"), "Day 2 radio should carry the report")
	_check(GameState.get_flag("heard_memory_loss_report"), "hearing it should be recorded")
	_check(GameState.minutes == 7 * 60 + 15, "the first listen takes 15 minutes")
	_room_view.perform_action("radio")
	_check(not _room_view.get_narration_text().contains("unverified"), "a second listen does not repeat it")
	_room_view.close()

	# Missing it on Day 2 does not lock it away: it can be heard on Day 3.
	_start_campaign(38)
	_go_to(18 * 60 + 5)
	_handle_visitor("miss", 21 * 60 + 30)
	_sleep()
	_sleep()
	_check(GameState.day == 3, "should be Day 3 with nobody in the house")
	_check(GameState.get_residents().is_empty(), "an empty house is a valid campaign")
	_check(not GameState.get_flag("heard_memory_loss_report"), "the report was missed on Day 2")
	_room_view.open(&"living_room")
	_room_view.perform_action("radio")
	_check(_room_view.get_narration_text().contains("unverified"), "the report should still be available on Day 3")
	_room_view.close()


# --- Item 10 ----------------------------------------------------------------

func _check_shortage_is_reported() -> void:
	_start_campaign(39)
	GameState.admit("elena_ward", "guest_a_1")
	GameState.admit("marcus_hale", "guest_a_2")
	GameState.resources["food"] = 5
	GameState.resources["water"] = 9
	_room_view.open(&"pantry")
	_room_view.perform_action("check_supplies")
	var text: String = _room_view.get_narration_text()
	_check(text.contains("3 people"), "the supply count should give tonight's head count, got '%s'" % text)
	_check(text.contains("tomorrow"), "a shortage one day ahead should be warned about")
	_room_view.close()

	GameState.resources["food"] = 2
	_sleep()
	_check(GameState.resources["food"] == 0, "food cannot go below zero")
	_check(GameState.get_flag("shortage_food_day_2", 0) == 1, "the shortfall of one should be recorded")
	_check(not GameState.get_flag("shortage_water_day_2", 0), "water was sufficient")
	_room_view.open(&"daniel_bedroom")
	_room_view.close()


# --- Item 12 ----------------------------------------------------------------

func _check_version_1_migration() -> void:
	# A version 1 save as written before beds and visit records existed:
	# Elena admitted on Day 1, now the morning of Day 2.
	_start_campaign(40)
	var infected: Dictionary = _infection_map()
	var old_npcs: Dictionary = GameState.npcs.duplicate(true)
	old_npcs["elena_ward"]["status"] = "resident"
	old_npcs["elena_ward"]["room"] = "guest_a"
	old_npcs["elena_ward"]["trust"] = 18
	var version_1: Dictionary = {
		"campaign_seed": 40, "day": 2, "minutes": 435,
		"flags": {"elena_arrived": true, "elena_admitted": true, "tv_day_1": true},
		"resources": {"food": 10, "water": 12, "medical": 2, "repair": 3, "fuel": 4},
		"player": {"energy": 100, "stress": 10, "infection": "healthy"},
		"npcs": old_npcs,
		"visitor": "",
	}
	var through_json: Dictionary = JSON.parse_string(JSON.stringify(version_1))
	_start_campaign(41)
	GameState.from_dict(through_json)

	_check(GameState.day == 2 and GameState.minutes == 435, "migration keeps the day and time")
	_check(GameState.campaign_seed == 40, "migration keeps the seed")
	_check(_infection_map() == infected, "migration must not change who is infected")
	_check(GameState.npcs["elena_ward"]["trust"] == 18, "migration keeps trust")
	_check(GameState.get_status("elena_ward") == "resident", "migration keeps residents")
	_check(GameState.get_bed_of("elena_ward") == "guest_a_1", "Elena gets the first bed of her old room")
	_check(GameState.resolved_arrivals.has("d1_elena"), "Elena's visit is marked as already done")
	_check(GameState.get_flag("elena_admitted") == true, "migration keeps decisions")
	_check(GameState.resources["food"] == 10, "migration keeps supplies")

	# Migrating is repeatable, and the migrated campaign plays on normally.
	var once: String = JSON.stringify(GameState.to_dict())
	GameState.from_dict(JSON.parse_string(once))
	_check(JSON.stringify(GameState.to_dict()) == once, "a migrated save round-trips unchanged")
	_go_to(10 * 60)
	_check(GameState.visitor == "marcus_hale", "Marcus should arrive in a migrated campaign")
	_check(GameState.get_status("elena_ward") == "resident", "Elena is not asked to arrive again")


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _finish() -> void:
	if _failures.is_empty():
		print("DAY 2 TEST: PASS (%d checks)" % _checks)
		get_tree().quit(0)
	else:
		for failure: String in _failures:
			printerr("FAIL: " + failure)
		print("DAY 2 TEST: FAIL (%d of %d)" % [_failures.size(), _checks])
		get_tree().quit(1)


## This suite checks docs/Day2Design.md's fixed visits (Marcus 10:00, Arthur
## 15:00), so every campaign here uses that timetable instead of the seed's
## random one (ARRIVALS-001). Random timetables are covered by
## arrival_scheduler_test and arrival_integration_test.
func _start_campaign(seed_value: int) -> void:
	GameState.new_campaign(seed_value)
	GameState.arrival_schedule = ArrivalScheduler.legacy_schedule()
	GameState.arrival_schedule_version = 0
