class_name AccusationView
extends CanvasLayer
signal closed
signal completed(content: String)
var controller: Accusation
var _room: String = ""
var _target: String = ""
var _selected: Array = []
var _offer: Dictionary = {}
var _title: Label
var _guide: Label
var _status: Label
var _list: VBoxContainer
var _cancel: Button
var _confirm: Button
var _checks: Dictionary = {}
var _panel: VBoxContainer

func _ready() -> void:
	name = "AccusationView"
	layer = 24
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.023, 0.97)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	_panel = VBoxContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 80
	_panel.offset_right = -80
	_panel.offset_top = 65
	_panel.offset_bottom = -65
	_panel.add_theme_constant_override("separation", 14)
	add_child(_panel)
	_title = _label(30)
	_guide = _label(22)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size.y = 80
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_panel.add_child(scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 14)
	scroll.add_child(_list)
	_status = _label(22)
	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 20)
	_panel.add_child(buttons)
	_cancel = Button.new()
	_confirm = Button.new()
	for button: Button in [_cancel, _confirm]:
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 26)
		buttons.add_child(button)
	_cancel.pressed.connect(close)
	_confirm.pressed.connect(_press_confirm)
	EventBus.room_view_closed.connect(func(_id: StringName) -> void: close())
	EventBus.day_started.connect(func(_day: int) -> void: close())
	visible = false

func _label(size: int) -> Label:
	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", size)
	_panel.add_child(label)
	return label

func is_open() -> bool:
	return visible

func open(room: String, id: String) -> void:
	if controller == null or id not in controller.targets(room) or controller.recorded(id):
		return
	_room = room
	_target = id
	_selected.clear()
	_offer = {}
	visible = true
	_refresh()
	_cancel.grab_focus()

func close() -> void:
	_offer = {}
	_selected.clear()
	if visible:
		visible = false
		closed.emit()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and visible and is_instance_valid(_confirm):
		_offer = {}
		_refresh()

func _refresh() -> void:
	_title.text = tr("ACC_TITLE").format({"name": Roster.get_display_name(_target)})
	var rules: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Accusation.RULES))
	_guide.text = tr("ACC_GUIDE").format({"minutes": int(rules["minutes"])})
	_cancel.text = tr("ACC_CANCEL")
	_confirm.text = tr("ACC_REVIEW_ACTION")
	_status.text = tr("ACC_UNSUPPORTED")
	_checks.clear()
	for child: Node in _list.get_children():
		child.free()
	for entry: Dictionary in Accusation.basis(GameState.to_dict()):
		var id: String = entry["id"]
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		_list.add_child(row)
		var tick := CheckBox.new()
		tick.add_theme_icon_override("checked", load("res://assets/icons/evidence_checked.svg"))
		tick.add_theme_icon_override("unchecked", load("res://assets/icons/evidence_unchecked.svg"))
		tick.button_pressed = id in _selected
		tick.custom_minimum_size = Vector2(44, 44)
		row.add_child(tick)
		_checks[id] = tick
		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.add_theme_font_size_override("font_size", 22)
		label.text = tr("POWER_" + str(entry["kind"]).to_upper()) + " — " + tr(entry["key"]).format(entry.get("args", {}))
		row.add_child(label)
		tick.toggled.connect(func(checked: bool) -> void:
			if checked:
				_selected.append(id)
			else:
				_selected.erase(id)
			_offer = {}
			_confirm.text = tr("ACC_REVIEW_ACTION")
			_status.text = tr("ACC_TESTIMONY_LIMIT" if Accusation.supported(_target, _selected, GameState.to_dict()) else "ACC_UNSUPPORTED")
		)
	if _checks.is_empty():
		var empty := Label.new()
		empty.text = tr("ACC_NO_BASIS")
		empty.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty.add_theme_font_size_override("font_size", 22)
		_list.add_child(empty)
	var focus: Array[Control] = [_cancel]
	for tick: Control in _checks.values():
		focus.append(tick)
	focus.append(_confirm)
	for index: int in focus.size():
		focus[index].focus_next = focus[index].get_path_to(focus[(index + 1) % focus.size()])
		focus[index].focus_previous = focus[index].get_path_to(focus[(index - 1 + focus.size()) % focus.size()])
	_status.text = tr("ACC_TESTIMONY_LIMIT" if Accusation.supported(_target, _selected, GameState.to_dict()) else "ACC_UNSUPPORTED")

func _press_confirm() -> void:
	if _offer.is_empty():
		_offer = controller.quote(_room, _target, _selected)
		if _offer.is_empty():
			_status.text = tr("ACC_UNAVAILABLE")
			return
		_status.text = tr("ACC_CONFIRM").format({"name": Roster.get_display_name(_target), "minutes": _offer["minutes"]}) + "\n\n" + tr("ACC_UNSUPPORTED" if _offer["unsupported"] else "ACC_TESTIMONY_LIMIT")
		_confirm.text = tr("ACC_CONFIRM_ACTION")
		_cancel.grab_focus()
		return
	var error: Error = controller.commit(_offer)
	_offer = {}
	if error != OK:
		_refresh()
		_status.text = tr("ACC_CHANGED" if error in [ERR_BUSY, ERR_UNAVAILABLE] else "DAY4_REVIEW_SAVE_FAILED")
		return
	var response: String = controller.response(_target)
	close()
	completed.emit(response)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"pause"):
		close()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"interact"):
		get_viewport().set_input_as_handled()
