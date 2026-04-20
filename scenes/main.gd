extends Node2D

const FIRST_ROOM_INDEX: int = 1

# -------------------------------------------------------------------
func _ready() -> void:
	var room_config: RoomConfig = Configs.get_room_config(FIRST_ROOM_INDEX)
	var room_instance: Node2D = room_config.scene_script.create(room_config)
	add_child(room_instance) # add to tree, calls _ready()
