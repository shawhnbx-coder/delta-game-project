extends Node2D
class_name RoomScript

# -------------------------------------------------------------------
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
signal room_completed(success: bool)

# -------------------------------------------------------------------
var room_config: RoomConfig = null
var entry_markers: Array[Marker2D]
var  idle_markers: Array[Marker2D]
var  work_markers: Array[Marker2D]

# -------------------------------------------------------------------
# -------------------------------------------------------------------
@warning_ignore("shadowed_variable")
static func create(room_config: RoomConfig, score: int) -> Node2D:
	var room_instance = room_config.scene.instantiate() # create, calls _init()
	room_instance.configure(room_config, score)
	return room_instance

## Display the game's score in the upper left corner
func display_hud(score: int) -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "HUD"
	canvas_layer.layer = 1  # render above default (0)
	add_child(canvas_layer)

	var label = RichTextLabel.new()
	label.bbcode_enabled 	= true
	var level_text: String 	= "[i]Level:[/i]  [b]" + str(room_config.level) + "[/b]"
	var score_text: String 	= "[i]Score:[/i]  [b]" + str(score) + "[/b]"
	label.text 				= level_text + "   " + score_text

	# Anchor to top-left
	label.anchor_left 	= 0.0
	label.anchor_top 	= 0.0
	label.anchor_right 	= 0.0
	label.anchor_bottom = 0.0

	# Position at (0,0) with no offset
	label.offset_left 	= 0
	label.offset_top 	= 0
	label.offset_right 	= 200   # minimum width, optional
	label.offset_bottom = 30   # minimum height, optional

	# Add to a CanvasLayer (or any Control parent)
	canvas_layer.add_child(label)
	
# -------------------------------------------------------------------
@warning_ignore("shadowed_variable", "unused_parameter")
func configure(room_config: RoomConfig, score: int) -> void:
	self.room_config = room_config
	display_hud(score)

# -------------------------------------------------------------------
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	populate_marker_arrays()
	spawn_emps()
	play_music()

# -------------------------------------------------------------------
func populate_marker_arrays() -> void:
	assert(has_node("markers"), "populate_marker_arrays: no markers found")
	var markers_node = get_node("markers")
	for child in markers_node.get_children():
		assert(child is Marker2D, "populate_marker_arrays: type not Marker2D")
		if child.name.begins_with("entry"): entry_markers.append(child)
		elif child.name.begins_with("idle"): idle_markers.append(child)
		elif child.name.begins_with("work"): work_markers.append(child)

# -------------------------------------------------------------------
## Spawns an NPC at a specific coordinate
func spawn_emps() -> void:
	var the_spy: EmpConfig = room_config.emps.pick_random()   # select the spy
	for emp_config: EmpConfig in room_config.emps:
		var emp_scene: CharacterBody2D = emp_config.scene_script.create(emp_config,
			entry_markers, idle_markers, work_markers, emp_config == the_spy)
		emp_scene.emp_completed.connect(_on_emp_completed)
		emp_scene.global_position = entry_markers.pick_random().global_position # do before adding to tree
		$employees.add_child(emp_scene) # add to tree so it becomes visible and active; calls _ready()

# -------------------------------------------------------------------
func _on_emp_completed(success):
	room_completed.emit(success)


func play_music() -> void:
	audio_stream_player.stream = room_config.music
	audio_stream_player.stream.loop = true
	audio_stream_player.play()
