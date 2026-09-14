extends Area2D
class_name DeskScript

# -------------------------------------------------------------------
const DESK_SCENE: PackedScene = preload("res://scenes/desk/Desk.tscn")

## How long the player has, once an infected desk's screen is open, to find
## and remove the malware before it's game over.
const MALWARE_TIME_LIMIT: float = 15.0

signal clicked(desk: DeskScript)
## Emitted once if this desk was infected and its timer ran out unresolved.
signal malware_uncleaned

var has_malware: bool = false
var malware_cleaned: bool = false
var malware_filename: String = ""
## True once a file has been clicked on an infected desk - further clicks are
## locked out so the player can't just click every file within the timer.
var file_locked: bool = false

# -------------------------------------------------------------------
# make sure Monitoring=On in the Area2D (this is the default)
# make sure Pickable=On in the Area2D (this is the default)
@onready var canvas_layer: CanvasLayer 			= $CanvasLayer
@onready var panel_container: PanelContainer	= $CanvasLayer/PanelContainer
@onready var margin_container: MarginContainer	= $CanvasLayer/PanelContainer/MarginContainer
@onready var dialog: VBoxContainer 			= $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer

@onready var warning_label: Label				= dialog.get_node("WarningLabel")
@onready var timer_label: Label 				= dialog.get_node("TimerLabel")
@onready var file_grid: GridContainer 			= dialog.get_node("FileGrid")
@onready var result_label: RichTextLabel		= dialog.get_node("ResultLabel")
@onready var close_button: Button 				= dialog.get_node("CloseButton")
@onready var malware_timer: Timer 				= $MalwareTimer

# -------------------------------------------------------------------
## Create a desk, optionally infected with malware.
@warning_ignore("shadowed_variable")
static func create(has_malware: bool) -> Area2D:
	var desk_instance = DESK_SCENE.instantiate() # create, calls _init()
	desk_instance.configure(has_malware)
	return desk_instance

# -------------------------------------------------------------------
@warning_ignore("shadowed_variable")
func configure(has_malware: bool) -> void:
	self.has_malware = has_malware

# -------------------------------------------------------------------
func _ready() -> void:
	prepare_dialog()

	malware_timer.wait_time = MALWARE_TIME_LIMIT
	malware_timer.one_shot = true
	# Keep counting down (and keep this script's own _process running to
	# update the label) while the game world is paused, which happens the
	# instant this desk's dialog opens - see _on_clicked()/_on_close_pressed()
	# for how it's paused/resumed independent of the tree's own pause state.
	malware_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	process_mode = Node.PROCESS_MODE_ALWAYS
	malware_timer.timeout.connect(_on_malware_timer_timeout)

	warning_label.text = "⚠ You may only select ONE file here — choose carefully!" if has_malware else ""

	build_file_list()

# -------------------------------------------------------------------
## enable the mouse click detection
func prepare_dialog():
	# Double-safety: ensure the UI layer keeps running while paused
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS

	# Hide dialog at start
	canvas_layer.hide()

	# set the look of the dialog box
	set_dialog_style()

	# Detect mouse clicks and put up the dialog box
	clicked.connect(_on_clicked)
	input_event.connect(_on_input_event)

	# Wire the close button
	close_button.pressed.connect(_on_close_pressed)

	# enable input event processing for this scene
	input_pickable = true

# -------------------------------------------------------------------
func set_dialog_style():
	const margin: int = 25
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)
	margin_container.add_theme_constant_override("margin_right", margin)

	var dialog_style = StyleBoxFlat.new()
	dialog_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)   # near-black, 90% opaque
	dialog_style.border_color = Color(1, 1, 1, 1)         # white border
	panel_container.add_theme_stylebox_override("panel", dialog_style)

# -------------------------------------------------------------------
## Handle input events for this scene
# We use the Area's CollisionShape for the clickable area
func _on_input_event(viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		clicked.emit(self)
		viewport.set_input_as_handled() # do not propagate event to children

# -------------------------------------------------------------------
## How many ordinary files sit alongside the malware (or fill the grid
## alone, on a clean desk) - 8 fills the 3-column grid into a neat 3x3.
const NORMAL_FILE_COUNT: int = 8

## Build this desk's file grid: several normal files, plus one malicious
## file in a random slot if this desk is infected.
func build_file_list() -> void:
	var normal_pool: Array = GlobalConfigs.NORMAL_FILE_NAMES.duplicate()
	normal_pool.shuffle()
	var file_names: Array = normal_pool.slice(0, NORMAL_FILE_COUNT)

	if has_malware:
		malware_filename = GlobalConfigs.MALWARE_FILE_NAMES.pick_random()
		file_names.append(malware_filename)
	file_names.shuffle()

	for file_name in file_names:
		var file_button := Button.new()
		file_button.text = file_name
		file_button.custom_minimum_size = Vector2(120, 60)
		file_button.pressed.connect(_on_file_clicked.bind(file_name))
		file_grid.add_child(file_button)

# -------------------------------------------------------------------
## The desk was clicked - open its screen. Only starts the malware clock
## the first time; reopening resumes wherever it was left off.
func _on_clicked(_desk: DeskScript) -> void:
	get_tree().paused = true
	result_label.visible = false
	result_label.text = ""
	canvas_layer.show()

	if has_malware and not malware_cleaned:
		if malware_timer.is_stopped():
			malware_timer.start()
		malware_timer.paused = false
	update_timer_label()

# -------------------------------------------------------------------
func _process(_delta: float) -> void:
	if has_malware and not malware_cleaned and canvas_layer.visible:
		update_timer_label()

# -------------------------------------------------------------------
func update_timer_label() -> void:
	if has_malware and not malware_cleaned:
		timer_label.text = "⚠ Unrecognized process running — %0.1fs to resolve" % malware_timer.time_left
	else:
		timer_label.text = "No threats detected."

# -------------------------------------------------------------------
## A file icon was clicked - check if it was the malware. On an infected
## desk, only one click is ever allowed (right or wrong) - see file_locked.
func _on_file_clicked(file_name: String) -> void:
	if malware_cleaned or (has_malware and file_locked):
		return

	result_label.bbcode_enabled = true
	result_label.visible = true

	if has_malware and file_name == malware_filename:
		malware_cleaned = true
		malware_timer.stop()
		result_label.text = "[color=green][b]Malware removed![/b][/color]"
	elif has_malware:
		result_label.text = "[color=red][b]Wrong file - that wasn't it.[/b][/color]"
	else:
		result_label.text = "[color=gray]Nothing suspicious there.[/color]"

	if has_malware:
		file_locked = true
		for child in file_grid.get_children():
			if child is Button:
				child.disabled = true

# -------------------------------------------------------------------
## The close button was clicked. Pause (don't reset) any running malware
## timer so it can only ever expire while its own screen is open.
func _on_close_pressed() -> void:
	if has_malware and not malware_cleaned:
		malware_timer.paused = true
	canvas_layer.hide()
	get_tree().paused = false

# -------------------------------------------------------------------
## Ran out of time with the malware still on this desk - game over.
func _on_malware_timer_timeout() -> void:
	if malware_cleaned:
		return

	result_label.bbcode_enabled = true
	result_label.fit_content = true
	result_label.text = failure_message()
	result_label.visible = true
	for child in file_grid.get_children():
		if child is Button:
			child.disabled = true

	await get_tree().create_timer(2.5).timeout
	malware_uncleaned.emit()

# -------------------------------------------------------------------
## Fancy bbcode display of the malware timeout message
func failure_message() -> String:
	var message: String = "[center][color=red][shake level=5 rate=10][font_size=20][b]"
	message += "Security breach! IT wasn't notified in time."
	message += "[/b][/font_size][/shake][/color][/center]"
	return message
