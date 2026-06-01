## Title screen
extends Node2D

# -------------------------------------------------------------------
var score: int = 0

## Room number to load first (one-based).
const FIRST_ROOM_INDEX: int = 1

var current_room_index: int = FIRST_ROOM_INDEX
var current_room: Node2D = null

# -------------------------------------------------------------------
## Load a room given its index (1..)
func load_room(room_index: int):
	if current_room:
		current_room.queue_free() # free the scene at the end of the current frame
		current_room = null

	var room_config: RoomConfig = GlobalConfigs.get_room_config(room_index)
	current_room = room_config.scene_script.create(room_config, score)
	current_room.room_completed.connect(_on_room_completed)
	add_child(current_room) # add to tree, calls _ready()

# -------------------------------------------------------------------
## Load the next room after completing a level
func load_next_room():
	current_room_index += 1
	load_room(current_room_index)

# -------------------------------------------------------------------
## Load and launch the first room of the game.
func load_first_room():
	current_room_index = FIRST_ROOM_INDEX
	load_room(current_room_index)

# -------------------------------------------------------------------
## event received from room when the player finishes it
# success = did they successfull identify the spy?
func _on_room_completed(success: bool):
	score = score + (1 if success else 0)
	load_next_room()

# -------------------------------------------------------------------
## Global game initialization
func _ready() -> void:
	add_music_bus()
	add_sfx_bus()
	load_first_room()
	show_title_dialog()

# -------------------------------------------------------------------
## Create the global sound device for music
# Decibel is a logarithmic scale. A change of -3 roughly halves the sound volume
func add_music_bus():
	assert(AudioServer.get_bus_index("Music") == -1, "Audio server bus for music already created")
	# Add a new bus at the end
	AudioServer.add_bus()

	var bus_idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(bus_idx, "Music")
	AudioServer.set_bus_volume_db(bus_idx, -6.0) # 0=default, in decibels

	# Route this bus to Master
	AudioServer.set_bus_send(bus_idx, "Master")

# -------------------------------------------------------------------
## Create the global sound device for sound effects
# Decibel is a logarithmic scale. A change of -3 roughly halves the sound volume
func add_sfx_bus():
	assert(AudioServer.get_bus_index("Sfx") == -1, "Audio server bus for sound effects already created")
	# Add a new bus at the end
	AudioServer.add_bus()

	var bus_idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(bus_idx, "Sfx")
	AudioServer.set_bus_volume_db(bus_idx, -3.0) # 0=default, in decibels

	# Route this bus to Master
	AudioServer.set_bus_send(bus_idx, "Master")

# -------------------------------------------------------------------
@onready var canvas_layer: CanvasLayer 			= $CanvasLayer
@onready var panel_container: PanelContainer	= $CanvasLayer/PanelContainer
@onready var margin_container: MarginContainer	= $CanvasLayer/PanelContainer/MarginContainer
@onready var title_dialog: VBoxContainer 		= $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer

@onready var dialog_close_button: Button 		= title_dialog.get_node("ButtonClose")

# -------------------------------------------------------------------
## enable the mouse click detection
func prepare_dialog():
	# Double-safety: ensure the UI layer keeps running while paused
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS

	# Hide dialog at start
	canvas_layer.hide()
	
	# Wire the close button
	dialog_close_button.pressed.connect(_on_title_dialog_close)

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
## Show the title screen dialog box
func show_title_dialog():
	prepare_dialog()
	set_dialog_style()
	# Freeze the entire game world
	get_tree().paused = true
	canvas_layer.show()

# -------------------------------------------------------------------
## The close button on the title dialog box was clicked
func _on_title_dialog_close():
	# Hide the dialog box and resume the game
	canvas_layer.hide()
	get_tree().paused = false
