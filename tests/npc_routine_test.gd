extends Node
## IMMERSION I-06 technical skeleton: NpcRoutine activity/pose on top of the
## single location model, and RoomWorld figures that fade instead of popping.
## Run only through tools/Run-Tests.ps1.

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	_test_routine()
	_test_consistency()
	await _test_room_world()
	if failures == 0:
		print("NPC ROUTINE TEST: PASS (%d checks)" % checks)
	else:
		print("NPC ROUTINE TEST: FAILED %d of %d checks" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)


func _at(minute: int) -> void:
	GameState.minutes = minute


func _test_routine() -> void:
	GameState.new_campaign(606)
	check(NpcRoutine.state("elena_ward").is_empty() and NpcRoutine.pose("elena_ward") == &"", "nobody outside the house has a routine")
	check(GameState.admit("elena_ward", "guest_a_1"), "Elena admitted")
	var table: Dictionary = NpcRoutine.rules()
	for activity: String in ["isolated", "work", "watch", "sleep", "morning", "afternoon", "evening", "night"]:
		check(table["poses"].has(activity), "pose authored for " + activity)
	_at(8 * 60)
	var s: Dictionary = NpcRoutine.state("elena_ward")
	check(s["room"] == "guest_a" and s["activity"] == "morning" and s["pose"] == StringName(table["poses"]["morning"]), "morning in her bedroom")
	_at(13 * 60)
	check(NpcRoutine.state("elena_ward")["activity"] == "afternoon", "afternoon activity")
	_at(19 * 60)
	check(NpcRoutine.state("elena_ward")["activity"] == "evening", "evening activity")
	_at(23 * 60 + 30)
	s = NpcRoutine.state("elena_ward")
	check(s["room"] == "guest_a" and s["activity"] == "sleep" and s["pose"] == &"lie", "asleep in her own bed at night")
	_at(24 * 60 + 90)
	check(NpcRoutine.state("elena_ward")["activity"] == "sleep", "still asleep after midnight")

	GameState.jobs["elena_ward"] = {"job": "cooking", "day": GameState.day, "start": 9 * 60, "end": 10 * 60, "room": "kitchen"}
	_at(9 * 60 + 30)
	s = NpcRoutine.state("elena_ward")
	check(s["room"] == "kitchen" and s["activity"] == "work" and s["pose"] == &"work", "working in the kitchen")
	_at(10 * 60)
	check(NpcRoutine.state("elena_ward")["room"] == "guest_a" and NpcRoutine.state("elena_ward")["activity"] == "morning", "back in her room when the job ends")
	GameState.jobs["elena_ward"]["day"] = GameState.day + 1
	_at(9 * 60 + 30)
	check(NpcRoutine.state("elena_ward")["activity"] == "morning", "tomorrow's job does not apply today")

	GameState.jobs["elena_ward"] = {"job": "night_watch", "day": GameState.day, "start": 0, "end": 0, "room": ""}
	_at(22 * 60)
	check(NpcRoutine.state("elena_ward")["activity"] == "evening", "night watch has not started before 23:00")
	_at(23 * 60 + 10)
	s = NpcRoutine.state("elena_ward")
	check(s["room"] == "guest_a" and s["activity"] == "watch" and s["pose"] == &"sit", "awake on night watch, not lying down")

	GameState.jobs["elena_ward"] = {"job": "cooking", "day": GameState.day, "start": 9 * 60, "end": 10 * 60, "room": "kitchen"}
	GameState.npcs["elena_ward"]["isolated"] = true
	_at(9 * 60 + 30)
	s = NpcRoutine.state("elena_ward")
	check(s["room"] == "isolation" and s["activity"] == "isolated", "isolation beats a job")
	GameState.npcs["elena_ward"]["isolated"] = false

	var infected: bool = GameState.npcs["elena_ward"]["infected"]
	var before: Dictionary = NpcRoutine.state("elena_ward")
	GameState.npcs["elena_ward"]["infected"] = not infected
	check(NpcRoutine.state("elena_ward") == before, "infection never changes what is shown")
	GameState.npcs["elena_ward"]["infected"] = infected

	GameState.npcs["elena_ward"]["status"] = "expelled"
	check(NpcRoutine.state("elena_ward").is_empty(), "an expelled resident has no routine")
	GameState.npcs["elena_ward"]["status"] = "resident"


## Over a whole day with jobs and isolation mixed in: the routine room is
## always the central location, every resident is in exactly one room, and
## asking never changes state.
func _test_consistency() -> void:
	GameState.new_campaign(707)
	GameState.admit("elena_ward", "guest_a_1")
	GameState.admit("marcus_hale", "guest_b_1")
	GameState.admit("arthur_bell", "multipurpose_1")
	GameState.jobs["marcus_hale"] = {"job": "inventory", "day": GameState.day, "start": 600, "end": 660, "room": "utility"}
	GameState.jobs["arthur_bell"] = {"job": "night_watch", "day": GameState.day, "start": 0, "end": 0, "room": ""}
	GameState.npcs["elena_ward"]["isolated"] = true
	var rooms: Array[String] = []
	for room: Dictionary in HouseLayout.ROOMS:
		rooms.append(str(room["id"]))
	var ok_location: bool = true
	var ok_single: bool = true
	for minute: int in range(GameState.DAY_START, 26 * 60, 15):
		_at(minute)
		var seen: Dictionary = {}
		for room: String in rooms:
			for id: String in GameState.get_room_occupants(room):
				seen[id] = int(seen.get(id, 0)) + 1
		for id: String in GameState.get_residents():
			ok_location = ok_location and NpcRoutine.state(id)["room"] == GameState.get_location(id)
			ok_single = ok_single and int(seen.get(id, 0)) == 1
	check(ok_location, "routine room is always the central location")
	check(ok_single, "every resident is in exactly one room at every quarter hour")
	var snapshot: Dictionary = GameState.to_dict()
	for id: String in GameState.get_residents():
		NpcRoutine.state(id)
	check(GameState.to_dict() == snapshot, "asking for routines changes nothing")


func _test_room_world() -> void:
	GameState.new_campaign(808)
	GameState.admit("elena_ward", "guest_a_1")
	_at(8 * 60)
	var world := RoomWorld.new()
	world.size = Vector2(1280, 720)
	add_child(world)
	world.show_room(&"guest_a", GameState.minutes, true, false)
	check(world.resident_ids == ["elena_ward"] and world.characters.get_child_count() == 1, "resident drawn once")
	var first: Control = world.characters.get_child(0)
	check(first.get_meta(&"pose") == &"stand" and is_equal_approx(first.modulate.a, 1.0), "first view shows the morning pose at once")
	world.show_room(&"guest_a", GameState.minutes, true, false)
	check(world.characters.get_child(0) == first and world.departing.get_child_count() == 0, "redrawing the same moment changes nothing")

	_at(23 * 60 + 30)
	world.show_room(&"guest_a", GameState.minutes, true, false)
	var lying: Control = world.characters.get_child(0)
	check(world.characters.get_child_count() == 1 and lying != first and lying.get_meta(&"pose") == &"lie", "pose changes to lying at night")
	check(lying.modulate.a < 0.5 and world.departing.get_child_count() == 1, "new pose fades in while the old one fades out")
	await get_tree().create_timer(RoomWorld.FIGURE_FADE_SECONDS + 0.15).timeout
	check(is_equal_approx(lying.modulate.a, 1.0) and world.departing.get_child_count() == 0, "crossfade finishes and the old figure is gone")

	GameState.jobs["elena_ward"] = {"job": "cooking", "day": GameState.day, "start": 23 * 60, "end": 24 * 60, "room": "kitchen"}
	world.show_room(&"guest_a", GameState.minutes, true, false)
	check(world.resident_ids.is_empty() and world.characters.get_child_count() == 0, "a resident who leaves is no longer present at once")
	check(world.departing.get_child_count() == 1, "but fades out where she stood instead of vanishing")
	await get_tree().create_timer(RoomWorld.FIGURE_FADE_SECONDS + 0.15).timeout
	check(world.departing.get_child_count() == 0, "departure fade cleans up")

	world.show_room(&"kitchen", GameState.minutes, true, false)
	check(world.resident_ids == ["elena_ward"] and is_equal_approx(world.characters.get_child(0).modulate.a, 1.0), "a newly opened room shows its people at once")
	check(world.characters.get_child(0).get_meta(&"pose") == &"work", "working pose in the kitchen")
	check(CharacterArt.texture_path("elena_ward", &"lie") == CharacterArt.texture_path("elena_ward", &"room"), "missing pose art falls back to the room drawing")
	world.queue_free()
	await get_tree().process_frame
