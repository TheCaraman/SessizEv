extends Node
## Review-only scene: no campaign creation, save writes or production swaps.
const OPTIONS: Array[Dictionary] = [
	{"title": "Mevcut geçici oda", "path": "res://assets/rooms/living_room.png", "capture": "current"},
	{"title": "Önerilen çizimsel yön — onay bekliyor", "path": "res://docs/art/concepts/ART-REV-003-graphic-study.png", "capture": "proposed"},
]
var _view: RoomView
var _caption: Label

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_view = RoomView.new()
	add_child(_view)
	_view.open("living_room")
	_view.set_process_input(false)
	var overlay := CanvasLayer.new()
	overlay.layer = 30
	add_child(overlay)
	var panel := PanelContainer.new()
	panel.anchor_left = 0.54
	panel.anchor_right = 1.0
	panel.offset_top = 28.0
	panel.offset_right = -32.0
	panel.offset_left = 0.0
	overlay.add_child(panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	panel.add_child(column)
	_caption = Label.new()
	_caption.add_theme_font_size_override("font_size", 25)
	_caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_caption)
	for index: int in OPTIONS.size():
		var button := Button.new()
		button.text = "%d — %s" % [index + 1, OPTIONS[index]["title"]]
		button.add_theme_font_size_override("font_size", 23)
		button.pressed.connect(_select.bind(index))
		column.add_child(button)
	_select(1)
	if "--capture-atmosphere" in OS.get_cmdline_user_args():
		for index: int in OPTIONS.size():
			_select(index)
			for frame: int in 6:
				await get_tree().process_frame
			await RenderingServer.frame_post_draw
			var path: String = "res://docs/qa/atmosphere-review-%s.png" % OPTIONS[index]["capture"]
			if get_viewport().get_texture().get_image().save_png(path) != OK:
				push_error("Could not save atmosphere review")
				get_tree().quit(1)
				return
		print("ATMOSPHERE REVIEW: CAPTURED")
		get_tree().quit()

func _select(index: int) -> void:
	_view._background.texture = load(OPTIONS[index]["path"]) as Texture2D
	_caption.text = OPTIONS[index]["title"] + "\nKarşılaştırma aracı; oyun kaydı değiştirilmez."

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1:
			_select(0)
		elif event.keycode == KEY_2:
			_select(1)
		elif event.keycode == KEY_ESCAPE:
			get_tree().quit()
