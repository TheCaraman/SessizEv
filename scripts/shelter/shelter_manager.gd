class_name ShelterManager
extends Node
## Beds and jobs for the people living in the house (docs/Day2Design.md,
## sections 6 and 7). Scene-local; all lasting state is in GameState.
##
## Changes are made as a plan: a complete proposal for who sleeps where and
## who does what. A plan is checked as a whole and applied as a whole, so a
## swap of two beds works and an invalid plan changes nothing.
##
## Jobs in this first version: inventory, cooking, security and night watch.
## A job takes the resident's time, not Daniel's. Finishing one produces a
## report exactly once; nothing a resident reports is invented, and on these
## quiet nights the watch honestly reports nothing.

const JOBS_PATH: String = "res://resources/jobs/jobs.json"
const NO_JOB: String = ""
## Agreeing a plan with the household takes this long.
const PLAN_MINUTES: int = 15
## At or below this trust a resident will not volunteer for work.
const REFUSAL_TRUST: int = -40

## Job definitions by id.
var _jobs: Dictionary = {}
var _job_order: Array[String] = []


func _ready() -> void:
	_load_jobs()
	EventBus.time_changed.connect(func(_day: int, _minutes: int) -> void: resolve_finished_jobs())


func get_job_ids() -> Array[String]:
	return _job_order.duplicate()


func get_job(job_id: String) -> Dictionary:
	return _jobs.get(job_id, {})


## The job a resident currently holds, or "".
func get_job_of(npc_id: String) -> String:
	return str(GameState.jobs.get(npc_id, {}).get("job", NO_JOB))


## The household as it stands: {"beds": {npc: bed}, "jobs": {npc: job}}.
## A management screen edits a copy of this and hands it back to apply_plan().
func get_current_plan() -> Dictionary:
	var bed_plan: Dictionary = {}
	var job_plan: Dictionary = {}
	for npc_id: String in GameState.get_residents():
		bed_plan[npc_id] = GameState.get_bed_of(npc_id)
		job_plan[npc_id] = get_job_of(npc_id)
	return {"beds": bed_plan, "jobs": job_plan}


## Why [param plan] cannot be carried out, as a translation key with
## arguments: {"key", "args"}; an empty key means the plan is valid.
func check_plan(plan: Dictionary) -> Dictionary:
	var residents: Array[String] = GameState.get_residents()
	var bed_plan: Dictionary = plan.get("beds", {})
	var job_plan: Dictionary = plan.get("jobs", {})

	var taken: Dictionary = {}
	for npc_id: String in residents:
		var bed_id: String = str(bed_plan.get(npc_id, ""))
		if not GameState.BEDS.has(bed_id):
			return _problem("PLAN_NO_BED", npc_id)
		if taken.has(bed_id):
			return {"key": "PLAN_BED_TAKEN", "args": {
				"name": Roster.get_display_name(npc_id),
				"other": Roster.get_display_name(taken[bed_id]),
			}}
		taken[bed_id] = npc_id
	for npc_id: String in bed_plan:
		if not residents.has(npc_id):
			return _problem("PLAN_NOT_RESIDENT", npc_id)

	for npc_id: String in job_plan:
		var job_id: String = str(job_plan[npc_id])
		if job_id == NO_JOB or job_id == get_job_of(npc_id):
			continue
		if not residents.has(npc_id):
			return _problem("PLAN_NOT_RESIDENT", npc_id)
		var refusal: Dictionary = why_refuses(npc_id, job_id)
		if refusal["key"] != "":
			return refusal
	return {"key": "", "args": {}}


## Why a resident would not take a job right now; empty key if they would.
## A refusal costs no time and no supplies.
func why_refuses(npc_id: String, job_id: String) -> Dictionary:
	if not _jobs.has(job_id):
		return _problem("PLAN_UNKNOWN_JOB", npc_id)
	if GameState.get_status(npc_id) != "resident":
		return _problem("PLAN_NOT_RESIDENT", npc_id)
	if int(GameState.npcs[npc_id]["trust"]) <= REFUSAL_TRUST:
		return _problem("REFUSE_NO_TRUST", npc_id)
	var person: Dictionary = GameState.npcs[npc_id]
	if person.get("injured", false):
		return _problem("REFUSE_INJURED", npc_id)
	if person.get("tired", false) or int(person.get("energy", 100)) <= 20:
		return _problem("REFUSE_TIRED", npc_id)
	var job: Dictionary = _jobs[job_id]
	if str(job.get("room", "")) in person.get("blocked_rooms", []):
		return _problem("REFUSE_ACCESS", npc_id)
	if job.get("needs_food", false) and int(GameState.resources["food"]) <= 0:
		return _problem("REFUSE_NO_FOOD", npc_id)
	if not job.get("at_night", false) and GameState.minutes + PLAN_MINUTES + int(job["minutes"]) > GameState.NIGHT_START:
		return _problem("REFUSE_TOO_LATE", npc_id)
	return {"key": "", "args": {}}


## Carries out [param plan] in full, or not at all. Returns the same shape as
## check_plan(); an empty key means it was applied. A plan that changes
## nothing is accepted and costs no time.
func apply_plan(plan: Dictionary) -> Dictionary:
	var problem: Dictionary = check_plan(plan)
	if problem["key"] != "":
		return problem
	var current: Dictionary = get_current_plan()
	var bed_plan: Dictionary = plan.get("beds", {})
	var job_plan: Dictionary = plan.get("jobs", {})

	var changed: bool = false
	for npc_id: String in GameState.get_residents():
		if str(bed_plan[npc_id]) != current["beds"][npc_id]:
			changed = true
		if job_plan.has(npc_id) and str(job_plan[npc_id]) != current["jobs"][npc_id]:
			changed = true
	if not changed:
		return {"key": "", "args": {}}

	# The talk comes first; work starts when it is over.
	for npc_id: String in job_plan:
		if str(job_plan[npc_id]) != current["jobs"].get(npc_id, NO_JOB):
			GameState.jobs.erase(npc_id)
	GameState.advance_minutes(PLAN_MINUTES)

	# Beds: rebuild the whole map so swaps never collide half-way.
	GameState.beds = {}
	for npc_id: String in GameState.get_residents():
		var bed_id: String = str(bed_plan[npc_id])
		GameState.beds[bed_id] = npc_id
		GameState.npcs[npc_id]["room"] = GameState.bed_room(bed_id)

	for npc_id: String in job_plan:
		var job_id: String = str(job_plan[npc_id])
		if job_id == current["jobs"].get(npc_id, NO_JOB):
			continue
		# A new assignment replaces the old one; the old work earns nothing.
		GameState.jobs.erase(npc_id)
		if job_id != NO_JOB:
			_start_job(npc_id, job_id)
	EventBus.residents_changed.emit()
	return {"key": "", "args": {}}


## Finishes every job whose time is up. Safe to call any number of times:
## a job is rewarded once.
func resolve_finished_jobs() -> void:
	for npc_id: String in GameState.jobs.keys():
		if GameState.get_status(npc_id) != "resident":
			GameState.jobs.erase(npc_id)
	var finished: Array[String] = []
	for npc_id: String in GameState.jobs:
		var entry: Dictionary = GameState.jobs[npc_id]
		var job: Dictionary = _jobs.get(str(entry["job"]), {})
		if job.is_empty() or job.get("at_night", false):
			continue
		if int(entry["day"]) == GameState.day and GameState.minutes >= int(entry["end"]):
			finished.append(npc_id)
	for npc_id: String in finished:
		_complete(npc_id)
	if not finished.is_empty():
		EventBus.residents_changed.emit()


## Called as the day ends: whoever was asked to keep watch reports in the
## morning. Returns the reports as ready-to-show lines.
func resolve_night() -> PackedStringArray:
	var lines := PackedStringArray()
	var watchers: Array[String] = []
	for npc_id: String in GameState.jobs:
		if _jobs.get(str(GameState.jobs[npc_id]["job"]), {}).get("at_night", false):
			watchers.append(npc_id)
	for npc_id: String in watchers:
		var report: Dictionary = _complete(npc_id)
		if not report.is_empty():
			lines.append(format_report(report))
	return lines


## A report as a line of text: "Arthur Bell: ...".
func format_report(report: Dictionary) -> String:
	return "%s: %s" % [
		Roster.get_display_name(report["npc"]),
		tr(report["key"]).format(report.get("args", {})),
	]


## Today's reports, oldest first, as ready-to-show lines.
func get_todays_reports() -> PackedStringArray:
	var lines := PackedStringArray()
	for report: Dictionary in GameState.reports:
		if int(report["day"]) == GameState.day:
			lines.append(format_report(report))
	return lines


## Trust as a word, never a number (GDD section 7).
static func trust_label_key(trust: int) -> String:
	if trust <= REFUSAL_TRUST:
		return "TRUST_HOSTILE"
	if trust <= -10:
		return "TRUST_DISTRUSTFUL"
	if trust < 15:
		return "TRUST_NEUTRAL"
	if trust < 40:
		return "TRUST_COOPERATIVE"
	return "TRUST_LOYAL"


func _start_job(npc_id: String, job_id: String) -> void:
	var job: Dictionary = _jobs[job_id]
	GameState.jobs[npc_id] = {
		"job": job_id,
		"day": GameState.day,
		"start": GameState.minutes,
		"end": GameState.minutes + int(job["minutes"]),
		"room": str(job.get("room", "")),
	}


## Ends a resident's job, records its result once and returns the report
## (empty if this exact job had already been completed).
func _complete(npc_id: String) -> Dictionary:
	if GameState.get_status(npc_id) != "resident":
		GameState.jobs.erase(npc_id)
		return {}
	var entry: Dictionary = GameState.jobs[npc_id]
	var job_id: String = str(entry["job"])
	var job: Dictionary = _jobs[job_id]
	GameState.jobs.erase(npc_id)

	var completion_id: String = "%d:%s:%s:%d" % [int(entry["day"]), npc_id, job_id, int(entry["start"])]
	var daily_id: String = "%d:%s" % [int(entry["day"]), job_id]
	if GameState.completed_jobs.has(completion_id) or GameState.completed_jobs.has(daily_id):
		return {}
	GameState.completed_jobs.append(completion_id)
	GameState.completed_jobs.append(daily_id)

	if job.has("sets_flag"):
		GameState.set_flag(str(job["sets_flag"]).format({"day": GameState.day}))

	# A character with the right background gives a fuller report, if one has
	# been written for them. Skill changes the detail, never who may do the job.
	var key: String = str(job["report"])
	var personal: String = "%s_%s" % [key, npc_id.get_slice("_", 0).to_upper()]
	if tr(personal) != personal:
		key = personal
	var report: Dictionary = {
		"day": GameState.day, "minutes": GameState.minutes, "npc": npc_id,
		"key": key, "args": GameState.resources.duplicate(),
	}
	GameState.reports.append(report)
	return report


func _problem(key: String, npc_id: String) -> Dictionary:
	return {"key": key, "args": {"name": Roster.get_display_name(npc_id)}}


func _load_jobs() -> void:
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(JOBS_PATH)) != OK or not json.data is Dictionary:
		push_error("ShelterManager: %s could not be read" % JOBS_PATH)
		return
	for job: Dictionary in json.data.get("jobs", []):
		var id: String = str(job["id"])
		job["minutes"] = int(job.get("minutes", 0))
		_jobs[id] = job
		_job_order.append(id)
