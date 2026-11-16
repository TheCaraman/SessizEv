class_name PauseMenu
extends CanvasLayer
## Pauses the game and offers: resume, return to the title screen, or quit.
##
## The game only saves at set moments (a new day, or by choice in Daniel's
## bedroom), so the menu warns that leaving loses anything since the last save.

signal closed

const MENU_SCENE: String = "res://scenes/main/main_menu.tscn"
const TEXT_COLOR := Color(0.88, 0.86, 0.76)
const DIM_COLOR := Color(0.58, 0.57, 0.50)
var _settings: SettingsView


func _ready() -> void:
	layer = 20
	# Keeps working while the rest of the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_interface()
	_settings = SettingsView.new()
	add_child(_settings)
	visible = false


func is_open() -> bool:
	return visible


func open() -> void:
	if visible:
		return
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close() -> void:
	if not visible:
		return
	visible = false
	_settings.close()
	get_tree().paused = false
	closed.emit()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"pause"):
		if _settings.visible:
			_settings.close()
		else:
			close()
		get_viewport().set_input_as_handled()


func _go_to_main_menu() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU_SCENE)


func _build_interface() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.0, 0.01, 0.01, 0.78)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var column := VBoxContainer.new()
	column.anchor_left = 0.12
	column.anchor_right = 0.6
	column.anchor_top = 0.28
	column.anchor_bottom = 0.9
	column.add_theme_constant_override(&"separation", 14)
	add_child(column)

	var title := Label.new()
	title.text = tr("PAUSE_TITLE")
	title.add_theme_color_override(&"font_color", TEXT_COLOR)
	title.add_theme_font_size_override(&"font_size", 54)
	column.add_child(title)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 28.0)
	column.add_child(gap)

	var resume: Button = _make_button(tr("PAUSE_RESUME"))
	resume.pressed.connect(close)
	column.add_child(resume)
	var settings_button: Button = _make_button(tr("MENU_SETTINGS"))
	settings_button.name = "SettingsButton"
	settings_button.pressed.connect(func() -> void: _settings.open())
	column.add_child(settings_button)

	var main_menu: Button = _make_button(tr("PAUSE_MAIN_MENU"))
	main_menu.pressed.connect(_go_to_main_menu)
	column.add_child(main_menu)

	var quit: Button = _make_button(tr("MENU_QUIT"))
	quit.pressed.connect(func() -> void: get_tree().quit())
	column.add_child(quit)

	var note := Label.new()
	note.text = tr("PAUSE_NOTE")
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_color_override(&"font_color", DIM_COLOR)
	note.add_theme_font_size_override(&"font_size", 20)
	column.add_child(note)


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(420.0, 0.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.add_theme_font_size_override(&"font_size", 30)
	return button
