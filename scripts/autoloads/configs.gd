extends Node
class_name Configs

# -------------------------------------------------------------------
const EMP_SCRIPT: GDScript = preload("res://scenes/emp/emp.gd")

# -------------------------------------------------------------------
const EMP01_SPRITES = preload("res://scenes/spy/sprites/emp01.tres")
const EMP02_SPRITES = preload("res://scenes/spy/sprites/emp02.tres")

# -------------------------------------------------------------------
const FOOTSTEPS01_SFX = preload("res://assets/sfx/footsteps/271911__sturmankin__carpet_15a_darkshoes_walk.wav")
const FOOTSTEPS02_SFX = preload("res://assets/sfx/footsteps/271929__sturmankin__carpet_14a_lightshoes_walk.wav")

# -------------------------------------------------------------------
static var emp01_config: EmpConfig = EmpConfig.new(
	"Mr. Bojangles",
	EMP_SCRIPT,
	"Tap dancing my way through life",
	"Fast on his feet.",
	EMP01_SPRITES,
	FOOTSTEPS01_SFX,
	1.0, 6.0, 3.0, # ratios
	100.0, 1.0, 5.0 # movement speed, wait times
)

# -------------------------------------------------------------------
static var emp02_config: EmpConfig = EmpConfig.new(
	"Ms. Mary Contrary",
	EMP_SCRIPT,
	"Doing my own thing",
	"Doing the unexpected",
	EMP02_SPRITES,
	FOOTSTEPS02_SFX,
	0.2, 9.0, 1.0, # ratios
	75.0, 1.0, 3.0 # movement speed, wait times
)

# -------------------------------------------------------------------
const ROOM01_SCENE: PackedScene  = preload("res://scenes/room/rooms/Room01.tscn")
const ROOM01_SCRIPT: GDScript    = preload("res://scenes/room/room.gd")

# -------------------------------------------------------------------
const TROUB01_MUSIC = preload("res://assets/music/Troubadeck 01 A Simple Snail.ogg")

# -------------------------------------------------------------------
# We use a static dictionary so you don't need to instantiate this class
static var rooms_config: Array[RoomConfig] = [
	RoomConfig.new("A Simple Office", ROOM01_SCENE, ROOM01_SCRIPT, TROUB01_MUSIC,
	 				[emp01_config, emp02_config])
]

# -------------------------------------------------------------------
## Retrieve the configuration data for a level (1..).
static func get_room_config(room_index: int) -> RoomConfig:
	room_index -= 1 # turn into zero-based
	assert(room_index >= 0 and room_index < rooms_config.size())
	return rooms_config[room_index]
