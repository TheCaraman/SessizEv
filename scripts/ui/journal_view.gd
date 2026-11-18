class_name JournalView
extends CanvasLayer
signal closed
var text: Label
var _close_hint: Label
func _ready() -> void:
	layer = 15
	# Cover lower HUD layers as well as the world. The journal is modal.
	var backdrop := ColorRect.new()
	backdrop.name = "ModalBackdrop"
	backdrop.color = Color(0.025, 0.032, 0.031, 1.0)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(backdrop)
	var panel := PanelContainer.new()
	panel.name = "JournalPanel"
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.055, 0.065, 0.06, 1.0)
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 24.0
	style.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", style)
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 80
	panel.offset_right = -80
	panel.offset_top = 80
	panel.offset_bottom = -80
	add_child(panel)
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	text = Label.new()
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text.add_theme_font_size_override("font_size", 24)
	scroll.add_child(text)
	_close_hint = Label.new()
	_close_hint.name = "JournalCloseHint"
	_close_hint.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_close_hint.offset_left = 80
	_close_hint.offset_right = -80
	_close_hint.offset_top = -64
	_close_hint.offset_bottom = -24
	_close_hint.add_theme_font_size_override("font_size", 20)
	_close_hint.text = tr("JOURNAL_CLOSE_HINT").format({"key": InputSetup.get_key_label(&"journal")})
	add_child(_close_hint)
	visible = false
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_instance_valid(_close_hint):
		_close_hint.text = tr("JOURNAL_CLOSE_HINT").format({"key": InputSetup.get_key_label(&"journal")})
func open(content: String = "") -> void:
	text.text = EvidenceManager.journal_text() if content.is_empty() else content
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func close() -> void:
	visible = false
	closed.emit()
func _input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("journal") or event.is_action_pressed("pause")):
		close()
		get_viewport().set_input_as_handled()
