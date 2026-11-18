class_name NpcRoutine
extends RefCounted
## IMMERSION I-06 (technical skeleton): one central answer to "where is this
## resident and what are they doing right now".
##
## The room always comes from GameState.get_location, the single location
## model that jobs, isolation, night testimony and accusations already use, so
## nobody is ever shown in two places. This class only adds the activity and
## the pose to draw. It is deterministic (no random per room visit), reads
## no infection or campaign secret, and changes no state.
##
## Activity priority (docs/design/ImmersionBatchReview.md, I-06 AMEND):
##   isolated  -> "isolated"   (in the isolation room)
##   on a job  -> "work"       (in the job's room)
##   night watch, after 23:00 -> "watch" (awake in their room)
##   night in their own bedroom -> "sleep"
##   otherwise the authored phase activity in their bedroom
## Poses map to CharacterArt contexts; a missing pose drawing falls back to the
## character's room drawing, so this works before pose art exists.

const DATA_PATH: String = "res://resources/npc/routine.json"
const PHASE_NAMES: Array[String] = ["morning", "afternoon", "evening", "night"]

static var _rules_cache: Dictionary = {}


## {"room": String, "activity": String, "pose": StringName} for a resident, or
## {} for anyone not living in the house (dead, expelled, gone, unknown).
static func state(npc_id: String) -> Dictionary:
	if GameState.get_status(npc_id) != "resident":
		return {}
	var rules: Dictionary = _rules()
	var room: String = GameState.get_location(npc_id)
	var activity: String
	if GameState.npcs[npc_id].get("isolated", false):
		activity = "isolated"
	elif _working(npc_id):
		activity = "work"
	elif _watching(npc_id):
		activity = "watch"
	else:
		var phase: String = PHASE_NAMES[GameState.get_phase()]
		var bedroom: String = str(GameState.npcs[npc_id].get("room", ""))
		activity = "sleep" if phase == "night" and room == bedroom else phase
	return {"room": room, "activity": activity, "pose": StringName(str(rules["poses"].get(activity, rules["default_pose"])))}


## The pose to draw, or &"" for someone not in the house.
static func pose(npc_id: String) -> StringName:
	return state(npc_id).get("pose", &"")


## The authored table (poses per activity). Read once.
static func rules() -> Dictionary:
	return _rules().duplicate(true)


static func _working(npc_id: String) -> bool:
	if not GameState.jobs.has(npc_id):
		return false
	var job: Dictionary = GameState.jobs[npc_id]
	return (
		str(job.get("room", "")) != "" and int(job.get("day", 0)) == GameState.day
		and GameState.minutes >= int(job.get("start", 0)) and GameState.minutes < int(job.get("end", 0))
	)


## On tonight's night watch: awake in their room after NIGHT_START (same rule
## as Accusation and PowerIncident).
static func _watching(npc_id: String) -> bool:
	var job: Dictionary = GameState.jobs.get(npc_id, {})
	return job.get("job") == "night_watch" and int(job.get("day", 0)) == GameState.day and GameState.minutes >= GameState.NIGHT_START


static func _rules() -> Dictionary:
	if _rules_cache.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
		_rules_cache = parsed if parsed is Dictionary else {"poses": {}, "default_pose": "stand"}
	return _rules_cache
