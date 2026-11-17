extends Node
## ROOM-COMPACT-001: rooms merged in the compact plan (dining -> kitchen,
## pantry -> utility, bathroom_ground -> bathroom_upper). Old saves and old
## ids keep working, nothing is lost, and the seed and infection are untouched.
## Run only through tools/Run-Tests.ps1.

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	_test_alias_table()
	_test_old_save()
	await _test_room_view()
	if failures == 0:
		print("ROOM COMPACT TEST: PASS (%d checks)" % checks)
	else:
		print("ROOM COMPACT TEST: FAILED %d of %d checks" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)


func _test_alias_table() -> void:
	check(RoomAliases.canonical("dining") == "kitchen", "dining is now the kitchen")
	check(RoomAliases.canonical("pantry") == "utility", "pantry is now the service room")
	check(RoomAliases.canonical(&"bathroom_ground") == "bathroom_upper", "one bathroom")
	check(RoomAliases.canonical("guest_a") == "guest_a" and RoomAliases.canonical("") == "", "other ids unchanged")
	check(RoomAliases.canonical_list(["pantry", "utility", "dining"]) == ["utility", "kitchen"], "lists map and drop duplicates")
	for alias: String in RoomAliases.ALIASES:
		var target: String = RoomAliases.ALIASES[alias]
		check(not RoomAliases.ALIASES.has(target), "alias %s points at a real room, not another alias" % alias)
		check(not HouseLayout.get_room(StringName(target)).is_empty(), "alias target %s exists in the house" % target)
	for bed_id: String in GameState.BEDS:
		check(not RoomAliases.ALIASES.has(GameState.bed_room(bed_id)), "bed %s is not in a merged room" % bed_id)


## A save written before the merge: a job in the pantry, a blocked room list,
## evidence and a night record naming merged rooms.
func _test_old_save() -> void:
	GameState.new_campaign(4242)
	GameState.day = 4
	GameState.minutes = 9 * 60
	GameState.admit("marcus_hale", "guest_a_1")
	GameState.admit("elena_ward", "guest_b_1")
	var old: Dictionary = GameState.to_dict()
	old["jobs"] = {"marcus_hale": {"job": "inventory", "day": 4, "start": 8 * 60, "end": 10 * 60, "room": "pantry"}}
	old["npcs"]["elena_ward"]["blocked_rooms"] = ["pantry", "bathroom_ground", "utility"]
	old["evidence"] = [{"id": "e1", "room": "dining", "day": 3}]
	old["flags"]["night_witness_record"] = {"steps": [{"room": "bathroom_ground", "minute": 10}]}
	var seed_before: int = int(old["campaign_seed"])
	var infection_before: Dictionary = {}
	for id: String in old["npcs"]:
		infection_before[id] = old["npcs"][id]["infected"]
	var untouched: Dictionary = old.duplicate(true)

	GameState.from_dict(JSON.parse_string(JSON.stringify(old)), false)
	check(old == untouched, "loading never edits the caller's dictionary")
	check(GameState.jobs["marcus_hale"]["room"] == "utility", "old pantry job now runs in the service room")
	check(GameState.jobs["marcus_hale"]["job"] == "inventory" and GameState.jobs["marcus_hale"]["end"] == 10 * 60, "the job itself is unchanged")
	check(GameState.get_location("marcus_hale") == "utility", "worker is found in the service room")
	check(GameState.get_room_occupants("utility") == ["marcus_hale"], "service room lists the worker")
	check(GameState.get_room_occupants("pantry") == ["marcus_hale"], "asking by the old id finds the same worker")
	check(GameState.npcs["elena_ward"]["blocked_rooms"] == ["utility", "bathroom_upper"], "blocked rooms mapped without duplicates")
	check(GameState.evidence[0]["room"] == "kitchen" and GameState.evidence[0]["id"] == "e1", "evidence kept, room mapped")
	check(GameState.flags["night_witness_record"]["steps"][0]["room"] == "bathroom_upper", "night record kept, room mapped")
	check(GameState.campaign_seed == seed_before, "seed unchanged")
	var same_infection: bool = true
	for id: String in infection_before:
		same_infection = same_infection and GameState.npcs[id]["infected"] == infection_before[id]
	check(same_infection, "infection unchanged")
	check(GameState.npcs["marcus_hale"]["room"] == "guest_a" and GameState.beds.size() == untouched["beds"].size(), "beds unchanged")
	check(GameState.resources == _ints(untouched["resources"]), "supplies unchanged")

	# A second save/load round trip is stable and holds no old ids.
	var saved: Dictionary = GameState.to_dict()
	var text: String = JSON.stringify(saved)
	for alias: String in RoomAliases.ALIASES:
		check(not text.contains("\"%s\"" % alias), "re-saved state holds no '%s'" % alias)
	GameState.from_dict(JSON.parse_string(text), false)
	check(GameState.to_dict() == saved, "migrated state round-trips unchanged")


func _test_entry_points(director: CampaignDirector) -> void:
	check(_job_room("inventory") == "utility", "inventory job data lives in the service room")
	var ids: Array[String] = []
	for action: Dictionary in director.get_room_actions("utility"):
		ids.append(action["id"])
	check(ids.has("check_supplies"), "supply check moved with the pantry into the service room")
	var old_ids: Array[String] = []
	for action: Dictionary in director.get_room_actions("pantry"):
		old_ids.append(action["id"])
	check(old_ids == ids, "old pantry id offers exactly the service room's actions")
	check(director.perform_room_action("pantry", "check_supplies") != "", "supply check still works when called by the old id")


func _test_room_view() -> void:
	GameState.new_campaign(4242)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	await get_tree().process_frame
	var room: RoomView = scene.get_node("RoomView")
	_test_entry_points(scene.get_node("CampaignDirector"))
	for alias: String in RoomAliases.ALIASES:
		room.open(StringName(alias))
		check(room.is_open() and room.get_room_id() == StringName(RoomAliases.ALIASES[alias]), "opening '%s' shows %s" % [alias, RoomAliases.ALIASES[alias]])
		room.close()
	var world := RoomWorld.new()
	add_child(world)
	var shown: Dictionary = world.show_room(&"pantry", GameState.minutes, true, false)
	var direct: Dictionary = RoomVisuals.new().resolve("utility", GameState.minutes, true)
	check(shown.get("path", "") == direct["path"], "room art for an old id is the merged room's art")
	world.queue_free()
	scene.queue_free()
	await get_tree().process_frame


func _job_room(job_id: String) -> String:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://resources/jobs/jobs.json"))
	for job: Dictionary in data["jobs"]:
		if job["id"] == job_id:
			return str(job["room"])
	return ""


func _ints(values: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for key: String in values:
		result[key] = int(values[key])
	return result
