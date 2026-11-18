extends Node3D
## Isolated model review; no campaign reads or writes.
var actor: Node3D
var camera: Camera3D
var animation: AnimationPlayer
var yaw := 0.0
var walking := false
var close_up := false
var capture_phase := 0.4
var capture_cycle := false
func _ready() -> void:
	if not str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")).begins_with("TheQuietHours-Tests/"):
		push_error("Use the isolated Elena review launcher")
		get_tree().quit(2)
		return
	actor = load("res://assets/models/elena_v6/elena_v6.glb").instantiate()
	add_child(actor)
	for child: Node in actor.find_children("*", "AnimationPlayer", true, false):
		animation = child
	if animation == null:
		push_error("Imported character has no AnimationPlayer")
		get_tree().quit(3)
		return
	print("IMPORTED_ANIMATIONS ", animation.get_animation_list())
	_play("Idle_8fps")
	var env := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_COLOR
	e.background_color = Color("172521")
	e.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color = Color("b8c7b8")
	e.ambient_light_energy = 0.55
	env.environment = e
	add_child(env)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-35, -30, 0)
	key.light_energy = 1.1
	key.light_color = Color("ffdfbd")
	key.shadow_enabled = true
	add_child(key)
	var floor_mesh := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(4, 4)
	floor_mesh.mesh = plane
	floor_mesh.position.y = -0.005
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("273730")
	floor_material.roughness = 1.0
	floor_mesh.material_override = floor_material
	add_child(floor_mesh)
	camera = Camera3D.new()
	camera.current = true
	camera.fov = 37
	add_child(camera)
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var label := Label.new()
	label.text = "ELENA — 3D STUDY / NOT FINAL\nA/D: rotate   Space: walk/idle   F: face   Esc: exit"
	label.position = Vector2(24, 24)
	label.add_theme_font_size_override("font_size", 22)
	canvas.add_child(label)
	_update_camera()
	for arg: String in OS.get_cmdline_user_args():
		if arg == "--side":
			yaw = PI * 0.5
			_update_camera()
		if arg == "--close":
			close_up = true
			_update_camera()
		if arg.begins_with("--phase="): capture_phase = float(arg.trim_prefix("--phase="))
		if arg == "--cycle": capture_cycle = true
		if arg == "--angle":
			yaw = 0.65
			_update_camera()
		if arg.begins_with("--capture="):
			_capture(arg.trim_prefix("--capture="))
func _play(suffix: String) -> void:
	for name: StringName in animation.get_animation_list():
		if str(name).ends_with(suffix):
			animation.get_animation(name).loop_mode = Animation.LOOP_LINEAR
			animation.play(name)
			return
	push_error("Missing animation " + suffix)
func _update_camera() -> void:
	var target := Vector3(0, 1.58 if close_up else 0.96, 0)
	var distance := 0.85 if close_up else 3.1
	camera.position = target + Vector3(sin(yaw)*distance, 0.03, cos(yaw)*distance)
	camera.look_at(target)
func _process(delta: float) -> void:
	if camera == null: return
	yaw += (float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)))*delta
	_update_camera()
func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo: return
	match event.physical_keycode:
		KEY_SPACE:
			walking = not walking
			_play("Walk_8fps" if walking else "Idle_8fps")
		KEY_F:
			close_up = not close_up
		KEY_ESCAPE:
			get_tree().quit()
func _capture(path: String) -> void:
	for frame in 12: await RenderingServer.frame_post_draw
	var skeletons := actor.find_children("*", "Skeleton3D", true, false)
	if skeletons.is_empty() or skeletons[0].get_bone_count() < 13:
		push_error("Missing real skeleton")
		get_tree().quit(4)
		return
	_play("Walk_8fps")
	var skeleton: Skeleton3D = skeletons[0]
	var leg := skeleton.find_bone("LThigh")
	if leg < 0:
		push_error("Missing walking thigh")
		get_tree().quit(6)
		return
	animation.seek(0.015, true)
	var a := skeleton.get_bone_pose_rotation(leg)
	animation.seek(0.045, true)
	var b := skeleton.get_bone_pose_rotation(leg)
	animation.seek(0.19, true)
	var c := skeleton.get_bone_pose_rotation(leg)
	if not a.is_equal_approx(b) or a.is_equal_approx(c):
		push_error("Walk must hold within a sampled pose and change at the next step")
		get_tree().quit(7)
		return
	print("STEPPED_WALK_PASS")
	animation.seek(capture_phase, true)
	animation.pause()
	for frame in 3: await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(path)
	if capture_cycle:
		for sample in 8:
			animation.seek(float(sample)/8.0, true)
			await RenderingServer.frame_post_draw
			var frame_path := path.get_basename() + "-pose-%02d.png" % sample
			if get_viewport().get_texture().get_image().save_png(frame_path) != OK:
				result = ERR_CANT_CREATE
		print("WALK_CYCLE_CAPTURED 8 poses")
	print("ELENA_NATIVE_REVIEW ", error_string(result), " bones=", skeletons[0].get_bone_count())
	get_tree().quit(0 if result == OK else 5)
