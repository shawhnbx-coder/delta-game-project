## Title screen
extends Node2D

# -------------------------------------------------------------------
## Room number to load first (one-based).
const FIRST_ROOM_INDEX: int = 1

# -------------------------------------------------------------------
## Load and launch the first room of the game.
func load_first_room():
	var room_config: RoomConfig = Configs.get_room_config(FIRST_ROOM_INDEX)
	var room_instance: Node2D = room_config.scene_script.create(room_config)
	add_child(room_instance) # add to tree, calls _ready()

# -------------------------------------------------------------------
## Global game initialization
func _ready() -> void:
	add_music_bus()
	add_sfx_bus()
	load_first_room()

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
