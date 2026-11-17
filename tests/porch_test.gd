extends Node
## IMMERSION I-05 (street part): the porch set in front of the main door.

const SCENE: PackedScene = preload("res://scenes/main/house_blockout.tscn")
## Where a visitor stands for the door view; nothing may stand in it.
const VISITOR_ZONE: AABB = AABB(Vector3(6.7, 0.02, 12.9), Vector3(1.6, 2.0, 1.1))

var checks: int = 0
var failures: int = 0


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL: " + label)


func _ready() -> void:
	GameState.new_campaign(11)
	GameState.minutes = 1350
	var scene: Node = SCENE.instantiate()
	add_child(scene)
	await get_tree().process_frame
	var porch: Node3D = scene.find_child("PorchSet", true, false) as Node3D
	check(porch != null, "the porch set is built in front of the house")
	if porch == null:
		_finish()
		return

	var blocking: Array[String] = []
	var bodies: int = 0
	for node: Node in porch.find_children("*", "", true, false):
		if node is CollisionObject3D:
			bodies += 1
		if node is MeshInstance3D:
			var box: AABB = (node as MeshInstance3D).global_transform * (node as MeshInstance3D).get_aabb()
			if box.intersects(VISITOR_ZONE):
				blocking.append(str(porch.get_path_to(node)))
	check(blocking.is_empty(), "the visitor's place on the porch is clear (%s)" % ", ".join(blocking))
	check(bodies == 0, "the porch set is scenery only: no collision bodies")
	check(porch.global_position.distance_to(Vector3.ZERO) < 0.001, "porch set is authored in world coordinates")

	var lantern: OmniLight3D = porch.get_node("PorchLantern")
	var street: OmniLight3D = porch.get_node("StreetSupply/StreetLamp")
	var daylight: OmniLight3D = porch.get_node("PorchDaylight")
	check(lantern.is_in_group("electric_lights") and lantern.is_in_group("local_lamp_lights"), "porch lantern is on the house supply")
	check(street.is_in_group("moon_lights") and not street.is_in_group("electric_lights"), "street lamp is not on the house supply")
	check(daylight.is_in_group("window_lights"), "porch daylight follows the clock")
	check(lantern.visible and lantern.light_energy > 0.0, "porch lantern burns at night with power")
	check(street.visible and street.light_energy > 0.0, "street lamp burns at night")

	GameState.power_incident = {"state": "outage", "cause": "loose_connection", "inspected": []}
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	await get_tree().process_frame
	check(not lantern.visible, "a power cut puts the porch lantern out")
	check(street.is_visible_in_tree(), "a house-only fault leaves the street lamp lit")

	GameState.power_incident = {"state": "outage", "cause": "grid_outage", "inspected": []}
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	await get_tree().process_frame
	check(not lantern.visible and not street.is_visible_in_tree(), "a grid outage darkens the porch and the street")
	check((porch.get_node("StreetLampHeadDark") as Node3D).visible, "the dead lamp head still stands there")

	GameState.power_incident = {"state": "restored", "cause": "grid_outage", "inspected": []}
	GameState.minutes = 1360
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	await get_tree().process_frame
	check(street.is_visible_in_tree(), "the street lamp returns when the outage is over")

	GameState.power_incident = {}
	GameState.minutes = 660
	EventBus.time_changed.emit(GameState.day, GameState.minutes)
	await get_tree().process_frame
	check(not street.visible, "the street lamp is off by day")
	check(daylight.light_energy > 0.5, "the porch is lit by day")
	_finish()


func _finish() -> void:
	if failures == 0:
		print("PORCH TEST: PASS (%d checks)" % checks)
	get_tree().quit(0 if failures == 0 else 1)
