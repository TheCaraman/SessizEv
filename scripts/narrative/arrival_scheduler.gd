class_name ArrivalScheduler
extends RefCounted
## Builds a campaign's door-visit timetable once, from the campaign seed
## (docs/design/ArrivalSchedule.md, K-NPC-ARRIVALS-ROOMS-001, K-ARRIVALS-PARAMS-001).
##
## Rules:
##   - Its own random stream (seed ^ hash(STREAM)), so infection and the power
##     incident draw exactly what they drew before.
##   - It may READ who is infected; it never changes infection.
##   - Fixed visits (the Day 1 tutorial) are placed first and never moved.
##   - A visit whose dialogue is not written yet never enters the timetable.
##   - At most max_visits_per_day per day, min_gap_minutes between visits, and
##     no visit runs past latest_end (no night arrivals).
##   - If no infected person is among the first offers but one comes later, one
##     such visit swaps slots with a random earlier one when both windows allow.
## The result is plain data meant to be stored in the save; it is never rolled
## again for the same campaign.

const POOL_PATH: String = "res://resources/events/arrival_pool.json"
const LEGACY_PATH: String = "res://resources/events/arrivals.json"
const DIALOGUE_DIR: String = "res://resources/dialogue/"
const STREAM: String = "arrival_schedule_v1"
## Stored with the timetable; 0 marks the old fixed timetable of pre-v6 saves.
const ALGORITHM_VERSION: int = 1


static func load_pool(path: String = POOL_PATH) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}


## The timetable for [param campaign_seed]. [param infected] maps character id
## to bool (GameState npcs[*].infected); it is only read.
static func generate(campaign_seed: int, infected: Dictionary, pool: Dictionary = {}, has_content: Callable = Callable()) -> Array[Dictionary]:
	if pool.is_empty():
		pool = load_pool()
	if not has_content.is_valid():
		has_content = func(dialogue: String) -> bool: return FileAccess.file_exists(DIALOGUE_DIR + dialogue + ".json")
	var rules: Dictionary = pool.get("rules", {})
	var rng := RandomNumberGenerator.new()
	rng.seed = campaign_seed ^ STREAM.hash()

	var visits: Array = (pool.get("visits", []) as Array).duplicate()
	visits.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var fixed_a: bool = a.has("fixed")
		var fixed_b: bool = b.has("fixed")
		if fixed_a != fixed_b:
			return fixed_a
		return str(a["id"]) < str(b["id"])
	)

	var placed: Array[Dictionary] = []
	for visit: Dictionary in visits:
		# Draw for every visit, written or not, so adding dialogue for one
		# character later does not reshuffle everybody else's dates.
		var roll: float = rng.randf()
		var window_pick: int = rng.randi()
		var day_pick: int = rng.randi()
		var slot_pick: int = rng.randi()
		if not has_content.call(str(visit["dialogue"])):
			continue
		if not visit.get("always", false) and roll >= float(visit.get("chance", 1.0)):
			continue
		if visit.has("fixed"):
			var fixed: Dictionary = visit["fixed"]
			placed.append(_entry(visit, int(fixed["day"]), int(fixed["start"]), int(fixed["end"]), true))
			continue
		var windows: Array = visit["windows"]
		var window: Dictionary = windows[window_pick % windows.size()]
		var spot: Vector2i = _find_slot(placed, window, rules, day_pick, slot_pick)
		if spot.x < 0:
			continue
		placed.append(_entry(visit, spot.x, spot.y, spot.y + int(window["duration"]), false))

	placed.sort_custom(comes_first)
	_ensure_early_infected(placed, visits, infected, rules, rng)
	placed.sort_custom(comes_first)
	for entry: Dictionary in placed:
		entry["id"] = "d%d_%s" % [entry["day"], entry["visit"]]
		entry.erase("fixed")
	return placed


## The pre-v6 fixed timetable (arrivals.json), for migrating old saves without
## re-rolling them. Ids stay "d1_elena", "d2_marcus", "d2_arthur".
static func legacy_schedule() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(LEGACY_PATH))
	if not parsed is Dictionary:
		return result
	for item: Dictionary in parsed.get("arrivals", []):
		result.append({
			"id": str(item["id"]), "visit": str(item["id"]).get_slice("_", 1), "npc": str(item["npc"]),
			"npcs": [str(item["npc"])], "day": int(item["day"]), "start": int(item["start"]),
			"end": int(item["end"]), "dialogue": str(item["dialogue"]),
		})
	result.sort_custom(comes_first)
	return result


## Order of visits: earlier day, then earlier start, then id.
static func comes_first(a: Dictionary, b: Dictionary) -> bool:
	if a["day"] != b["day"]:
		return a["day"] < b["day"]
	if a["start"] != b["start"]:
		return a["start"] < b["start"]
	return str(a.get("id", a.get("visit", ""))) < str(b.get("id", b.get("visit", "")))


## Structural check for a stored timetable (used by the save validator).
static func valid_schedule(schedule: Variant, roster_ids: PackedStringArray) -> bool:
	if not schedule is Array:
		return false
	var seen: Dictionary = {}
	for entry: Variant in schedule:
		if not entry is Dictionary:
			return false
		for key: String in ["id", "visit", "npc", "npcs", "day", "start", "end", "dialogue"]:
			if not entry.has(key):
				return false
		if not (entry["id"] is String and entry["npc"] is String and entry["npcs"] is Array and entry["dialogue"] is String):
			return false
		for key: String in ["day", "start", "end"]:
			if not (entry[key] is int or (entry[key] is float and is_equal_approx(entry[key], roundf(entry[key])))):
				return false
		if seen.has(entry["id"]) or int(entry["day"]) < 1 or int(entry["start"]) < 0 or int(entry["start"]) >= int(entry["end"]) or int(entry["end"]) > 1440:
			return false
		seen[entry["id"]] = true
		if (entry["npcs"] as Array).is_empty() or entry["npcs"][0] != entry["npc"]:
			return false
		for npc: Variant in entry["npcs"]:
			if not npc is String or not roster_ids.has(npc):
				return false
	return true


static func _entry(visit: Dictionary, day: int, start: int, end: int, fixed: bool) -> Dictionary:
	var npcs: Array = []
	for npc: Variant in visit["npcs"]:
		npcs.append(str(npc))
	return {
		"visit": str(visit["id"]), "npc": npcs[0], "npcs": npcs, "day": day, "start": start,
		"end": end, "dialogue": str(visit["dialogue"]), "fixed": fixed,
	}


## First free (day, start) at or after the drawn one, wrapping inside the
## window; (-1, -1) if the window has no room left.
static func _find_slot(placed: Array[Dictionary], window: Dictionary, rules: Dictionary, day_pick: int, slot_pick: int) -> Vector2i:
	var first_day: int = int(window["days"][0])
	var last_day: int = int(window["days"][1])
	var step: int = int(rules.get("slot_minutes", 15))
	var slot_count: int = (int(window["start_max"]) - int(window["start_min"])) / step + 1
	var day_count: int = last_day - first_day + 1
	var duration: int = int(window["duration"])
	for d: int in day_count:
		var day: int = first_day + (day_pick + d) % day_count
		for s: int in slot_count:
			var start: int = int(window["start_min"]) + ((slot_pick + s) % slot_count) * step
			if _fits(placed, day, start, start + duration, rules, -1):
				return Vector2i(day, start)
	return Vector2i(-1, -1)


static func _fits(placed: Array[Dictionary], day: int, start: int, end: int, rules: Dictionary, ignore: int) -> bool:
	if end > int(rules.get("latest_end", 1380)):
		return false
	var gap: int = int(rules.get("min_gap_minutes", 90))
	var same_day: int = 0
	for i: int in placed.size():
		if i == ignore or placed[i]["day"] != day:
			continue
		same_day += 1
		var other: Dictionary = placed[i]
		if not (start >= int(other["end"]) + gap or end + gap <= int(other["start"])):
			return false
	return same_day < int(rules.get("max_visits_per_day", 2))


## K-005 under a random timetable. Never touches infection; only moves a
## later infected visit into a random earlier visit's slot when both fit.
static func _ensure_early_infected(placed: Array[Dictionary], visits: Array, infected: Dictionary, rules: Dictionary, rng: RandomNumberGenerator) -> void:
	var limit: int = mini(int(rules.get("first_offers_window", 6)), placed.size())
	var late: Array[int] = []
	for i: int in placed.size():
		if _any_infected(placed[i], infected):
			if i < limit:
				return
			late.append(i)
	if late.is_empty():
		return
	var late_index: int = late[rng.randi_range(0, late.size() - 1)]
	var targets: Array[int] = []
	for i: int in limit:
		if not placed[i]["fixed"]:
			targets.append(i)
	# Fisher-Yates so the infected visit lands in a random early position.
	for i: int in range(targets.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var swap: int = targets[i]
		targets[i] = targets[j]
		targets[j] = swap
	for target: int in targets:
		if _swap_fits(placed, late_index, target, visits, rules):
			var a: Dictionary = placed[late_index]
			var b: Dictionary = placed[target]
			var a_len: int = int(a["end"]) - int(a["start"])
			var b_len: int = int(b["end"]) - int(b["start"])
			var a_day: int = a["day"]
			var a_start: int = a["start"]
			a["day"] = b["day"]
			a["start"] = b["start"]
			a["end"] = int(b["start"]) + a_len
			b["day"] = a_day
			b["start"] = a_start
			b["end"] = a_start + b_len
			return


static func _swap_fits(placed: Array[Dictionary], a_index: int, b_index: int, visits: Array, rules: Dictionary) -> bool:
	var a: Dictionary = placed[a_index]
	var b: Dictionary = placed[b_index]
	if not (_in_window(a, int(b["day"]), int(b["start"]), visits) and _in_window(b, int(a["day"]), int(a["start"]), visits)):
		return false
	var trial: Array[Dictionary] = []
	for entry: Dictionary in placed:
		trial.append(entry.duplicate())
	var a_len: int = int(a["end"]) - int(a["start"])
	var b_len: int = int(b["end"]) - int(b["start"])
	trial[a_index]["day"] = b["day"]
	trial[a_index]["start"] = b["start"]
	trial[a_index]["end"] = int(b["start"]) + a_len
	trial[b_index]["day"] = a["day"]
	trial[b_index]["start"] = a["start"]
	trial[b_index]["end"] = int(a["start"]) + b_len
	for i: int in [a_index, b_index]:
		if not _fits(trial, int(trial[i]["day"]), int(trial[i]["start"]), int(trial[i]["end"]), rules, i):
			return false
	return true


static func _in_window(entry: Dictionary, day: int, start: int, visits: Array) -> bool:
	for visit: Dictionary in visits:
		if str(visit["id"]) != entry["visit"] or visit.has("fixed"):
			continue
		for window: Dictionary in visit["windows"]:
			if day >= int(window["days"][0]) and day <= int(window["days"][1]) and start >= int(window["start_min"]) and start <= int(window["start_max"]):
				return true
	return false


static func _any_infected(entry: Dictionary, infected: Dictionary) -> bool:
	for npc: Variant in entry["npcs"]:
		if infected.get(npc, false):
			return true
	return false
