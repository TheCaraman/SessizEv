class_name MainMenu
extends Control
## The title screen: continue the saved campaign, start a new one, or quit.
##
## "Continue" is offered only when a save exists and shows which day it is on.
## Starting a new game does not delete the save at once; it is overwritten the
## next time the game saves, and the menu says so.

const SESSION_SCENE: String = "res://scenes/main/house_blockout.tscn"
const TEXT_COLOR := Color(0.88, 0.86, 0.76)
const DIM_COLOR := Color(0.58, 0.57, 0.50)

var _continue_button: Button
var _note: Label


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = false
	_build_interface()
	refresh()


## True when there is a campaign to continue.
func has_continue() -> bool:
	return not SaveManager.get_summary().is_empty()


## Updates the menu to match the save on disk.
func refresh() -> void:
	var summary: Dictionary = SaveManager.get_summary()
	_continue_button.visible = not summary.is_empty()
	if not summary.is_empty():
		_continue_button.text = tr("MENU_CONTINUE").format({"day": summary["day"]})
	_note.text = tr("MENU_OVERWRITE_NOTE") if not summary.is_empty() else ""


## Loads the saved campaign into GameState. Returns false if it cannot be read.
func prepare_continue() -> bool:
	return SaveManager.load_game()


## Starts a fresh campaign in GameState.
func prepare_new_game() -> void:
	GameState.new_campaign()


func _on_continue_pressed() -> void:
	if prepare_continue():
		get_tree().change_scene_to_file(SESSION_SCENE)
	else:
		refresh()
		_note.text = tr("MENU_LOAD_FAILED")


func _on_new_game_pressed() -> void:
	prepare_new_game()
	get_tree().change_scene_to_file(SESSION_SCENE)


func _build_interface() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.025, 0.035, 0.035)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var column := VBoxContainer.new()
	column.anchor_left = 0.12
	column.anchor_right = 0.6
	column.anchor_top = 0.24
	column.anchor_bottom = 0.9
	column.add_theme_constant_override(&"separation", 14)
	add_child(column)

	var title := Label.new()
	title.text = tr("MENU_TITLE")
	title.add_theme_color_override(&"font_color", TEXT_COLOR)
	title.add_theme_font_size_override(&"font_size", 72)
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = tr("MENU_SUBTITLE")
	subtitle.add_theme_color_override(&"font_color", DIM_COLOR)
	subtitle.add_theme_font_size_override(&"font_size", 24)
	column.add_child(subtitle)

	var gap := Control.new()
	gap.custom_minimum_size = Vector2(0.0, 48.0)
	column.add_child(gap)

	_continue_button = _make_button(tr("MENU_CONTINUE"))
	_continue_button.pressed.connect(_on_continue_pressed)
	column.add_child(_continue_button)

	var new_game: Button = _make_button(tr("MENU_NEW_GAME"))
	new_game.pressed.connect(_on_new_game_pressed)
	column.add_child(new_game)

	var quit: Button = _make_button(tr("MENU_QUIT"))
	quit.pressed.connect(func() -> void: get_tree().quit())
	column.add_child(quit)

	_note = Label.new()
	_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_note.add_theme_color_override(&"font_color", DIM_COLOR)
	_note.add_theme_font_size_override(&"font_size", 20)
	column.add_child(_note)


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(420.0, 0.0)
	button.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	button.add_theme_font_size_override(&"font_size", 30)
	return button
