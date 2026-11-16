class_name InteractionRay
extends RayCast3D
## Finds what the player is looking at and lets them use it.
##
## Anything with an interact(player) method is usable; if it also has
## get_interaction_prompt() that text is shown while it is targeted
## (docs/DecisionLog.md, V-019). The ray is a child of the player's camera.

var _player: PlayerController
var _target: Object = null
var _prompt: String = ""


func _ready() -> void:
	_player = owner as PlayerController
	add_exception(_player)


func _physics_process(_delta: float) -> void:
	var target: Object = null
	if _player.control_enabled and is_colliding():
		var collider: Object = get_collider()
		if collider != null and collider.has_method(&"interact"):
			target = collider
	_target = target

	var prompt: String = ""
	if _target != null and _target.has_method(&"get_interaction_prompt"):
		prompt = _target.call(&"get_interaction_prompt")
	if prompt != _prompt:
		_prompt = prompt
		EventBus.interaction_prompt_changed.emit(_prompt)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(&"interact"):
		return
	if _target == null or not _player.control_enabled:
		return
	_target.call(&"interact", _player)
	get_viewport().set_input_as_handled()


## The object currently targeted, or null.
func get_target() -> Object:
	return _target
