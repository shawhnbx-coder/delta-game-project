class_name RoomConfig

var name: String = ""
var level: int = 0
var scene: PackedScene = null
var scene_script: GDScript = null
var music: AudioStream = null
var emps: Array[EmpConfig] = []
## How many of this room's workstations get secretly infected with malware.
var malware_desk_count: int = 1

# -------------------------------------------------------------------
## Constructor for easy instantiation
@warning_ignore("shadowed_variable")
func _init(name: String, level: int, scene: PackedScene, scene_script: GDScript,
 		   music: AudioStream, emps: Array[EmpConfig], malware_desk_count: int = 1):
	self.name	= name
	self.level  = level
	self.scene	= scene
	self.scene_script = scene_script
	self.music	= music
	self.emps	= emps
	self.malware_desk_count = malware_desk_count
