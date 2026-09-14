extends Node
class_name Configs

# -------------------------------------------------------------------
const EMP_SCRIPT: GDScript = preload("res://scenes/emp/emp.gd")

# -------------------------------------------------------------------
const EMP01_SPRITES = preload("res://scenes/emp/sprites/emp01.tres")
const EMP02_SPRITES = preload("res://scenes/emp/sprites/emp02.tres")
const EMP03_SPRITES = preload("res://scenes/emp/sprites/emp03.tres")

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
## Ordinary desktop files shown alongside the malware on a desk's screen.
## Includes a few correctly-spelled everyday app names on purpose, so they
## can occasionally sit right next to their typo'd MALWARE_FILE_NAMES twin.
const NORMAL_FILE_NAMES: Array[String] = [
	"Q3_Report.docx", "Payroll.xlsx", "TeamPhoto.png", "Notes.txt",
	"Invoice_0421.pdf", "Presentation.pptx", "Budget.xlsx", "Recycle Bin",
	"Meeting_Minutes.docx", "Vacation_Request.pdf", "Org_Chart.png",
	"Expense_Report.xlsx", "Onboarding_Guide.pdf", "IT_Policy.docx",
	"Chrome.exe", "Zoom.exe", "Spotify.exe", "Slack.exe", "Adobe Reader.exe"
]

## The suspicious file that shows up on an infected desk - one is picked at
## random. Mostly typosquats of common apps (swapped/extra/missing letters,
## a zero for an "o") since an obviously-named virus is too easy to spot.
const MALWARE_FILE_NAMES: Array[String] = [
	"svch0st.exe", "FreeGiftCard.scr", "systemUpdate32.bat",
	"invoice_view.exe", "READ_ME_URGENT.exe", "Setup_Codec.exe",
	"Chr0me.exe", "Z00m.exe", "Spotifyy.exe", "Slakk.exe",
	"Adobe Reeder.exe", "Notepad++_lnstall.exe", "Sk ype_Setup.exe"
]

# -------------------------------------------------------------------
static var emp01_config: EmpConfig = EmpConfig.new(
	"Ms. Bojangles",
	EMP_SCRIPT,
	"Color-codes their calendar and still finds time to make you feel behind.",
	"The Overachiever",
	EMP01_SPRITES,
	FOOTSTEPS01_SFX,
	1.0, 6.0, 5.0, # ratios
	100.0, 2.0, 7.0 # movement speed, wait times
)

# -------------------------------------------------------------------
static var emp02_config: EmpConfig = EmpConfig.new(
	"Sammy Ford",
	EMP_SCRIPT,
	"Really likes dodging work.",
	"Who needs cheesy titles",
	EMP02_SPRITES,
	FOOTSTEPS02_SFX,
	0.2, 8.0, 3.0, # ratios
	75.0, 2.0, 5.0 # movement speed, wait times
)

# -------------------------------------------------------------------
static var emp03_config: EmpConfig = EmpConfig.new(
	"David Stevens",
	EMP_SCRIPT,
	"Solves 90% of office conflicts with a granola bar.",
	"The Snack Diplomat",
	EMP03_SPRITES,
	FOOTSTEPS01_SFX,
	1.0, 6.0, 5.0, # ratios
	100.0, 2.0, 7.0 # movement speed, wait times
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
	 				[emp01_config, emp02_config, emp03_config]),
	RoomConfig.new("A Simple Office", 5, ROOM01_SCENE, ROOM01_SCRIPT, TROUB01_MUSIC,
	 				[emp01_config, emp02_config, emp03_config])
]

# -------------------------------------------------------------------
## Retrieve the configuration data for a level (1..).
func get_room_config(room_index: int) -> RoomConfig:
	room_index -= 1 # turn into zero-based
	assert(room_index >= 0 and room_index < rooms_config.size())
	return rooms_config[room_index]

# -------------------------------------------------------------------
## Total number of configured rooms/levels.
func get_room_count() -> int:
	return rooms_config.size()
