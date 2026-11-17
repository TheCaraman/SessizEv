extends Node

var checks: int = 0
var failures: int = 0
var answered: int = 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)

func _ready() -> void:
	GameState.new_campaign(42)
	GameState.day = 4
	var scene: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(scene)
	var player: PlayerController = scene.get_node("Player")
	player.set_physics_process(false)
	var front: RoomDoor
	for body: Node in scene.find_children("*", "StaticBody3D", true, false):
		if body is RoomDoor and body.is_front:
			front = body
	check(front != null, "real entrance door exists")
	var target: PeepholeInteraction = front.get_node("Peephole")
	check(target != null, "physical peephole mounted only on entrance")
	EventBus.front_door_used.connect(func() -> void: answered += 1)
	var state: Dictionary = GameState.to_dict().duplicate(true)
	var walk_camera: Camera3D = player.get_node("Head/Camera3D")
	player.global_position = front.to_global(Vector3(0.0, 0.05, -1.0))
	walk_camera.look_at(target.global_position, Vector3.UP)
	for frame: int in 3:
		await get_tree().physics_frame
	check(player.get_node("Head/Camera3D/InteractionRay").get_target() == target, "real interaction ray reaches optical target ahead of door leaf")
	var transform_before: Transform3D = walk_camera.global_transform
	var fov_before: float = walk_camera.fov
	target.interact(player)
	var view: PeepholeView = target.view
	check(view.is_open() and view.visible, "empty exterior can be observed")
	check(not player.control_enabled, "walking blocked during optical view")
	check(view.viewport.world_3d == player.get_viewport().world_3d, "camera observes actual house exterior world")
	check(view.viewport.world_2d != player.get_viewport().world_2d, "interface is not recursively rendered")
	check(view.camera.global_position.z > front.global_position.z, "optical camera sits outside the closed leaf")
	check(view.camera.global_basis.z.dot(front.global_basis.z) < -0.99, "camera looks outward")
	check(view.visitor_slot.get_child_count() == 0, "no invented visitor")
	check(GameState.to_dict() == state and answered == 0, "look is free and does not answer door")
	view.close()
	check(player.control_enabled and not view.visible, "return restores walking")
	check(view.viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED, "closed view does not render every frame")
	check(walk_camera.global_transform == transform_before and walk_camera.fov == fov_before, "walking camera unchanged")
	GameState.visitor = "elena_ward"
	state = GameState.to_dict().duplicate(true)
	target.interact(player)
	check(view.visitor_id == "elena_ward" and view.visitor_slot.get_child_count() == 1, "only real waiting visitor is drawn")
	check(view.visitor_slot.get_child(0).get_meta("npc_id") == "elena_ward", "visible figure comes from public visitor id")
	check(GameState.to_dict() == state and answered == 0, "seeing visitor neither recruits nor spends time")
	# Light on the visitor follows the porch: day, night with the lantern, and
	# night in a power cut (lantern out) are three different levels.
	GameState.minutes = 660
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	var day_light: float = view.visitor_slot.modulate.v
	GameState.minutes = 1350
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	var night_light: float = view.visitor_slot.modulate.v
	GameState.power_incident = {"state": "outage", "cause": "grid_loss", "inspected": []}
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	var outage_light: float = view.visitor_slot.modulate.v
	check(day_light > night_light and night_light > outage_light, "visitor is darker at night and darker still with the porch lantern out")
	GameState.power_incident = {}
	GameState.minutes = 420
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	GameState.visitor = ""
	EventBus.visitor_changed.emit("")
	check(view.visitor_slot.get_child_count() == 0, "departed visitor disappears immediately")
	GameState.visitor = "elena_ward"
	EventBus.visitor_changed.emit(GameState.visitor)
	for language: String in ["en", "tr"]:
		Settings.set_language(language)
		check(not target.get_interaction_prompt().contains("PROMPT_PEEPHOLE"), "localized optical prompt " + language)
		check(view._back.text == tr("SETTINGS_BACK"), "localized return button " + language)
	for size: Vector2i in [Vector2i(1280, 720), Vector2i(1920, 1080), Vector2i(2560, 1440)]:
		get_viewport().size = size
		for frame: int in 2:
			await get_tree().process_frame
		view._resize()
		check(view.viewport.size == Vector2i(get_viewport().get_visible_rect().size), "optical output matches stretched UI canvas at " + str(size))
		check(view._back.get_global_rect().end.y <= get_viewport().get_visible_rect().size.y, "return button stays on screen at " + str(size))
	check(view._back.size.x >= 300.0, "keyboard return target remains readable")
	if "--capture-peephole" in OS.get_cmdline_user_args():
		get_viewport().size = Vector2i(1920, 1080)
		view._resize()
		for frame: int in 10:
			await get_tree().process_frame
		await RenderingServer.frame_post_draw
		DirAccess.make_dir_recursive_absolute("res://docs/qa/peephole")
		check(get_viewport().get_texture().get_image().save_png("res://docs/qa/peephole/visitor-day.png") == OK, "native capture")
	var back := InputEventAction.new()
	back.action = &"pause"
	back.pressed = true
	view._unhandled_input(back)
	check(not view.is_open() and player.control_enabled, "Escape returns without pause conflict")
	scene.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	if failures == 0:
		print("PEEPHOLE TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
