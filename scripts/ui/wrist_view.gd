class_name WristView
extends CanvasLayer
## IMMERSION I-08: hold the wrist key (Tab) to glance at the watch on Daniel's
## wrist: day, clock and energy, read straight from GameState. Looking is free:
## it never changes time, energy or any other state, and walking continues.
##
## Mechanics only. The panel below is a neutral placeholder; the drawn arm and
## watch belong in [member art_slot] (Codex, approved V5 style). Child of the
## Player, so it shows only while the player has control.

const SLIDE_SECONDS: float = 0.18
## How far below its resting place the panel waits while hidden.
const HIDDEN_DROP: float = 260.0
## Resting top edge of the panel, measured up from the bottom of the screen.
const REST_TOP: float = -200.0

## Where the drawn arm/watch art goes. Empty until Codex supplies it.
var art_slot: TextureRect
var panel: PanelContainer
var day_label: Label
var clock_label: Label
var energy_label: Label
var energy_bar: ProgressBar
var _player: PlayerController
var _shown: bool = false
var _tween: Tween


func _ready() -> void:
	layer = 15
	process_mode = Node.PROCESS_MODE_ALWAYS
	_player = get_parent() as PlayerController
	panel = PanelContainer.new()
	panel.name = "WristPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	panel.offset_left = -360.0
	panel.offset_top = REST_TOP
	panel.offset_right = -36.0
	panel.offset_bottom = -36.0
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.055, 0.86)
	style.border_color = Color(0.42, 0.40, 0.32)
	style.set_border_width_all(2)
	style.set_corner_radius_all(18)
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)
	art_slot = TextureRect.new()
	art_slot.name = "ArtSlot"
	art_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art_slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.add_child(art_slot)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 6)
	rows.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(rows)
	var top := HBoxContainer.new()
	rows.add_child(top)
	day_label = _label(26, Color(0.80, 0.78, 0.66))
	day_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(day_label)
	clock_label = _label(40, Color(0.90, 0.88, 0.76))
	top.add_child(clock_label)
	energy_label = _label(22, Color(0.80, 0.78, 0.66))
	rows.add_child(energy_label)
	energy_bar = ProgressBar.new()
	energy_bar.min_value = 0.0
	energy_bar.max_value = 100.0
	energy_bar.show_percentage = false
	energy_bar.custom_minimum_size = Vector2(0.0, 14.0)
	energy_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rows.add_child(energy_bar)
	visible = false
	panel.position.y += HIDDEN_DROP
	refresh()


## Where the panel stands when the watch is up, in canvas units. Fixed, so a
## half-finished slide never shifts it.
func rest_position_y() -> float:
	return panel.get_parent_area_size().y + REST_TOP


## Whether the watch is up (or on its way up).
func is_shown() -> bool:
	return _shown


func _process(_delta: float) -> void:
	var wanted: bool = (
		_player != null and _player.control_enabled and not get_tree().paused
		and InputMap.has_action(&"wrist") and Input.is_action_pressed(&"wrist")
	)
	if wanted != _shown:
		_set_shown(wanted)
	if _shown:
		refresh()


## Rewrites the readout from the current game state.
func refresh() -> void:
	var energy: int = clampi(int(GameState.player.get("energy", 0)), 0, 100)
	day_label.text = tr("WRIST_DAY").format({"day": GameState.day})
	clock_label.text = GameState.get_clock_text()
	energy_label.text = tr("WRIST_ENERGY").format({"energy": energy})
	energy_bar.value = energy


func _set_shown(value: bool) -> void:
	_shown = value
	if _tween != null and _tween.is_valid():
		_tween.kill()
	var rest_y: float = rest_position_y()
	var target_y: float = rest_y if value else rest_y + HIDDEN_DROP
	if value:
		refresh()
		visible = true
	if Settings.get_number("camera_motion") < 0.5:
		panel.position.y = target_y
		visible = value
		return
	_tween = create_tween()
	_tween.tween_property(panel, "position:y", target_y, SLIDE_SECONDS).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT if value else Tween.EASE_IN)
	if not value:
		_tween.tween_callback(func() -> void: visible = false)


func _label(font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label
