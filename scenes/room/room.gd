extends Node2D
class_name RoomScript

# -------------------------------------------------------------------
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# -------------------------------------------------------------------
var room_config: RoomConfig = null
var entry_markers: Array[Marker2D]
var  idle_markers: Array[Marker2D]
var  work_markers: Array[Marker2D]

# -------------------------------------------------------------------
# -------------------------------------------------------------------
@warning_ignore("shadowed_variable")
static func create(room_config: RoomConfig) -> Node2D:
	var room_instance = room_config.scene.instantiate() # create, calls _init()
	room_instance.configure(room_config)
	return room_instance

# -------------------------------------------------------------------
@warning_ignore("shadowed_variable")
func configure(room_config: RoomConfig) -> void:
	self.room_config = room_config

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
	for emp_config: EmpConfig in room_config.spies:
		var emp_scene: CharacterBody2D = emp_config.scene_script.create(emp_config,
			entry_markers, idle_markers, work_markers, false)
		emp_scene.global_position = entry_markers.pick_random().global_position # do before adding to tree
		$npcs.add_child(emp_scene) # add to tree so it becomes visible and active; calls _ready()

# -------------------------------------------------------------------
func play_music() -> void:
	audio_stream_player.stream = room_config.music
	audio_stream_player.stream.loop = true
	audio_stream_player.play()
