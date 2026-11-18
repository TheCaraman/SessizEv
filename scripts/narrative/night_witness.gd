class_name NightWitness
extends RefCounted
## An authored innocent bathroom visit. Infection is never a selection input.
const RECORD: String = "night_witness_record"
const PROTOCOL: String = "night_witness_enabled"
var offscreen: Callable
var access: Callable

func propose(until: int) -> Dictionary:
	if GameState.day != 3 or not GameState.night_in_progress() or GameState.night_session.get("state") != "awake":
		return {}
	if GameState.get_flag(PROTOCOL, false) != true or GameState.flags.has(RECORD) or not GameState.get_flag("night_pipes_day3_heard", false):
		return {}
	if not offscreen.is_valid() or not offscreen.call() or not access.is_valid():
		return {}
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NightObservation.RULES))
	var ids: Array[String] = []
	for id: String in rules["allowed_adults"]:
		if _available(id) and _route_allowed(id) and rules["routes"].has(GameState.get_location(id)) and not _busy(id):
			ids.append(id)
	ids.sort()
	for subject: String in ids:
		for observer: String in ids:
			if subject == observer:
				continue
			var measured: Dictionary = access.call(GameState.get_location(subject), GameState.get_location(observer))
			if measured.get("route_access") != true or measured.get("sightline") != true:
				continue
			var start: int = maxi(int(rules["earliest"]), GameState.minutes + 1)
			var steps: Array = _steps(rules["routes"][GameState.get_location(subject)], start, int(rules["step_minutes"]))
			# Both people complete the whole trip while Daniel is behind his room view.
			var observer_steps: Array = _steps(rules["routes"][GameState.get_location(observer)], start, int(rules["step_minutes"]))
			var end: int = maxi(int(steps[-1]["minute"]), int(observer_steps[-1]["minute"]))
			if end > mini(until, int(rules["latest"])):
				continue
			var seen: int = 0
			for step: Dictionary in steps:
				if step["room"] == "corridor":
					seen = int(step["minute"]) + 1
					break
			# Observer checks the corridor after the pipe noise, not the bathroom.
			var outward: Array = []
			for step: Dictionary in observer_steps:
				outward.append(step["room"])
				if step["room"] == "corridor":
					break
			var awake_from: int = start
			var observed_from: int = start + (outward.size() - 1)
			if seen < observed_from:
				continue
			var observer_trace: Array = []
			for index: int in outward.size():
				observer_trace.append({"room": outward[index], "minute": start + index})
			for index: int in range(outward.size() - 2, -1, -1):
				observer_trace.append({"room": outward[index], "minute": seen + outward.size() - index})
			end = int(observer_trace[-1]["minute"])
			if end > mini(until, int(rules["latest"])):
				continue
			var record: Dictionary = {"day": 3, "start": start, "end": steps[-1]["minute"], "seen_at": seen,
				"subject": subject, "observer": observer, "subject_reason": rules["subject_reason"], "observer_reason": rules["observer_reason"], "denial_reason": rules["denial_reason"],
				"steps": steps, "observer_steps": observer_trace, "observer_returned_at": end,
				"snapshot": {subject: {"status": "resident", "route_access": measured["route_access"], "room": GameState.get_location(subject)}, observer: {"status": "resident", "route_access": measured["route_access"], "room": GameState.get_location(observer)}},
				"observation": {"room": "corridor", "minute": seen, "awake": awake_from <= seen and seen < end, "sightline": measured["sightline"], "awake_from": awake_from, "awake_until": end, "positions": measured}}
			if NightObservation.valid_completed(record):
				return GameState._restore_numbers(record)
	return {}

func publish(record: Dictionary) -> Error:
	if record.is_empty():
		return OK
	if GameState.flags.has(RECORD) or not NightObservation.valid_completed(record) or maxi(int(record["end"]), int(record["observer_returned_at"])) > GameState.minutes:
		return ERR_INVALID_DATA
	for id: String in [record["subject"], record["observer"]]:
		if not _available(id) or not _route_allowed(id) or _busy(id) or GameState.get_location(id) != record["snapshot"][id]["room"]:
			return ERR_UNAVAILABLE
	var expected: Dictionary = GameState.to_dict()
	var candidate: Dictionary = expected.duplicate(true)
	candidate["flags"][RECORD] = record.duplicate(true)
	return SaveManager.commit_candidate(expected, candidate, "night_witness_day3")

func _steps(route: Array, start: int, step_minutes: int) -> Array:
	var result: Array = []
	for index: int in route.size():
		result.append({"room": route[index], "minute": start + index * step_minutes})
	return result

func _available(id: String) -> bool:
	var person: Dictionary = GameState.npcs.get(id, {})
	if person.get("status") != "resident":
		return false
	for flag: String in ["isolated", "absent", "injured", "incapacitated", "busy"]:
		if person.get(flag, false) != false:
			return false
	return true

func _route_allowed(id: String) -> bool:
	var person: Dictionary = GameState.npcs.get(id, {})
	# The rooms this person would actually pass (NIGHT-ROUTE-COMPAT-001); the
	# old fixed list still named the two-storey stair landing.
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NightObservation.RULES))
	var rooms: Array = (rules["routes"].get(GameState.get_location(id), ["corridor", "bathroom_upper"]) as Array).duplicate()
	rooms.append(str(person.get("room", "")))
	for room: String in rooms:
		if room in person.get("blocked_rooms", []):
			return false
	return true

func _busy(id: String) -> bool:
	if not GameState.jobs.has(id):
		return false
	var job: Dictionary = GameState.jobs[id]
	return int(job.get("day", 0)) == GameState.day and (job.get("job") == "night_watch" or int(job.get("end", 0)) > GameState.minutes)

func actions(room: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NightObservation.RULES))
	var record: Dictionary = GameState.get_flag(RECORD, {})
	if GameState.day != 4 or record.is_empty() or not NightObservation.valid(record):
		return result
	for role: String in ["observer", "subject"]:
		var id: String = record[role]
		if _available(id) and not _busy(id) and GameState.get_location(id) == room:
			result.append({"id": "witness:" + role, "label": TranslationServer.translate("WITNESS_ASK").format({"name": Roster.get_display_name(id), "minutes": int(rules["interview_minutes"])})})
	var subject: String = record["subject"]
	if GameState.get_flag("witness_interview_observer", false) and GameState.get_flag("witness_interview_subject", false) and _available(subject) and not _busy(subject) and GameState.get_location(subject) == room:
		result.append({"id": "witness:clarify", "label": TranslationServer.translate("WITNESS_CLARIFY_ACTION").format({"name": Roster.get_display_name(subject), "minutes": int(rules["interview_minutes"])})})
	return result

func interview(room: String, role: String) -> String:
	var allowed: bool = false
	for action: Dictionary in actions(room):
		if action["id"] == "witness:" + role:
			allowed = true
	if not allowed:
		return ""
	var record: Dictionary = GameState.get_flag(RECORD, {})
	var key: String = "WITNESS_" + role.to_upper()
	var time: int = posmod(int(record["seen_at"]), 1440)
	var args: Dictionary = {"subject": Roster.get_display_name(record["subject"]), "observer": Roster.get_display_name(record["observer"]), "time": "%02d:%02d" % [time / 60, time % 60]}
	var flag: String = "witness_interview_" + role
	if not GameState.get_flag(flag, false):
		var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(NightObservation.RULES))
		var cost: int = int(rules["interview_minutes"])
		if GameState.minutes + cost > GameState.get_action_time_limit():
			return TranslationServer.translate("POWER_TOO_LATE")
		var expected: Dictionary = GameState.to_dict()
		var candidate: Dictionary = expected.duplicate(true)
		candidate["minutes"] += cost
		candidate["flags"][flag] = true
		if not EvidenceManager.collect_into(candidate["evidence"], "witness_" + role, key, "claim", args):
			return ""
		if SaveManager.commit_candidate(expected, candidate, "witness_interview_" + role) != OK:
			return TranslationServer.translate("NARR_SAVE_FAILED")
	return TranslationServer.translate(key).format(args)
