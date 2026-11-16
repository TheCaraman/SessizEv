extends Node
var checks: int = 0
var failures: int = 0
func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + message)
func _ready() -> void:
	GameState.new_campaign(42)
	var original: Dictionary = GameState.to_dict()
	for sleeping: bool in [false, true]:
		var timeline := NightTimeline.new()
		check(timeline.begin(3, 100), "begin")
		check(not timeline.begin(3, 100), "begin never resets active session")
		check(not timeline.claim_morning(), "no early consumption")
		for minute: int in range(1381, 1861):
			var crossed: Array[int] = timeline.advance_to(minute, sleeping)
			check(crossed.size() == (1 if (minute - 1380) % 120 == 0 else 0), "boundary exactly once")
			var restored := NightTimeline.new()
			var encoded: Dictionary = JSON.parse_string(JSON.stringify(timeline.to_dict()))
			if not restored.valid(encoded):
				check(false, "invalid roundtrip at " + str(minute) + ": " + JSON.stringify(encoded))
				get_tree().quit(1)
				return
			check(restored.from_dict(encoded), "JSON roundtrip at every minute")
			check(restored.to_dict() == timeline.to_dict() and restored.energy() == timeline.energy(), "restored accounting identical")
			timeline = restored
		check(timeline.energy() == (100 if sleeping else 60), "full night energy")
		check(timeline.claim_morning() and not timeline.claim_morning(), "morning exactly once")
		var resolved := NightTimeline.new()
		check(resolved.from_dict(timeline.to_dict()) and not resolved.claim_morning(), "consumption claim survives reload")
		check(timeline.advance_to(1900).is_empty(), "resolved night cannot advance")
	var mixed := NightTimeline.new()
	mixed.begin(3, 50)
	check(mixed.next_boundary() == 1500, "first boundary 01:00")
	mixed.advance_to(1620)
	check(mixed.next_boundary() == 1740 and mixed.energy() == 30, "half night watch")
	var halfway: Dictionary = mixed.to_dict()
	mixed.advance_to(1500)
	check(mixed.to_dict() == halfway, "backward request atomic")
	mixed.advance_to(1860, true)
	check(mixed.energy() == 63, "mixed partial recovery rounded once")
	var state: Dictionary = mixed.to_dict()
	for broken: Dictionary in [{"awake_minutes": -1}, {"cursor_minute": 1861}, {"initial_energy": 101}, {"resolved_boundaries": [1500]}, {"state": "awake"}, {"morning_resolved": "yes"}]:
		var invalid: Dictionary = state.duplicate(true)
		invalid.merge(broken, true)
		check(not mixed.from_dict(invalid) and mixed.to_dict() == state, "malformed night rejected atomically")
	check(GameState.to_dict() == original, "pure module never consumes or changes infection")
	if failures == 0:
		print("NIGHT TIMELINE TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
