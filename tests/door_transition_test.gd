extends Node
var checks: int = 0
var failures: int = 0
var _language_before: String
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _ready() -> void:
	_check_shared_world()
	GameState.new_campaign(42)
	_language_before = Settings.language
	check(Settings.set_language("tr") == OK, "capture/test language follows persisted setting")
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1920, 1080)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	viewport.add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	player.position = Vector3(6.4, 0.05, 7.5)
	player.rotation.y = deg_to_rad(90.0)
	var room: RoomView = scene.get_node("RoomView")
	var door: RoomDoor = scene.find_child("Door_living_room", true, false)
	check(door != null and door.has_node("Hinge/DoorLeaf"), "real hinged leaf")
	# Start at the real corridor side, independent of the current floor plan.
	player.global_position = door.to_global(Vector3(0.0, 0.05, 1.3))
	player.global_rotation = Vector3(0.0, door.global_rotation.y, 0.0)
	var before: Dictionary = GameState.to_dict()
	var camera: Camera3D = player.get_node("Head/Camera3D")
	var camera_before: Transform3D = camera.global_transform
	check(is_equal_approx(RoomDoor.TRANSITION_SECONDS, maxf(RoomDoor.OPEN_SECONDS, RoomDoor.APPROACH_DELAY + RoomDoor.APPROACH_SECONDS)), "transition length matches leaf and approach")
	check(RoomDoor.TRANSITION_SECONDS >= 0.35 and RoomDoor.TRANSITION_SECONDS <= 0.45, "door to room takes 0.35-0.45 s (DOOR-REFERENCE-003)")
	var opened_at: int = Time.get_ticks_msec()
	door.interact(player)
	door.interact(player)
	check(not player.control_enabled and not room.is_open(), "opening locks control before showing room")
	await get_tree().create_timer(0.22).timeout
	check(absf(door.get_node("Hinge").rotation.y) > 0.6 and not room.is_open(), "leaf swings out fast before the room shows")
	check(camera.global_position.distance_to(camera_before.origin) > 0.02, "step into the doorway runs alongside the leaf, not after it")
	check(absf(camera.global_position.y - camera_before.origin.y) < 0.001, "approach preserves eye height instead of crouching into doorway")
	var threshold: MeshInstance3D = door.get_node("RoomThreshold")
	check(threshold.visible and threshold.material_override is ShaderMaterial, "physical opening uses screen-matched room preview")
	var preview_texture: Texture2D = threshold.material_override.get_shader_parameter("room_image")
	check(preview_texture is ViewportTexture and door._composition.background.texture.resource_path == RoomVisuals.new().resolve("living_room", GameState.minutes, true)["path"], "opening composites the actual room variant")
	check(door._composition.props.get_prop_ids().has("media_console"), "props already exist behind the physical opening")
	var director: CampaignDirector = scene.get_node("CampaignDirector")
	GameState.power_incident = {"state": "outage", "cause": "grid_loss", "inspected": []}
	director.power.power_changed.emit(false)
	check(door._composition.background.texture.resource_path == RoomVisuals.new().resolve("living_room", GameState.minutes, false)["path"], "power-only event refreshes the open aperture without advancing time")
	GameState.power_incident = before["power_incident"].duplicate(true)
	director.power.power_changed.emit(true)
	var old_brightness: float = Settings.get_number("brightness")
	check(Settings.set_number("brightness", 1.35) == OK, "non-default brightness saved in isolated settings")
	check(door._composition.background.modulate == RoomVisuals.new().resolve("living_room", GameState.minutes, true)["background_tint"], "3D preview does not multiply brightness a second time")
	check(is_equal_approx(float(scene.get_node("RetroPostProcess")._material.get_shader_parameter("brightness")), 1.35), "corridor pass applies preview brightness once")
	check(Settings.set_number("brightness", old_brightness) == OK, "brightness restored before visual comparison")
	if "--capture-door" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png("res://docs/qa/door-opening.png") == OK, "opening image saved")
	if "--capture-door" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png("res://docs/qa/door-approaching.png") == OK, "approach image saved")
	while not room.is_open() and Time.get_ticks_msec() - opened_at < 1500:
		await get_tree().process_frame
	var took: float = (Time.get_ticks_msec() - opened_at) / 1000.0
	check(room.is_open() and took <= RoomDoor.TRANSITION_SECONDS + 0.12, "room shows %.2f s after the key press" % took)
	check(room.is_open() and room.get_room_id() == "living_room" and not player.control_enabled, "opening resolves to correct room")
	check(camera.global_position.distance_to(camera_before.origin) < 0.001, "camera returns to original corridor position behind room view")
	check(not room._transition_cover.visible, "handoff adds no second black cover")
	check(door._composition.props.get_prop_ids() == (room.get_prop_layer() as RoomProps).get_prop_ids(), "same prop set before and after handoff")
	check(door._preview_viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED, "hidden preview does not render every frame")
	if "--capture-door" in OS.get_cmdline_user_args():
		await RenderingServer.frame_post_draw
		check(viewport.get_texture().get_image().save_png("res://docs/qa/door-entered.png") == OK, "room handoff image saved")
	check(is_equal_approx(room._root.modulate.a, 1.0), "room fade finishes")
	var open_angle: float = absf(door.get_node("Hinge").rotation.y)
	room.close()
	check(player.control_enabled, "leaving the room returns control at once")
	check(door.is_closing() and absf(door.get_node("Hinge").rotation.y) > open_angle * 0.9, "door is still open when the corridor reappears")
	check(door.get_node("RoomThreshold").visible, "dark recess stays behind the open leaf while it closes")
	door.interact(player)
	check(not room.is_open() and player.control_enabled, "a closing door cannot be reopened mid-swing")
	await get_tree().create_timer(0.2).timeout
	var mid: float = absf(door.get_node("Hinge").rotation.y)
	check(mid > 0.01 and mid < open_angle, "leaf visibly swings shut")
	await get_tree().create_timer(RoomDoor.CLOSE_SECONDS).timeout
	check(not door.is_closing() and is_zero_approx(door.get_node("Hinge").rotation.y), "leaf ends fully closed")
	check(not door.get_node("RoomThreshold").visible and GameState.to_dict() == before, "threshold hides and transition consumes no campaign time")
	door.interact(player)
	check(not player.control_enabled, "a closed door can be opened again")
	await get_tree().create_timer(1.0).timeout
	check(room.is_open() and room.get_room_id() == "living_room", "reopening reaches the same room")
	room.close()
	await get_tree().create_timer(RoomDoor.CLOSE_SECONDS + 0.05).timeout
	door.interact(player)
	var escape := InputEventAction.new()
	escape.action = &"pause"
	escape.pressed = true
	door._unhandled_input(escape)
	check(player.control_enabled and not room.is_open() and not threshold.visible, "Escape cancels an opening without entering the room")
	await get_tree().create_timer(RoomDoor.TRANSITION_SECONDS + 0.05).timeout
	check(not room.is_open() and camera.global_position.distance_to(camera_before.origin) < 0.001, "cancelled tween never enters room or leaves displaced camera")
	var motion: float = Settings.get_number("camera_motion")
	check(Settings.set_number("camera_motion", 0.0) == OK, "reduced motion preference persists")
	var reduced_at: int = Time.get_ticks_msec()
	door.interact(player)
	var still: bool = true
	while not room.is_open() and Time.get_ticks_msec() - reduced_at < 1500:
		await get_tree().process_frame
		still = still and camera.global_position.distance_to(camera_before.origin) < 0.001
	var reduced_took: float = (Time.get_ticks_msec() - reduced_at) / 1000.0
	check(room.is_open() and still, "reduced motion opens room without moving camera")
	check(reduced_took <= RoomDoor.REDUCED_OPEN_SECONDS + 0.12, "reduced motion: room starts %.2f s after the key press" % reduced_took)
	check(room._root.modulate.a < 0.5, "reduced motion: room dissolves in instead of cutting")
	await get_tree().create_timer(RoomView.DISSOLVE_SECONDS + 0.05).timeout
	check(is_equal_approx(room._root.modulate.a, 1.0), "reduced motion: dissolve finishes")
	check(RoomDoor.REDUCED_OPEN_SECONDS + RoomView.DISSOLVE_SECONDS <= 0.45, "reduced motion stays within the same short budget")
	room.close()
	check(Settings.set_number("camera_motion", motion) == OK, "motion preference restored for other checks")
	await get_tree().create_timer(RoomDoor.CLOSE_SECONDS + 0.05).timeout
	GameState.admit("elena_ward", "guest_a_1")
	var occupied_door: RoomDoor = scene.find_child("Door_guest_a", true, false)
	check(occupied_door != null, "real occupied bedroom has a corridor door")
	if occupied_door != null:
		player.global_position = occupied_door.to_global(Vector3(0.0, 0.05, 1.3))
		player.global_rotation = Vector3(0.0, occupied_door.global_rotation.y, 0.0)
		occupied_door.interact(player)
		await get_tree().create_timer(0.3).timeout
		check(occupied_door._composition.resident_ids == ["elena_ward"], "resident is visible through the opening before room UI")
		if "--capture-door" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			check(viewport.get_texture().get_image().save_png("res://docs/qa/door-occupied-opening.png") == OK, "occupied opening saved")
		await get_tree().create_timer(0.7).timeout
		check(room.get_room_id() == &"guest_a" and room._world.resident_ids == occupied_door._composition.resident_ids, "resident identities match after physical handoff")
		if "--capture-door" in OS.get_cmdline_user_args():
			await RenderingServer.frame_post_draw
			check(viewport.get_texture().get_image().save_png("res://docs/qa/door-occupied-entered.png") == OK, "occupied room saved")
		room.close()
	scene.free()
	await get_tree().process_frame
	check(Settings.set_language(_language_before) == OK, "test restores language preference")
	if failures == 0:
		print("DOOR TRANSITION TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)

func _check_shared_world() -> void:
	GameState.new_campaign(42)
	GameState.admit("elena_ward", "guest_a_1")
	var world := RoomWorld.new()
	world.size = Vector2(1920.0, 1080.0)
	add_child(world)
	var before: Dictionary = GameState.to_dict()
	world.show_room(&"guest_a", 420, true)
	check(world.resident_ids == ["elena_ward"] and world.characters.get_child_count() == 1, "shared world draws the real bedroom resident once")
	check(world.characters.get_child(0).get_meta(&"npc_id") == "elena_ward", "figure identity is shared by preview and room")
	world.show_room(&"guest_a", 420, true)
	check(world.characters.get_child_count() == 1 and GameState.to_dict() == before, "repeated rendering neither duplicates figures nor mutates campaign")
	GameState.jobs["elena_ward"] = {"job": "cooking", "room": "kitchen", "day": 1, "start": 420, "end": 480}
	world.show_room(&"guest_a", 420, true)
	check(world.resident_ids.is_empty(), "working resident is not simultaneously shown in bedroom")
	world.show_room(&"kitchen", 420, true)
	check(world.resident_ids == ["elena_ward"], "job location is the only displayed location")
	GameState.jobs.clear()
	GameState.npcs["elena_ward"]["isolated"] = true
	GameState.flags["isolation_ready"] = true
	world.show_room(&"guest_a", 420, true)
	check(world.resident_ids.is_empty(), "isolated resident cannot appear in ordinary bedroom")
	world.show_room(&"isolation", 420, true)
	check(world.resident_ids == ["elena_ward"], "isolation uses the same central location model")
	GameState.npcs["elena_ward"]["isolated"] = false
	GameState.remove_npc("elena_ward", "expelled")
	world.show_room(&"guest_a", 420, true)
	check(world.resident_ids.is_empty(), "expelled resident has no room figure")
	for powered: bool in [true, false]:
		world.show_room(&"living_room", 1380, powered)
		var expected: Dictionary = RoomVisuals.new().resolve("living_room", 1380, powered)
		check(world.background.texture.resource_path == expected["path"] and world.props.get_prop_ids().has("media_console"), "night/outage composition keeps correct background and props")
		check(world.props.modulate == world.characters.modulate, "actors and props share lighting, UI excluded")
	world.free()
