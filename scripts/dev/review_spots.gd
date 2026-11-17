class_name ReviewSpots
extends RefCounted
## Shared helpers for developer capture scenes (SINGLE-STOREY-AUDIT-001).
##
## 1. isolated(): every capture scene that starts a campaign or touches
##    Settings must run in an isolated project copy (Run-Tests -KeepProjectCopy
##    writes override.cfg with a TheQuietHours-Tests/ user dir). Run against
##    the real project, these scenes could overwrite the owner's saves or
##    settings, which already happened once.
## 2. Viewpoints derived from HouseLayout and the front door, so the captures
##    follow the current plan instead of stale fixed coordinates.

const TEST_USER_DIR_PREFIX: String = "TheQuietHours-Tests/"


## True inside an isolated copy. Otherwise reports the problem, quits with
## code 1 and returns false; callers return at once.
static func isolated(tree: SceneTree) -> bool:
	if is_isolated():
		return true
	push_error("Capture scenes run only in an isolated project copy (tools/Run-Tests.ps1 -KeepProjectCopy); refusing to touch real saves or settings.")
	tree.quit(1)
	return false


## Whether this run uses an isolated test user directory.
static func is_isolated() -> bool:
	var user_dir: String = str(ProjectSettings.get_setting("application/config/custom_user_dir_name", ""))
	return user_dir.begins_with(TEST_USER_DIR_PREFIX)


## Whether the plan has a playable floor with this index.
static func has_floor(floor_index: int) -> bool:
	if floor_index >= 0 and floor_index < HouseLayout.FLOOR_COUNT:
		return true
	push_warning("The current plan has %d floor(s); floor %d does not exist." % [HouseLayout.FLOOR_COUNT, floor_index])
	return false


## The front door opening: {"x", "z"} of its centre on the outer wall.
static func front_door() -> Dictionary:
	for wall: Dictionary in HouseLayout.WALLS:
		for opening: Dictionary in wall.get("openings", []):
			if opening.get("front", false):
				if wall["axis"] == "x":
					return {"x": float(opening["pos"]), "z": float(wall["at"])}
				return {"x": float(wall["at"]), "z": float(opening["pos"])}
	return {}


## Standing point just inside the front door, [param depth] metres in, at
## floor level (+0.05 so the body settles onto the floor).
static func inside_front_door(depth: float = 1.0) -> Vector3:
	var door: Dictionary = front_door()
	var center: Vector3 = HouseLayout.room_center(&"vestibule")
	var inward: float = signf(center.z - float(door["z"]))
	return Vector3(float(door["x"]), 0.05, float(door["z"]) + inward * depth)


## Yaw (radians) that faces from [param from] toward [param to] on the floor.
static func yaw_toward(from: Vector3, to: Vector3) -> float:
	var d: Vector3 = to - from
	return atan2(-d.x, -d.z)


## Centre of a room at floor level (+0.05).
static func room_spot(id: StringName) -> Vector3:
	return HouseLayout.room_center(id) + Vector3(0.0, 0.05, 0.0)
