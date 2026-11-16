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

@warning_ignore("unused_signal")
signal door_transition_changed(active: bool)

## The campaign clock moved. [param minutes] is minutes since midnight.
@warning_ignore("unused_signal")
signal time_changed(day: int, minutes: int)

## The time of day crossed into another phase (GameState.Phase).
@warning_ignore("unused_signal")
signal phase_changed(phase: int)

## A new day began, or a campaign was started or loaded.
@warning_ignore("unused_signal")
signal day_started(day: int)

## Someone arrived at, or left, the front door. Empty id means nobody.
@warning_ignore("unused_signal")
signal visitor_changed(npc_id: String)

## The player used the front door while somebody was waiting outside.
@warning_ignore("unused_signal")
signal front_door_used

## Somebody moved in, left, or was removed.
@warning_ignore("unused_signal")
signal residents_changed

## Supplies were used or gained.
@warning_ignore("unused_signal")
signal resources_changed

## A conversation began or finished.
@warning_ignore("unused_signal")
signal dialogue_started(dialogue_id: String)
@warning_ignore("unused_signal")
signal dialogue_ended(dialogue_id: String)

## Asks the HUD to show a short message for a few seconds.
@warning_ignore("unused_signal")
signal notice_requested(text: String)

## A key binding was changed through InputSetup.rebind().
@warning_ignore("unused_signal")
signal input_binding_changed(action: StringName)

@warning_ignore("unused_signal")
signal shelter_view_requested
@warning_ignore("unused_signal")
signal shelter_view_opened
@warning_ignore("unused_signal")
signal shelter_view_closed

@warning_ignore("unused_signal")
signal review_requested(text: String)

@warning_ignore("unused_signal")
signal accusation_requested(room_id: String, npc_id: String)
