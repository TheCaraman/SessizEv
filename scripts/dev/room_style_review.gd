extends Node
## Safe outside an isolated copy (DEV-HELPER-GUARDS-001): no campaign session,
## no save or preference write; any GameState change stays in memory.
## Captures write PNGs under res:// only. Opening the campaign session scene
## or saving here would need ReviewSpots.isolated (dev_helpers_test checks).
## Consistency gallery: real RoomView, no campaign saves or day transitions.

var _rooms: Array[StringName] = []
var _index: int = 0
var _view: RoomView

func _ready() -> void:
	GameState.new_campaign(42)
	GameState.minutes = 660
	TranslationServer.set_locale("tr")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for room: Dictionary in HouseLayout.ROOMS:
		if not room["id"] in HouseLayout.WALKABLE_ROOMS:
			_rooms.append(room["id"])
	_view = RoomView.new()
	add_child(_view)
	show_room(0)
	if "--capture-all-rooms" in OS.get_cmdline_user_args():
		for i: int in _rooms.size():
			show_room(i)
			for frame: int in 5:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var path: String = "res://docs/art/previews/%s_in_game.png" % _rooms[i]
			if get_viewport().get_texture().get_image().save_png(path) != OK:
				push_error("FAIL: room capture " + str(_rooms[i]))
				get_tree().quit(1)
				return
		print("ROOM STYLE REVIEW: PASS (%d room captures)" % _rooms.size())
		get_tree().quit(0)

func show_room(index: int) -> void:
	_index = posmod(index, _rooms.size())
	_view.open(_rooms[_index])

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_RIGHT:
			show_room(_index + 1)
		elif event.keycode == KEY_LEFT:
			show_room(_index - 1)
