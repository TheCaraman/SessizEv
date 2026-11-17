class_name SettingsView
extends CanvasLayer
## Scene-owned modal, shared by the title screen and pause menu.
signal closed
var _labels: Dictionary = {}
var _sliders: Dictionary = {}
var _readouts: Dictionary = {}
var _error: Label
var _back: Button

func _ready() -> void:
	layer = 30
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build()
	Settings.preferences_changed.connect(_refresh)
	visible = false

func open() -> void:
	_error.text = ""
	visible = true
	_refresh()
	_back.grab_focus()

func close() -> void:
	if not visible:
		return
	visible = false
	closed.emit()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed(&"pause"):
		close()
		get_viewport().set_input_as_handled()

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and _error != null:
		_refresh()

func _build() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.023, 0.97)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	var panel := VBoxContainer.new()
	panel.name = "SettingsPanel"
	panel.anchor_left = 0.18
	panel.anchor_right = 0.82
	panel.anchor_top = 0.10
	panel.anchor_bottom = 0.92
	panel.add_theme_constant_override("separation", 12)
	add_child(panel)
	var title := Label.new()
	title.add_theme_font_size_override("font_size", 40)
	_labels[title] = "MENU_SETTINGS"
	panel.add_child(title)
	for key: String in Settings.DEFAULTS:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 20)
		panel.add_child(row)
		var label := Label.new()
		label.custom_minimum_size.x = 320
		label.add_theme_font_size_override("font_size", 26)
		_labels[label] = "SETTINGS_" + key.to_upper()
		row.add_child(label)
		var slider := HSlider.new()
		slider.name = key
		var limits: Vector2 = Settings.LIMITS[key]
		slider.min_value = limits.x
		slider.max_value = limits.y
		slider.step = 0.00011 if key == "mouse_sensitivity" else (0.01 if key in ["master_volume", "vignette"] else (0.05 if key == "brightness" else 1.0))
		slider.custom_minimum_size = Vector2(280, 44)
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.value_changed.connect(func(value: float) -> void:
			var error: Error = Settings.set_number(key, value)
			_error.text = tr("MENU_SETTINGS_FAILED") if error != OK else ""
			_refresh()
		)
		_sliders[key] = slider
		row.add_child(slider)
		var readout := Label.new()
		readout.custom_minimum_size.x = 100
		readout.add_theme_font_size_override("font_size", 26)
		_readouts[key] = readout
		row.add_child(readout)
	_error = Label.new()
	_error.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_error.add_theme_font_size_override("font_size", 22)
	panel.add_child(_error)
	var defaults := Button.new()
	defaults.name = "RestoreDefaults"
	defaults.add_theme_font_size_override("font_size", 28)
	_labels[defaults] = "SETTINGS_DEFAULTS"
	defaults.pressed.connect(func() -> void:
		_error.text = tr("MENU_SETTINGS_FAILED") if Settings.restore_defaults() != OK else ""
		_refresh()
	)
	panel.add_child(defaults)
	_back = Button.new()
	_back.name = "SettingsBack"
	_back.add_theme_font_size_override("font_size", 28)
	_labels[_back] = "SETTINGS_BACK"
	_back.pressed.connect(close)
	panel.add_child(_back)
	# Keep keyboard focus inside this modal instead of reaching hidden menu buttons.
	var focus_chain: Array[Control] = []
	for key: String in _sliders:
		focus_chain.append(_sliders[key])
	focus_chain.append(defaults)
	focus_chain.append(_back)
	for i: int in focus_chain.size():
		var control: Control = focus_chain[i]
		var previous: NodePath = control.get_path_to(focus_chain[(i - 1 + focus_chain.size()) % focus_chain.size()])
		var next: NodePath = control.get_path_to(focus_chain[(i + 1) % focus_chain.size()])
		control.focus_previous = previous
		control.focus_next = next
		control.focus_neighbor_top = previous
		control.focus_neighbor_bottom = next
		control.focus_neighbor_left = control.get_path_to(control)
		control.focus_neighbor_right = control.get_path_to(control)

func _refresh() -> void:
	for control: Control in _labels:
		control.text = tr(_labels[control])
	for key: String in _sliders:
		var value: float = Settings.get_number(key)
		_sliders[key].set_value_no_signal(value)
		_readouts[key].text = "%d°" % roundi(value) if key == "fov" else "%d%%" % roundi(value * (100.0 / float(Settings.DEFAULTS[key])))
		if key == "camera_motion":
			_readouts[key].text = tr("SETTINGS_MOTION_ON" if value >= 0.5 else "SETTINGS_MOTION_OFF")
