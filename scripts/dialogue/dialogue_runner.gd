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
##           "if_flag": "key", "if_not_flag": "key", "effects": [ effect, ... ] }
##       ]
##     }
##   }
## }
## A "next" of "end" (or none) finishes the conversation.
##
## Effects:
##   {"type": "flag", "key": "name", "value": true}
##   {"type": "trust", "npc": "id", "delta": 5}
##   {"type": "time", "minutes": 5}
##   {"type": "admit", "npc": "id", "room": "room_id"}
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


## Starts a conversation. Returns false if the file is missing or malformed.
func start(dialogue_id: String) -> bool:
	var path: String = DIALOGUE_PATH % dialogue_id
	if not FileAccess.file_exists(path):
		push_error("DialogueRunner: missing %s" % path)
		return false
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or not (parsed as Dictionary).get("nodes") is Dictionary:
		push_error("DialogueRunner: %s is not a valid dialogue" % path)
		return false
	_dialogue_id = dialogue_id
	_nodes = parsed["nodes"]
	EventBus.dialogue_started.emit(_dialogue_id)
	_enter(str(parsed.get("start", "")))
	return true


## The node on screen: {"speaker", "text", "choices": [{"id", "text"}]}.
## Choices whose conditions fail are left out. A node without choices gets a
## single "continue" choice.
func get_current() -> Dictionary:
	if not is_active():
		return {}
	var node: Dictionary = _nodes[_node_id]
	var choices: Array[Dictionary] = []
	for choice: Dictionary in _visible_choices(node):
		choices.append({"id": str(choice.get("id", "")), "text": str(choice.get("text", ""))})
	if choices.is_empty():
		choices.append({"id": "continue", "text": "DLG_CONTINUE"})
	return {
		"speaker": str(node.get("speaker", "")),
		"text": str(node.get("text", "")),
		"choices": choices,
	}


## Picks the choice at [param index] among the visible ones.
func choose(index: int) -> void:
	if not is_active():
		return
	var node: Dictionary = _nodes[_node_id]
	var choices: Array[Dictionary] = _visible_choices(node)
	if choices.is_empty():
		_go(str(node.get("next", END)))
		return
	if index < 0 or index >= choices.size():
		return
	var choice: Dictionary = choices[index]
	_apply(choice.get("effects", []))
	_go(str(choice.get("next", END)))


## Picks a visible choice by its id. Returns false if it is not available.
func choose_by_id(choice_id: String) -> bool:
	var current: Dictionary = get_current()
	var choices: Array = current.get("choices", [])
	for i: int in choices.size():
		if choices[i]["id"] == choice_id:
			choose(i)
			return true
	return false


func _visible_choices(node: Dictionary) -> Array[Dictionary]:
	var visible: Array[Dictionary] = []
	for choice: Dictionary in node.get("choices", []):
		if choice.has("if_flag") and not GameState.get_flag(str(choice["if_flag"])):
			continue
		if choice.has("if_not_flag") and GameState.get_flag(str(choice["if_not_flag"])):
			continue
		visible.append(choice)
	return visible


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
				GameState.admit(str(effect["npc"]), str(effect["room"]))
			"remove":
				GameState.remove_npc(str(effect["npc"]), str(effect.get("status", "rejected")))
			"clear_visitor":
				GameState.set_visitor("")
			_:
				push_error("DialogueRunner: unknown effect %s" % [effect])
