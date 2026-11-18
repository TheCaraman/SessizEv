extends Node
## Registers the game's input actions at startup (autoload: InputSetup).
##
## Actions are defined in code rather than in project.godot so that default
## bindings live in one readable place and rebinding has a single entry point.
## See docs/DecisionLog.md, V-009.

## Action name -> default physical key.
## Physical keys keep WASD in the same place on non-QWERTY layouts.
const DEFAULT_BINDINGS: Dictionary = {
	&"move_forward": KEY_W,
	&"move_back": KEY_S,
	&"move_left": KEY_A,
	&"move_right": KEY_D,
	&"walk_fast": KEY_SHIFT,
	&"interact": KEY_E,
	&"wrist": KEY_TAB,
	&"journal": KEY_J,
	&"inventory": KEY_I,
	&"pause": KEY_ESCAPE,
}


func _ready() -> void:
	for action: StringName in DEFAULT_BINDINGS:
		_ensure_action(action, DEFAULT_BINDINGS[action] as Key)


## Replaces every key bound to [param action] with [param keycode].
## Returns false if the action does not exist.
func rebind(action: StringName, keycode: Key) -> bool:
	if not InputMap.has_action(action):
		return false
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, _make_key_event(keycode))
	EventBus.input_binding_changed.emit(action)
	return true


## Restores the default key for every action.
func reset_to_defaults() -> void:
	for action: StringName in DEFAULT_BINDINGS:
		rebind(action, DEFAULT_BINDINGS[action] as Key)


## Returns the physical key currently bound to [param action],
## or KEY_NONE if the action has no key event.
func get_bound_key(action: StringName) -> Key:
	if not InputMap.has_action(action):
		return KEY_NONE
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			return (event as InputEventKey).physical_keycode
	return KEY_NONE


## Human-readable name of the key bound to [param action], for prompts.
func get_key_label(action: StringName) -> String:
	return OS.get_keycode_string(get_bound_key(action))


func _ensure_action(action: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	if InputMap.action_get_events(action).is_empty():
		InputMap.action_add_event(action, _make_key_event(keycode))


func _make_key_event(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	return event
