extends Node
## Interactive QA fixture. Run in an isolated test copy, never a personal save.
func _ready() -> void:
	DisplayServer.window_set_title("The Quiet Hours - Night QA")
	TranslationServer.set_locale("tr")
	GameState.new_campaign(42)
	GameState.day = 3
	GameState.minutes = 1200
	var session: Node = load("res://scenes/main/house_blockout.tscn").instantiate()
	add_child(session)
	session.get_node("RoomView").open("daniel_bedroom")
