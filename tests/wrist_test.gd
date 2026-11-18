extends Node
## IMMERSION I-08 mechanics: Tab glances at the wrist (day, clock, energy),
## J opens the journal. Looking changes nothing and never blocks walking.

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _on_screen(wrist: WristView) -> bool:
	return Rect2(Vector2.ZERO, wrist.panel.get_parent_area_size()).encloses(wrist.panel.get_global_rect())


func frames(count: int) -> void:
	for i: int in count:
		await get_tree().process_frame


func _ready() -> void:
	check(InputSetup.get_bound_key(&"wrist") == KEY_TAB, "Tab is the wrist")
	check(InputSetup.get_bound_key(&"journal") == KEY_J, "J is the journal")
	var used: Dictionary = {}
	for action: StringName in InputSetup.DEFAULT_BINDINGS:
		var key: Key = InputSetup.get_bound_key(action)
		check(not used.has(key), "no key shared by two actions (%s)" % action)
		used[key] = action

	GameState.new_campaign(21)
	GameState.day = 2
	GameState.minutes = 14 * 60 + 35
	GameState.player["energy"] = 62
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	await frames(2)
	var player: PlayerController = scene.get_node("Player")
	var wrist: WristView = player.get_node("WristView")
	check(not wrist.visible and not wrist.is_shown(), "watch is down until asked for")
	check(wrist.art_slot != null and wrist.art_slot.name == "ArtSlot", "art slot ready for the drawn arm")

	Settings.set_language("en")
	var state: Dictionary = GameState.to_dict().duplicate(true)
	Input.action_press(&"wrist")
	await frames(3)
	await get_tree().create_timer(WristView.SLIDE_SECONDS + 0.1).timeout
	check(wrist.is_shown() and wrist.visible, "holding Tab raises the watch")
	check(_on_screen(wrist), "the raised watch is fully on screen (%s in %s)" % [wrist.panel.get_global_rect(), wrist.panel.get_parent_area_size()])
	check(wrist.day_label.text == "Day 2", "day shown (%s)" % wrist.day_label.text)
	check(wrist.clock_label.text == "14:35", "clock shown (%s)" % wrist.clock_label.text)
	check(wrist.energy_label.text == "Energy 62%" and is_equal_approx(wrist.energy_bar.value, 62.0), "energy shown (%s)" % wrist.energy_label.text)
	check(player.control_enabled, "walking is not blocked while looking")
	check(GameState.to_dict() == state, "looking spends no time or energy")
	check(not scene._journal.visible, "Tab no longer opens the journal")

	GameState.minutes += 20
	GameState.player["energy"] = 41
	await frames(2)
	check(wrist.clock_label.text == "14:55" and wrist.energy_label.text == "Energy 41%", "readout follows the game live")

	Settings.set_language("tr")
	await frames(2)
	check(wrist.day_label.text == "Gün 2" and wrist.energy_label.text == "Enerji %41", "Turkish readout (%s / %s)" % [wrist.day_label.text, wrist.energy_label.text])
	Settings.set_language("en")

	player.control_enabled = false
	await frames(2)
	check(not wrist.is_shown(), "watch drops when a screen takes control")
	player.control_enabled = true
	await frames(2)
	await get_tree().create_timer(WristView.SLIDE_SECONDS + 0.1).timeout
	check(wrist.is_shown(), "and comes back while Tab is still held")
	check(_on_screen(wrist), "back on screen after an interruption")

	Input.action_release(&"wrist")
	await get_tree().create_timer(WristView.SLIDE_SECONDS + 0.15).timeout
	check(not wrist.is_shown() and not wrist.visible, "releasing Tab lowers the watch")

	Settings.set_number("camera_motion", 0.0)
	Input.action_press(&"wrist")
	await frames(2)
	check(wrist.visible and is_equal_approx(wrist.panel.position.y, wrist.rest_position_y()), "reduced motion: watch appears at once")
	check(_on_screen(wrist), "reduced motion: watch fully on screen")
	Input.action_release(&"wrist")
	await frames(2)
	check(not wrist.visible, "reduced motion: watch goes at once")
	Settings.set_number("camera_motion", 1.0)

	var journal_key := InputEventAction.new()
	journal_key.action = &"journal"
	journal_key.pressed = true
	Input.parse_input_event(journal_key)
	await frames(3)
	check(scene._journal.visible, "J opens the journal")
	check(scene._journal._close_hint.text.begins_with("J "), "journal close hint names J (%s)" % scene._journal._close_hint.text)
	Input.parse_input_event(journal_key)
	await frames(3)
	check(not scene._journal.visible, "J closes the journal")
	check(not tr("POWER_WAKE").contains("Tab") and not tr("POWER_JOURNAL").contains("Tab"), "no text still says Tab for the journal")

	scene.queue_free()
	await frames(2)
	if failures == 0:
		print("WRIST TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
