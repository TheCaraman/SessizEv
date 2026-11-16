class_name ShelterView
extends CanvasLayer
## The household screen: who sleeps where, who does what, what tonight will
## cost, and what residents have reported today (docs/Day2Design.md, 6-7).
##
## The screen edits a draft. "Confirm" hands the whole draft to
## ShelterManager, which applies all of it or none of it; "Cancel" discards
## it. Looking costs nothing; a confirmed change costs fifteen minutes.
##
## Nothing here reveals who is infected: only names, where people are,
## their trust in Daniel as a word, and their own reports.

const TEXT_COLOR := Color(0.88, 0.86, 0.76)
const DIM_COLOR := Color(0.60, 0.59, 0.52)
const WARN_COLOR := Color(0.86, 0.62, 0.36)

var _shelter: ShelterManager
var _draft: Dictionary = {"beds": {}, "jobs": {}}
var _rows: VBoxContainer
var _message: Label
var _forecast: Label
var _reports: Label
var _hint: Label
var _bed_pickers: Dictionary = {}
var _job_pickers: Dictionary = {}


func _ready() -> void:
	layer = 6
	_build_interface()
	visible = false


## Called once by the session scene.
func setup(shelter: ShelterManager) -> void:
	_shelter = shelter


func is_open() -> bool:
	return visible


func open() -> void:
	if visible or _shelter == null:
		return
	_draft = _shelter.get_current_plan()
	_message.text = ""
	visible = true
	_rebuild()
	EventBus.shelter_view_opened.emit()
	if not _bed_pickers.is_empty():
		(_bed_pickers.values()[0] as Control).grab_focus()


## Closes the screen and throws the draft away. Costs nothing.
func cancel() -> void:
	if not visible:
		return
	visible = false
	EventBus.shelter_view_closed.emit()


## Applies the draft. Returns "" on success, otherwise the translation key of
## the reason, which is also shown on screen; nothing is changed on failure.
func confirm() -> String:
	if not visible:
		return ""
	var result: Dictionary = _shelter.apply_plan(_draft)
	if result["key"] != "":
		_message.text = tr(result["key"]).format(result["args"])
		return result["key"]
	visible = false
	EventBus.shelter_view_closed.emit()
	return ""


## Changes the draft, as the pickers do.
func set_bed(npc_id: String, bed_id: String) -> void:
	_draft["beds"][npc_id] = bed_id
	_message.text = ""


func set_job(npc_id: String, job_id: String) -> void:
	_draft["jobs"][npc_id] = job_id
	_message.text = ""


func get_message() -> String:
	return _message.text


## Every piece of text currently on the screen, for tests.
func get_all_text() -> String:
	var parts := PackedStringArray()
	_collect_text(self, parts)
	return "\n".join(parts)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"pause") or event.is_action_pressed(&"journal"):
		cancel()
		get_viewport().set_input_as_handled()
	elif event.is_action(&"interact"):
		get_viewport().set_input_as_handled()


func _rebuild() -> void:
	for child: Node in _rows.get_children():
		_rows.remove_child(child)
		child.queue_free()
	_bed_pickers = {}
	_job_pickers = {}

	var residents: Array[String] = GameState.get_residents()
	if residents.is_empty():
		_rows.add_child(_make_label(tr("SHELTER_EMPTY"), 26, DIM_COLOR))
	for npc_id: String in residents:
		_rows.add_child(_make_row(npc_id))

	var people: int = GameState.get_headcount()
	var forecast: String = tr("SHELTER_FORECAST").format({
		"people": people,
		"food": GameState.resources["food"],
		"water": GameState.resources["water"],
	})
	var short_tonight: bool = (
		int(GameState.resources["food"]) < people or int(GameState.resources["water"]) < people
	)
	var short_tomorrow: bool = (
		int(GameState.resources["food"]) < people * 2 or int(GameState.resources["water"]) < people * 2
	)
	if short_tonight:
		forecast += "  " + tr("NARR_SUPPLIES_SHORT_TONIGHT")
	elif short_tomorrow:
		forecast += "  " + tr("NARR_SUPPLIES_SHORT_TOMORROW")
	_forecast.text = forecast
	_forecast.add_theme_color_override(&"font_color", WARN_COLOR if short_tonight or short_tomorrow else TEXT_COLOR)

	var lines: PackedStringArray = _shelter.get_todays_reports()
	_reports.text = tr("SHELTER_NO_REPORTS") if lines.is_empty() else "\n".join(lines)
	_hint.text = tr("SHELTER_HINT").format({
		"minutes": ShelterManager.PLAN_MINUTES,
		"key": InputSetup.get_key_label(&"pause"),
	})


func _make_row(npc_id: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override(&"separation", 18)

	if GameState.npcs[npc_id].get("isolated", false):
		row.add_child(_make_label(tr("ISO_RESERVED").format({"name": Roster.get_display_name(npc_id)}), 24, TEXT_COLOR))
		return row
	var who := VBoxContainer.new()
	who.custom_minimum_size = Vector2(360.0, 0.0)
	who.add_child(_make_label(Roster.get_display_name(npc_id), 28, TEXT_COLOR))
	var trust: int = int(GameState.npcs[npc_id]["trust"])
	var room: Dictionary = HouseLayout.get_room(StringName(GameState.get_location(npc_id)))
	var status: String = tr("SHELTER_STATUS").format({
		"trust": tr(ShelterManager.trust_label_key(trust)),
		"room": tr(room.get("name_key", "")),
	})
	var job_id: String = _shelter.get_job_of(npc_id)
	if job_id != ShelterManager.NO_JOB:
		status += "  ·  " + tr("SHELTER_WORKING").format({"job": tr(_shelter.get_job(job_id)["name"])})
	who.add_child(_make_label(status, 20, DIM_COLOR))
	row.add_child(who)

	var bed_picker := OptionButton.new()
	bed_picker.custom_minimum_size = Vector2(300.0, 0.0)
	bed_picker.add_theme_font_size_override(&"font_size", 22)
	for i: int in GameState.BEDS.size():
		var bed_id: String = GameState.BEDS[i]
		var bed_room: Dictionary = HouseLayout.get_room(StringName(GameState.bed_room(bed_id)))
		bed_picker.add_item(tr("BED_CHOICE").format({
			"room": tr(bed_room.get("name_key", "")), "n": GameState.bed_number(bed_id),
		}))
		if bed_id == _draft["beds"].get(npc_id, ""):
			bed_picker.select(i)
	bed_picker.item_selected.connect(func(index: int) -> void: set_bed(npc_id, GameState.BEDS[index]))
	row.add_child(bed_picker)
	_bed_pickers[npc_id] = bed_picker

	var job_ids: Array[String] = [ShelterManager.NO_JOB]
	job_ids.append_array(_shelter.get_job_ids())
	var job_picker := OptionButton.new()
	job_picker.custom_minimum_size = Vector2(300.0, 0.0)
	job_picker.add_theme_font_size_override(&"font_size", 22)
	for i: int in job_ids.size():
		var id: String = job_ids[i]
		job_picker.add_item(tr("JOB_NONE") if id == ShelterManager.NO_JOB else tr(_shelter.get_job(id)["name"]))
		if id == _draft["jobs"].get(npc_id, ShelterManager.NO_JOB):
			job_picker.select(i)
	job_picker.item_selected.connect(func(index: int) -> void: set_job(npc_id, job_ids[index]))
	row.add_child(job_picker)
	_job_pickers[npc_id] = job_picker
	return row


func _build_interface() -> void:
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.03, 0.03, 0.95)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)

	var column := VBoxContainer.new()
	column.anchor_left = 0.08
	column.anchor_right = 0.92
	column.anchor_top = 0.09
	column.anchor_bottom = 0.94
	column.add_theme_constant_override(&"separation", 16)
	root.add_child(column)

	column.add_child(_make_label(tr("SHELTER_TITLE"), 44, TEXT_COLOR))

	var header := HBoxContainer.new()
	header.add_theme_constant_override(&"separation", 18)
	for column_title: Array in [["SHELTER_COL_WHO", 360.0], ["SHELTER_COL_BED", 300.0], ["SHELTER_COL_JOB", 300.0]]:
		var title: Label = _make_label(tr(column_title[0]), 20, DIM_COLOR)
		title.custom_minimum_size = Vector2(column_title[1], 0.0)
		header.add_child(title)
	column.add_child(header)

	_rows = VBoxContainer.new()
	_rows.add_theme_constant_override(&"separation", 12)
	column.add_child(_rows)

	_message = _make_label("", 24, WARN_COLOR)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_message)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(spacer)

	_forecast = _make_label("", 24, TEXT_COLOR)
	_forecast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_forecast)

	column.add_child(_make_label(tr("SHELTER_REPORTS_TITLE"), 20, DIM_COLOR))
	_reports = _make_label("", 22, TEXT_COLOR)
	_reports.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_reports)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override(&"separation", 16)
	var confirm_button := Button.new()
	confirm_button.text = tr("SHELTER_CONFIRM")
	confirm_button.add_theme_font_size_override(&"font_size", 26)
	confirm_button.pressed.connect(confirm)
	buttons.add_child(confirm_button)
	var cancel_button := Button.new()
	cancel_button.text = tr("SHELTER_CANCEL")
	cancel_button.add_theme_font_size_override(&"font_size", 26)
	cancel_button.pressed.connect(cancel)
	buttons.add_child(cancel_button)
	column.add_child(buttons)

	_hint = _make_label("", 20, DIM_COLOR)
	column.add_child(_hint)


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override(&"font_color", color)
	label.add_theme_font_size_override(&"font_size", font_size)
	return label


func _collect_text(node: Node, into: PackedStringArray) -> void:
	if node is Label:
		into.append((node as Label).text)
	elif node is OptionButton:
		var picker := node as OptionButton
		for i: int in picker.item_count:
			into.append(picker.get_item_text(i))
	elif node is Button:
		into.append((node as Button).text)
	for child: Node in node.get_children():
		_collect_text(child, into)
