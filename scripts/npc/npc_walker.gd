class_name NpcWalker
extends RefCounted
## NPC-ACTOR-3D-001: follows a floor route at a walking pace, turning smoothly
## at the corners. Pure movement maths (no nodes, no physics), so the same
## walker serves any model and can be tested without a scene.
##
## Corners: the body keeps walking while it turns, but slows down when the
## heading it needs is far from the way it faces, so it rounds a corner
## instead of sliding sideways or snapping round.

## Fastest turn, radians per second.
const TURN_RATE: float = 5.0
## Facing error (radians) above which the walker slows for the turn.
const SLOW_ANGLE: float = 0.5
## Fraction of full pace while facing far from the heading.
const TURN_PACE: float = 0.3
## A waypoint counts as reached within this many metres.
const ARRIVE_DISTANCE: float = 0.02

var position: Vector3 = Vector3.ZERO
## Facing, radians around Y; 0 faces +Z (the way the imported model looks).
var yaw: float = 0.0
## Full walking pace, metres per second.
var speed: float = 1.2
var finished: bool = true

var _path: Array[Vector3] = []
var _next: int = 0
## Pace actually used on the last advance (for matching the animation).
var current_speed: float = 0.0


## Starts a route. The first point is where the walker already is; with a
## single point it just stands there. Heights are kept as given.
func start(points: Array[Vector3]) -> void:
	_path = points.duplicate()
	_next = 1
	finished = _path.size() < 2
	current_speed = 0.0
	if not _path.is_empty():
		position = _path[0]


func stop() -> void:
	_path = []
	_next = 0
	finished = true
	current_speed = 0.0


## Length of the route still to walk, metres.
func remaining() -> float:
	if finished:
		return 0.0
	var total: float = position.distance_to(_path[_next])
	for index: int in range(_next, _path.size() - 1):
		total += _path[index].distance_to(_path[index + 1])
	return total


## The unit heading toward the current waypoint (flat), or ZERO.
func heading() -> Vector3:
	if finished:
		return Vector3.ZERO
	var flat: Vector3 = _path[_next] - position
	flat.y = 0.0
	return flat.normalized()


## Moves for [param delta] seconds. Returns true the moment the last point is
## reached.
func advance(delta: float) -> bool:
	if finished or delta <= 0.0:
		current_speed = 0.0
		return false
	var budget: float = delta
	var travelled: float = 0.0
	# Several short legs can be crossed in one long frame.
	while budget > 0.0 and not finished:
		var to_next: Vector3 = _path[_next] - position
		var flat: Vector3 = Vector3(to_next.x, 0.0, to_next.z)
		if flat.length() <= ARRIVE_DISTANCE:
			position = _path[_next]
			_next += 1
			if _next >= _path.size():
				finished = true
			continue
		var wanted: float = atan2(flat.x, flat.z)
		var error: float = absf(angle_difference(yaw, wanted))
		yaw = wrapf(yaw + clampf(angle_difference(yaw, wanted), -TURN_RATE * budget, TURN_RATE * budget), -PI, PI)
		var pace: float = speed * (TURN_PACE if error > SLOW_ANGLE else 1.0)
		var reach: float = pace * budget
		var leg: float = to_next.length()
		if reach >= leg:
			budget -= leg / pace
			travelled += leg
			position = _path[_next]
			_next += 1
			if _next >= _path.size():
				finished = true
		else:
			position += to_next / leg * reach
			travelled += reach
			budget = 0.0
	current_speed = travelled / delta
	if finished:
		current_speed = 0.0
		return true
	return false
