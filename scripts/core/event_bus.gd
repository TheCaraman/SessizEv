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

## Something asks for a room's 2D scene to be shown (for example a door).
@warning_ignore("unused_signal")
signal room_view_requested(room_id: StringName)

## The 2D scene of a room is now on screen.
@warning_ignore("unused_signal")
signal room_view_opened(room_id: StringName)

## The 2D room scene was closed and the player is back in the corridor.
@warning_ignore("unused_signal")
signal room_view_closed(room_id: StringName)

## A key binding was changed through InputSetup.rebind().
@warning_ignore("unused_signal")
signal input_binding_changed(action: StringName)
