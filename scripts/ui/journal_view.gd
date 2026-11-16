class_name JournalView
extends CanvasLayer
signal closed
var text: Label
func _ready() -> void:
	layer = 15
	var panel := PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 80
	panel.offset_right = -80
	panel.offset_top = 80
	panel.offset_bottom = -80
	add_child(panel)
	var scroll := ScrollContainer.new()
	panel.add_child(scroll)
	text = Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("font_size", 24)
	scroll.add_child(text)
	visible = false
func open() -> void:
	text.text = EvidenceManager.journal_text()
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func close() -> void:
	visible = false
	closed.emit()
func _input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("journal") or event.is_action_pressed("pause")):
		close()
		get_viewport().set_input_as_handled()
