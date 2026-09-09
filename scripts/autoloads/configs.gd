extends Node
class_name Configs

# -------------------------------------------------------------------
const EMP_SCRIPT: GDScript = preload("res://scenes/emp/emp.gd")

# -------------------------------------------------------------------
const EMP01_SPRITES = preload("res://scenes/emp/sprites/emp01.tres")
const EMP02_SPRITES = preload("res://scenes/emp/sprites/emp02.tres")

# -------------------------------------------------------------------
const FOOTSTEPS01_SFX = preload("res://assets/sfx/footsteps/271911__sturmankin__carpet_15a_darkshoes_walk.wav")
const FOOTSTEPS02_SFX = preload("res://assets/sfx/footsteps/271929__sturmankin__carpet_14a_lightshoes_walk.wav")

const OFFICE01_SFX = preload("res://assets/sfx/office/Cabinet Lock Sfx.wav")
const OFFICE02_SFX = preload("res://assets/sfx/office/Cup On Table Sfx.wav")
const OFFICE03_SFX = preload("res://assets/sfx/office/Double Click Mouse Sfx.wav")
const OFFICE04_SFX = preload("res://assets/sfx/office/Light Switch Click On Sfx.wav")
const OFFICE05_SFX = preload("res://assets/sfx/office/Office Chair Roll Sfx.wav")
const OFFICE06_SFX = preload("res://assets/sfx/office/Page Turning Sfx.wav")
const OFFICE07_SFX = preload("res://assets/sfx/office/Paper Crumple Crumpling Scrunch Crunch Sfx.wav")
const OFFICE08_SFX = preload("res://assets/sfx/office/Pen Click Sfx.wav")
const OFFICE09_SFX = preload("res://assets/sfx/office/Slow Office Clock Tick Sfx.wav")
const OFFICE10_SFX = preload("res://assets/sfx/office/Tissue Out Of Box Sfx.wav")
const OFFICE11_SFX = preload("res://assets/sfx/office/Typing Sfx.wav")

var OFFICE_SOUNDS: Array[Resource] = \
	[OFFICE01_SFX, OFFICE02_SFX, OFFICE03_SFX, OFFICE04_SFX, OFFICE05_SFX, \
	 OFFICE06_SFX, OFFICE07_SFX, OFFICE08_SFX, OFFICE09_SFX, OFFICE10_SFX, OFFICE11_SFX]
	
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
	RoomConfig.new("A Simple Office", 1, ROOM01_SCENE, ROOM01_SCRIPT, TROUB01_MUSIC,
	 				[emp01_config]), 
	RoomConfig.new("A Simple Office", 2, ROOM01_SCENE, ROOM01_SCRIPT, TROUB01_MUSIC,
	 				[emp02_config]),
	RoomConfig.new("A Simple Office", 3, ROOM01_SCENE, ROOM01_SCRIPT, TROUB01_MUSIC,
	 				[emp01_config, emp02_config]),
	RoomConfig.new("A Simple Office", 4, ROOM01_SCENE, ROOM01_SCRIPT, TROUB01_MUSIC,
	 				[emp01_config, emp02_config]),
	RoomConfig.new("A Simple Office", 5, ROOM01_SCENE, ROOM01_SCRIPT, TROUB01_MUSIC,
	 				[emp01_config, emp02_config])
]

# -------------------------------------------------------------------
## Retrieve the configuration data for a level (1..).
func get_room_config(room_index: int) -> RoomConfig:
	room_index -= 1 # turn into zero-based
	assert(room_index >= 0 and room_index < rooms_config.size())
	return rooms_config[room_index]
