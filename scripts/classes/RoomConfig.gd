class_name RoomConfig

var name: String = ""
var scene: PackedScene = null
var scene_script: GDScript = null
var music: AudioStream = null
var emps: Array[EmpConfig] = []

# -------------------------------------------------------------------
## Constructor for easy instantiation
@warning_ignore("shadowed_variable")
func _init(name: String, scene: PackedScene, scene_script: GDScript,
 		   music: AudioStream, emps: Array[EmpConfig]):
	self.name	= name
	self.scene	= scene
	self.scene_script = scene_script
	self.music	= music
	self.emps	= emps
