extends Node
## NPC-ACTOR-3D-001: floor routes, the walker, and the rigged walking actor.
##
## Covers (1) NpcRoutes on the real plan: every room reaches every other,
## routes stay inside rooms, are symmetric and use the doorways; (2) NpcWalker
## movement maths; (3) NpcActor3D with the Elena study model: clips, facing,
## animation speed from the pace walked, feet not skating (the walk clip's
## foot travel is measured against CLIP_SPEED); (4) the same routes in the
## real house scene: no wall between consecutive points, a floor under every
## point, and an actor that really walks one across with physics frames.
## Run only through tools/Run-Tests.ps1.

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
const MODEL_PATH: String = "res://assets/models/elena_v7/elena_v7.glb"
const SAMPLE_STEP: float = 0.1

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	_test_routes()
	_test_walker()
	await _test_actor()
	await _test_in_house()
	await _test_demo()
	if failures == 0:
		print("NPC ACTOR 3D TEST: PASS (%d checks)" % checks)
	else:
		print("NPC ACTOR 3D TEST: FAILED %d of %d checks" % [failures, checks])
	get_tree().quit(0 if failures == 0 else 1)


func _room_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for room: Dictionary in HouseLayout.ROOMS:
		ids.append(room["id"])
	return ids


# --- routes -----------------------------------------------------------------

func _test_routes() -> void:
	var ids: Array[StringName] = _room_ids()
	check(ids.size() >= 13, "the plan has its rooms (%d)" % ids.size())
	var worst_ratio: float = 0.0
	var worst_label: String = ""
	for from_room: StringName in ids:
		for to_room: StringName in ids:
			var route: Array[Vector3] = NpcRoutes.route(from_room, to_room)
			var label: String = "%s -> %s" % [from_room, to_room]
			check(not route.is_empty(), "route exists " + label)
			if route.is_empty():
				continue
			check(route[0].is_equal_approx(HouseLayout.room_center(from_room)), "starts at the centre of the first room " + label)
			check(route[route.size() - 1].is_equal_approx(HouseLayout.room_center(to_room)), "ends at the centre of the last room " + label)
			if from_room == to_room:
				check(route.size() == 1, "staying put is a single point " + label)
				continue
			# Symmetric: the way back is the same length.
			var back: Array[Vector3] = NpcRoutes.route(to_room, from_room)
			check(is_equal_approx(NpcRoutes.length(route), NpcRoutes.length(back)), "same length both ways " + label)
			# Never wanders: not much longer than three times the straight line
			# (the L-shaped plan forces some detours).
			var straight: float = route[0].distance_to(route[route.size() - 1])
			# Neighbouring rooms may need a few metres through the doorway, so the
			# measure is the detour beyond the straight line, per metre of it.
			var total: float = NpcRoutes.length(route)
			if total > worst_ratio:
				worst_ratio = total
				worst_label = label
			# Every sample of every leg lies inside a room (not outside the house).
			if not _all_inside(route):
				check(false, "route stays inside the house " + label)
	# The house is 15 x 12.5 m; even the longest trip (a room whose only exit is
	# through another room, to the far end) stays well under 35 m.
	check(worst_ratio < 35.0, "no route is wildly roundabout (longest %.1f m: %s)" % [worst_ratio, worst_label])

	# Doorways really are used: the kitchen and the utility room meet at the
	# doorway of the wall at z = 3, so that route passes through it.
	var utility: Array[Vector3] = NpcRoutes.route(&"utility", &"kitchen")
	check(_passes_near(utility, Vector3(2.5, 0.0, 3.0), 0.01), "utility -> kitchen goes through the doorway at (2.5, 3)")
	var guest: Array[Vector3] = NpcRoutes.route(&"guest_a", &"kitchen")
	check(_passes_near(guest, Vector3(10.5, 0.0, 3.0), 0.01), "guest A leaves by its own doorway")
	check(_passes_near(guest, Vector3(5.0, 0.0, 6.5), 0.01), "and enters the kitchen by its doorway on the hall")
	# Storage is only reachable through the bathroom.
	var storage: Array[Vector3] = NpcRoutes.route(&"corridor", &"storage")
	check(_passes_near(storage, Vector3(13.5, 0.0, 8.0), 0.01) and _passes_near(storage, Vector3(13.5, 0.0, 5.5), 0.01), "storage is reached through the bathroom")
	# Aliases from the old plan resolve to the new rooms.
	var old: Array[Vector3] = NpcRoutes.route(&"guest_a", &"living_room")
	check(not old.is_empty() and old[0].is_equal_approx(HouseLayout.room_center(&"guest_a")), "a canonical room id works")
	check(NpcRoutes.route(&"nowhere", &"kitchen").is_empty(), "an unknown room has no route")
	check(NpcRoutes.route(&"kitchen", &"").is_empty(), "an empty room id has no route")
	# Every route point is on the floor.
	var all_flat: bool = true
	for point: Vector3 in NpcRoutes.route(&"storage", &"living_room"):
		all_flat = all_flat and is_zero_approx(point.y)
	check(all_flat, "route points are on the floor")


func _all_inside(route: Array[Vector3]) -> bool:
	for index: int in range(route.size() - 1):
		var from: Vector3 = route[index]
		var to: Vector3 = route[index + 1]
		var steps: int = maxi(1, ceili(from.distance_to(to) / SAMPLE_STEP))
		for step: int in steps + 1:
			var point: Vector3 = from.lerp(to, float(step) / float(steps))
			if HouseLayout.room_at(point + Vector3.UP * 0.1) == &"":
				return false
	return true


func _passes_near(route: Array[Vector3], point: Vector3, tolerance: float) -> bool:
	for candidate: Vector3 in route:
		if candidate.distance_to(point) <= tolerance:
			return true
	return false


# --- walker -----------------------------------------------------------------

func _test_walker() -> void:
	var walker := NpcWalker.new()
	check(walker.finished and not walker.advance(0.5), "a walker with no route stays finished")
	var straight: Array[Vector3] = [Vector3(0, 0, 0), Vector3(0, 0, 6)]
	walker.speed = 1.2
	walker.start(straight)
	check(not walker.finished and is_equal_approx(walker.remaining(), 6.0), "a route starts with all its length left")
	var elapsed: float = 0.0
	var arrived: bool = false
	var last_remaining: float = walker.remaining()
	var monotonic: bool = true
	while elapsed < 20.0 and not arrived:
		arrived = walker.advance(1.0 / 60.0)
		elapsed += 1.0 / 60.0
		monotonic = monotonic and walker.remaining() <= last_remaining + 0.0001
		last_remaining = walker.remaining()
		check(walker.current_speed <= 1.2 + 0.001, "never faster than the set pace")
		if walker.current_speed > 1.2 + 0.001:
			break
	check(arrived and walker.finished, "the walker arrives")
	check(absf(elapsed - 5.0) < 0.1, "6 m at 1.2 m/s takes 5 s (%.2f s)" % elapsed)
	check(monotonic, "the distance left only shrinks")
	check(walker.position.is_equal_approx(Vector3(0, 0, 6)), "it ends exactly on the last point")
	check(walker.current_speed == 0.0, "it reports zero speed when done")

	# A corner: heading changes by 90 degrees, so it slows and turns, but
	# still follows the route's lines exactly.
	var corner: Array[Vector3] = [Vector3(0, 0, 0), Vector3(0, 0, 3), Vector3(3, 0, 3)]
	walker.yaw = 0.0
	walker.start(corner)
	var min_pace: float = 99.0
	var off_route: float = 0.0
	elapsed = 0.0
	arrived = false
	while elapsed < 30.0 and not arrived:
		arrived = walker.advance(1.0 / 60.0)
		elapsed += 1.0 / 60.0
		if not arrived:
			min_pace = minf(min_pace, walker.current_speed)
		var on_first: float = absf(walker.position.x)
		var on_second: float = absf(walker.position.z - 3.0)
		off_route = maxf(off_route, minf(on_first, on_second))
	check(arrived, "the corner route ends")
	check(min_pace < 1.2 * 0.9, "it slows to round the corner (min %.2f m/s)" % min_pace)
	check(off_route < 0.001, "and never leaves the route's lines (%.4f m)" % off_route)
	check(absf(angle_difference(walker.yaw, PI * 0.5)) < 0.05, "it ends facing along the last leg (+X)")
	check(elapsed > 5.0, "the corner costs a little time (%.2f s for 6 m)" % elapsed)

	# One huge frame crosses several legs and arrives.
	walker.yaw = 0.0
	walker.start(corner)
	check(walker.advance(60.0) and walker.finished, "a huge frame crosses every leg and arrives")
	check(walker.position.is_equal_approx(Vector3(3, 0, 3)), "and lands on the last point")
	# Stopping mid-way.
	walker.start(straight)
	walker.advance(1.0)
	walker.stop()
	check(walker.finished and walker.remaining() == 0.0 and not walker.advance(1.0), "stop ends the walk where it stands")
	# A single point is not a walk.
	var single: Array[Vector3] = [Vector3(4, 0, 4)]
	walker.start(single)
	check(walker.finished and walker.position == Vector3(4, 0, 4), "one point is no route")
	# Zero and negative frame times do nothing.
	walker.start(straight)
	check(not walker.advance(0.0) and not walker.advance(-1.0) and is_equal_approx(walker.remaining(), 6.0), "no time passes for a zero frame")


# --- actor ------------------------------------------------------------------

func _test_actor() -> void:
	var actor := NpcActor3D.new()
	add_child(actor)
	check(not actor.load_model("res://assets/models/nothing/missing.glb"), "a missing model is refused")
	check(actor.model == null and actor.animation == null, "and leaves the actor empty")
	# Walking an empty actor still moves its position (no crash, no clip).
	var short: Array[Vector3] = [Vector3(1, 0, 1), Vector3(1, 0, 2)]
	actor.walk_route(short, 1.0)
	await _frames(70)
	check(not actor.is_walking(), "an actor without a model still completes a route")
	check(actor.position.is_equal_approx(Vector3(1, 0, 2)), "and ends on the last point")
	actor.free()

	actor = NpcActor3D.new()
	add_child(actor)
	check(actor.load_model(MODEL_PATH), "the Elena study model loads")
	if actor.animation == null:
		return
	check(actor.gait == &"idle" and actor.animation.current_animation == String(NpcActor3D.IDLE_CLIP), "it starts idle")
	check(actor.animation.get_animation(NpcActor3D.WALK_CLIP).loop_mode == Animation.LOOP_LINEAR, "the walk clip loops")
	var skeletons: Array[Node] = actor.model.find_children("*", "Skeleton3D", true, false)
	check(skeletons.size() == 1 and (skeletons[0] as Skeleton3D).get_bone_count() == 17, "one skeleton with 17 bones")
	await _measure_feet(actor, skeletons[0] as Skeleton3D)

	var gaits: Array[StringName] = []
	actor.gait_changed.connect(func(g: StringName) -> void: gaits.append(g))
	var arrivals: Array[int] = [0]
	actor.arrived.connect(func() -> void: arrivals[0] += 1)
	# Walk +X for 1.2 m at the clip's pace (3 s).
	var east: Array[Vector3] = [Vector3(0, 0, 0), Vector3(1.2, 0, 0)]
	actor.place(Vector3.ZERO, 0.0)
	actor.walk_route(east, NpcActor3D.CLIP_SPEED)
	check(actor.is_walking() and actor.gait == &"walk", "walking sets the walk gait")
	check(actor.animation.current_animation == String(NpcActor3D.WALK_CLIP), "and plays the walk clip")
	await _frames(30)
	check(absf(actor.rotation.y - PI * 0.5) < 0.05, "it turns to face the way it walks (+X)")
	check(absf(actor.animation.speed_scale - 1.0) < 0.1, "a full-pace walk plays the clip at 1x (%.2f)" % actor.animation.speed_scale)
	await _frames(190)
	check(not actor.is_walking() and actor.gait == &"idle", "it is idle again after arriving")
	check(arrivals[0] == 1, "arrived is emitted once")
	check(gaits == [&"walk", &"idle"], "gaits changed walk then idle (%s)" % str(gaits))
	check(actor.position.is_equal_approx(Vector3(1.2, 0, 0)), "it stands on the last point")
	check(actor.animation.current_animation == String(NpcActor3D.IDLE_CLIP), "and plays the idle clip")

	# A slow walk plays the clip slower; a tiny pace never freezes it.
	actor.place(Vector3.ZERO, 0.0)
	actor.walk_route(east, NpcActor3D.CLIP_SPEED * 0.5)
	await _frames(20)
	check(absf(actor.animation.speed_scale - 0.5) < 0.1, "half pace plays the clip at half speed (%.2f)" % actor.animation.speed_scale)
	actor.walk_route(east, 0.01)
	await _frames(5)
	check(actor.animation.speed_scale >= NpcActor3D.MIN_PLAYBACK - 0.001, "a tiny pace never freezes the clip")
	# Stopping returns to idle where it stands.
	actor.stop()
	check(not actor.is_walking() and actor.gait == &"idle", "stop returns to idle")
	# A route with fewer than two points just places it.
	var one: Array[Vector3] = [Vector3(9, 0, 9)]
	actor.walk_route(one, 1.0)
	check(not actor.is_walking() and actor.position.is_equal_approx(Vector3(9, 0, 9)), "a one-point route just places the actor")
	var none: Array[Vector3] = []
	actor.walk_route(none, 1.0)
	check(not actor.is_walking(), "an empty route does nothing")
	# Loading a second model replaces the first.
	check(actor.load_model(MODEL_PATH), "a model can be loaded again")
	check(actor.find_children("*", "AnimationPlayer", true, false).size() >= 1, "the actor has an animation player")
	actor.free()


## Measures how fast the walk clip moves a foot backwards over the ground and
## compares it with NpcActor3D.CLIP_SPEED.
func _measure_feet(actor: NpcActor3D, skeleton: Skeleton3D) -> void:
	var clip: Animation = actor.animation.get_animation(NpcActor3D.WALK_CLIP)
	var length: float = clip.length
	var bone: int = skeleton.find_bone("LFoot")
	check(bone >= 0, "the skeleton has a left foot")
	if bone < 0:
		return
	actor.animation.play(NpcActor3D.WALK_CLIP, 0.0)
	await _frames(2)
	actor.animation.pause()
	var samples: int = 48
	var xs: Array[Vector3] = []
	for index: int in samples + 1:
		actor.animation.seek(length * float(index) / float(samples), true)
		skeleton.force_update_all_bone_transforms()
		xs.append(skeleton.get_bone_global_pose(bone).origin)
	# Stance: the foot slides back from its furthest forward point to its
	# furthest back point while on the floor; the body moves over the ground
	# as fast as that (the clip is stepped at 8 fps, so this is an average).
	var dt: float = length / float(samples)
	var front: int = 0
	var z_low: float = INF
	for index: int in samples:
		if xs[index].z > xs[front].z + 0.003:
			front = index
		z_low = minf(z_low, xs[index].z)
	var back: int = -1
	for offset: int in samples:
		if xs[(front + offset) % samples].z <= z_low + 0.003:
			back = offset
			break
	check(back > 0, "the foot slides back over the ground during the walk clip")
	if back <= 0:
		return
	var travel: float = xs[front].z - z_low
	var stance_seconds: float = float(back) * dt
	var measured: float = travel / stance_seconds
	print("NPC ACTOR 3D: walk clip %.3f s, foot slides back %.3f m in %.3f s = %.3f m/s (CLIP_SPEED %.3f)" % [length, travel, stance_seconds, measured, NpcActor3D.CLIP_SPEED])
	check(absf(measured - NpcActor3D.CLIP_SPEED) / NpcActor3D.CLIP_SPEED < 0.2, "CLIP_SPEED matches the clip's foot travel (measured %.3f m/s)" % measured)
	actor.animation.play(NpcActor3D.IDLE_CLIP)

# --- in the real house -------------------------------------------------------

func _test_in_house() -> void:
	GameState.new_campaign(21)
	var house: Node = SCENE.instantiate()
	add_child(house)
	await _frames(10)
	var space: PhysicsDirectSpaceState3D = house.get_world_3d().direct_space_state
	var excluded: Array[RID] = []
	for node: Node in house.find_children("*", "CollisionObject3D", true, false):
		if node is RoomDoor or node is PlayerController:
			excluded.append((node as CollisionObject3D).get_rid())
	var blocked: Array[String] = []
	var unsupported: Array[String] = []
	var ids: Array[StringName] = _room_ids()
	var routes: int = 0
	for from_room: StringName in ids:
		for to_room: StringName in ids:
			if from_room == to_room:
				continue
			var route: Array[Vector3] = NpcRoutes.route(from_room, to_room)
			routes += 1
			for index: int in route.size():
				var floor_hit: Dictionary = _ray(space, route[index] + Vector3.UP * 0.5, route[index] + Vector3.DOWN * 0.5, excluded)
				if floor_hit.is_empty() or absf(float(floor_hit["position"].y)) > 0.05:
					unsupported.append("%s->%s point %d" % [from_room, to_room, index])
				if index < route.size() - 1:
					# A body-height ray and a knee-height ray must not meet a wall.
					for height: float in [0.35, 0.9, 1.6]:
						var hit: Dictionary = _ray(space, route[index] + Vector3.UP * height, route[index + 1] + Vector3.UP * height, excluded)
						if not hit.is_empty():
							blocked.append("%s->%s leg %d at %.2f m" % [from_room, to_room, index, height])
							break
	check(routes >= 150, "all room pairs were checked (%d routes)" % routes)
	check(unsupported.is_empty(), "every route point has floor under it (%s)" % str(unsupported.slice(0, 3)))
	check(blocked.is_empty(), "no wall between consecutive route points (%d blocked, first: %s)" % [blocked.size(), str(blocked.slice(0, 3))])

	# An actor really walks one of the longest routes with physics frames.
	var actor := NpcActor3D.new()
	house.add_child(actor)
	check(actor.load_model(MODEL_PATH), "the model loads inside the house")
	var route: Array[Vector3] = NpcRoutes.route(&"utility", &"daniel_bedroom")
	check(route.size() >= 6, "utility -> Daniel's bedroom is a multi-room route (%d points)" % route.size())
	var length: float = NpcRoutes.length(route)
	actor.place(route[0], 0.0)
	var arrived: Array[bool] = [false]
	actor.arrived.connect(func() -> void: arrived[0] = true)
	actor.walk_route(route, NpcActor3D.WALK_PACE)
	# Quicker than real time; the game clock (delta) is scaled the same way.
	const SCALE: float = 6.0
	Engine.time_scale = SCALE
	var frames: int = 0
	var seen_rooms: Array[StringName] = []
	var worst_clear: float = 0.0
	while not arrived[0] and frames < 60 * 60:
		await get_tree().physics_frame
		frames += 1
		var room: StringName = HouseLayout.room_at(actor.position + Vector3.UP * 0.1)
		if room == &"":
			worst_clear += 1.0
		elif seen_rooms.is_empty() or seen_rooms[seen_rooms.size() - 1] != room:
			seen_rooms.append(room)
	Engine.time_scale = 1.0
	var seconds: float = float(frames) / 60.0 * SCALE
	check(arrived[0], "the actor reaches the far room")
	check(worst_clear == 0.0, "the actor is always inside a room on the way (%d frames outside)" % int(worst_clear))
	check(seconds > length / NpcActor3D.WALK_PACE and seconds < length / NpcActor3D.WALK_PACE * 1.4 + 1.0, "the walk takes a believable time (%.1f s for %.1f m)" % [seconds, length])
	check(seen_rooms.size() >= 4 and seen_rooms[0] == &"utility" and seen_rooms[seen_rooms.size() - 1] == &"daniel_bedroom", "it passes through the rooms in order (%s)" % str(seen_rooms))
	check(actor.position.is_equal_approx(route[route.size() - 1]), "it ends on the last point")
	house.queue_free()
	await _frames(2)


func _ray(space: PhysicsDirectSpaceState3D, from: Vector3, to: Vector3, excluded: Array[RID]) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, 1, excluded)
	query.hit_from_inside = true
	return space.intersect_ray(query)


func _frames(count: int) -> void:
	for _i: int in count:
		await get_tree().physics_frame

# --- the dev demo ------------------------------------------------------------

func _test_demo() -> void:
	var script: GDScript = load("res://scripts/dev/npc_walk_demo.gd")
	var tour: Array = script.get_script_constant_map()["TOUR"]
	check(tour.size() >= 8, "the demo tour visits several rooms (%d stops)" % tour.size())
	var ids: Array[StringName] = _room_ids()
	for index: int in tour.size():
		var from: StringName = tour[index]
		var to: StringName = tour[(index + 1) % tour.size()]
		check(ids.has(from), "tour stop %s is a room of the plan" % from)
		check(from == to or NpcRoutes.route(from, to).size() >= 2, "the tour can walk %s -> %s" % [from, to])
	var demo: Node = load("res://scenes/dev/npc_walk_demo.tscn").instantiate()
	add_child(demo)
	await _frames(90)
	var actor: NpcActor3D = demo.actor
	check(actor != null and actor.animation != null, "the demo built its actor with the model")
	check(actor.is_walking() and actor.gait == &"walk", "after its short wait the demo actor is walking")
	check(actor.position.distance_to(HouseLayout.room_center(&"living_room")) > 0.05, "and has left the start point")
	demo.queue_free()
	await _frames(2)
