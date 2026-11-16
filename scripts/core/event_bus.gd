extends Node
## Global signal hub (autoload: EventBus).
##
## Systems emit and listen here instead of holding references to each other.
## Only cross-system signals belong in this file; signals used inside a single
## scene stay on that scene's own nodes.

## The text of the contextual interaction prompt changed.
## An empty string hides the prompt.
@warning_ignore("unused_signal")
signal interaction_prompt_changed(text: String)

## A key binding was changed through InputSetup.rebind().
@warning_ignore("unused_signal")
signal input_binding_changed(action: StringName)
