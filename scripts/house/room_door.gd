class_name RoomDoor
extends StaticBody3D
## A corridor door. Using it shows the 2D scene of the room behind it.
##
## The door never swings open in 3D: rooms are not walkable spaces
## (docs/DecisionLog.md, K-011). HouseBuilder creates the collision and
## the visible door; this script only holds behaviour.

## Room shown when the door is used. Empty for doors that lead nowhere yet.
var room_id: StringName = &""
## A locked door shows a "locked" prompt and cannot be used.
var locked: bool = false


func get_interaction_prompt() -> String:
	if locked or room_id == &"":
		return tr("PROMPT_LOCKED")
	var room: Dictionary = HouseLayout.get_room(room_id)
	return tr("PROMPT_ENTER_ROOM").format({
		"key": InputSetup.get_key_label(&"interact"),
		"room": tr(room.get("name_key", "")),
	})


func interact(_player: Node) -> void:
	if locked or room_id == &"":
		return
	EventBus.room_view_requested.emit(room_id)
