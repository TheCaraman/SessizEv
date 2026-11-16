class_name DialogueRunner
extends Node
## Plays authored, branching conversations from JSON files in
## resources/dialogue/. Deterministic: no generated text.
##
## File format:
## {
##   "start": "node_id",
##   "nodes": {
##     "node_id": {
##       "speaker": "elena_ward",      // character id, or "" for narration
##       "text": "TRANSLATION_KEY",
##       "enter": [ effect, ... ],      // applied when the node is shown
##       "next": "other_node",          // used when there are no choices
##       "choices": [
##         { "id": "admit", "text": "KEY", "next": "node_or_end",
##           "if_flag": "key", "if_not_flag": "key", "effects": [ effect, ... ],
##           "requires_free_bed": true, "else_next": "node_when_house_is_full" }
##       ],
##       "bed_choices": {               // instead of "choices": pick a bed
##         "npc": "id", "next": "node_after", "back": "node_if_cancelled",
##         "effects": [ effect, ... ]    // applied after the bed is assigned
##       }
##     }
##   }
## }
## A "next" of "end" (or none) finishes the conversation.
##
## Effects:
##   {"type": "flag", "key": "name", "value": true}
##   {"type": "trust", "npc": "id", "delta": 5}
##   {"type": "time", "minutes": 5}
##   {"type": "admit", "npc": "id", "bed": "bed_id"}
##   {"type": "remove", "npc": "id", "status": "rejected"}
##   {"type": "clear_visitor"}

signal node_changed(node: Dictionary)
signal ended(dialogue_id: String)

const DIALOGUE_PATH: String = "res://resources/dialogue/%s.json"
const END: String = "end"

var _dialogue_id: String = ""
var _nodes: Dictionary = {}
var _node_id: String = ""


func is_active() -> bool:
	return _dialogue_id != ""


func get_dialogue_id() -> String:
	return _dialogue_id


func get_node_id() -> String:
	return _node_id


## True if a conversation file with this id exists.
static func exists(dialogue_id: String) -> bool:
	return FileAccess.file_exists(DIALOGUE_PATH % dialogue_id)


## Starts a conversation. Returns false if the file is missing or malformed.
func start(dialogue_id: String) -> bool:
	var path: String = DIALOGUE_PATH % dialogue_id
	if not FileAccess.file_exists(path):
		push_error("DialogueRunner: missing %s" % path)
		return false
	var json := JSON.new()
	if json.parse(FileAccess.get_file_as_string(path)) != OK:
		push_error("DialogueRunner: %s line %d: %s" % [path, json.get_error_line(), json.get_error_message()])
		return false
	if not json.data is Dictionary or not (json.data as Dictionary).get("nodes") is Dictionary:
		push_error("DialogueRunner: %s is not a valid dialogue" % path)
		return false
	_dialogue_id = dialogue_id
	_nodes = json.data["nodes"]
	EventBus.dialogue_started.emit(_dialogue_id)
	_enter(str(json.data.get("start", "")))
	return true


## Ends the conversation at once without applying anything further. For
## leaving a scene or resetting between test cases; not a player action.
func cancel() -> void:
	if is_active():
		_finish()


## The node on screen:
## {"speaker", "text", "choices": [{"id", "text", "args"}]}.
## "text" values are translation keys; "args" fills their {placeholders}.
## Choices whose conditions fail are left out. A node without choices gets a
## single "continue" choice.
func get_current() -> Dictionary:
	if not is_active():
		return {}
	var node: Dictionary = _nodes[_node_id]
	var shown: Array[Dictionary] = []
	for choice: Dictionary in _build_choices(node):
		shown.append({"id": choice["id"], "text": choice["text"], "args": choice.get("args", {})})
	if shown.is_empty():
		shown.append({"id": "continue", "text": "DLG_CONTINUE", "args": {}})
	return {
		"speaker": str(node.get("speaker", "")),
		"text": str(node.get("text", "")),
		"choices": shown,
	}


## Picks the choice at [param index] among the visible ones.
func choose(index: int) -> void:
	if not is_active():
		return
	var node: Dictionary = _nodes[_node_id]
	var choices: Array[Dictionary] = _build_choices(node)
	if choices.is_empty():
		_go(str(node.get("next", END)))
		return
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	if choice.has("bed"):
		# The bed may have been taken since the list was shown; if so, stay.
		if not GameState.admit(str(choice["npc"]), str(choice["bed"])):
			node_changed.emit(get_current())
			return
	_apply(choice.get("effects", []))
	_go(str(choice.get("next", END)))


## Picks a visible choice by its id. Returns false if it is not available.
func choose_by_id(choice_id: String) -> bool:
	var choices: Array = get_current().get("choices", [])
	for i: int in choices.size():
		if choices[i]["id"] == choice_id:
			choose(i)
			return true
	return false


## Every choice the player can pick on [param node], fully resolved:
## conditions applied, a full house redirected, beds listed.
func _build_choices(node: Dictionary) -> Array[Dictionary]:
	var built: Array[Dictionary] = []
	if node.has("bed_choices"):
		var spec: Dictionary = node["bed_choices"]
		for bed_id: String in GameState.get_free_beds():
			var room_id: String = GameState.bed_room(bed_id)
			var room: Dictionary = HouseLayout.get_room(StringName(room_id))
			var args: Dictionary = {
				"room": tr(room.get("name_key", room_id)),
				"n": GameState.bed_number(bed_id),
			}
			var text: String = "BED_CHOICE"
			var roommates: Array[String] = GameState.get_room_occupants(room_id)
			if not roommates.is_empty():
				text = "BED_CHOICE_SHARED"
				args["name"] = Roster.get_display_name(roommates[0])
			built.append({
				"id": "bed:" + bed_id, "text": text, "args": args,
				"bed": bed_id, "npc": str(spec.get("npc", "")),
				"next": str(spec.get("next", END)), "effects": spec.get("effects", []),
			})
		built.append({"id": "back", "text": "DLG_BACK", "next": str(spec.get("back", END))})
		return built

	for choice: Dictionary in node.get("choices", []):
		if choice.has("if_flag") and not GameState.get_flag(str(choice["if_flag"])):
			continue
		if choice.has("if_not_flag") and GameState.get_flag(str(choice["if_not_flag"])):
			continue
		var entry: Dictionary = {
			"id": str(choice.get("id", "")), "text": str(choice.get("text", "")),
			"next": str(choice.get("next", END)), "effects": choice.get("effects", []),
		}
		# With no bed to offer, the choice explains why instead of admitting.
		if choice.get("requires_free_bed", false) and GameState.get_free_beds().is_empty():
			entry["next"] = str(choice.get("else_next", END))
			entry["effects"] = []
		built.append(entry)
	return built


func _go(next_id: String) -> void:
	if next_id == END or next_id == "" or not _nodes.has(next_id):
		if next_id != END and next_id != "":
			push_error("DialogueRunner: '%s' has no node '%s'" % [_dialogue_id, next_id])
		_finish()
		return
	_enter(next_id)


func _enter(node_id: String) -> void:
	if not _nodes.has(node_id):
		push_error("DialogueRunner: '%s' has no node '%s'" % [_dialogue_id, node_id])
		_finish()
		return
	_node_id = node_id
	_apply((_nodes[node_id] as Dictionary).get("enter", []))
	node_changed.emit(get_current())


func _finish() -> void:
	var finished: String = _dialogue_id
	_dialogue_id = ""
	_nodes = {}
	_node_id = ""
	ended.emit(finished)
	EventBus.dialogue_ended.emit(finished)


func _apply(effects: Array) -> void:
	for effect: Dictionary in effects:
		match str(effect.get("type", "")):
			"flag":
				GameState.set_flag(str(effect["key"]), effect.get("value", true))
			"trust":
				GameState.change_trust(str(effect["npc"]), int(effect["delta"]))
			"time":
				GameState.advance_minutes(int(effect["minutes"]))
			"admit":
				if not GameState.admit(str(effect["npc"]), str(effect["bed"])):
					push_error("DialogueRunner: could not give %s the bed %s" % [effect["npc"], effect["bed"]])
			"remove":
				GameState.remove_npc(str(effect["npc"]), str(effect.get("status", "rejected")))
			"clear_visitor":
				GameState.set_visitor("")
			_:
				push_error("DialogueRunner: unknown effect %s" % [effect])
