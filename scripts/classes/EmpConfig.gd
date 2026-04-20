class_name EmpConfig

var name: String = ""
var scene_script: GDScript = null
var story: String = ""
var desc: String = ""
var sprites: SpriteFrames = null
var footsteps: AudioStream = null
var entry_ratio: float = 1.0
var idle_ratio: float = 1.0
var work_ratio: float = 1.0
var movement_speed: float = 5.0
var wait_time_min: float = 1.0
var wait_time_max: float = 5.0

# -------------------------------------------------------------------
## Constructor for easy instantiation
@warning_ignore("shadowed_variable")
func _init(name: String, scene_script: GDScript, story: String, desc: String, sprites: SpriteFrames,
		   footsteps: AudioStream, entry_ratio: float, idle_ratio: float, work_ratio: float,
		   movement_speed: float, wait_time_min: float, wait_time_max: float):
	self.name 			= name
	self.scene_script   = scene_script
	self.story			= story
	self.desc			= desc
	self.sprites		= sprites
	self.footsteps		= footsteps
	self.entry_ratio 	= entry_ratio
	self.idle_ratio 	= idle_ratio
	self.work_ratio 	= work_ratio
	self.movement_speed	= movement_speed
	self.wait_time_min 	= wait_time_min
	self.wait_time_max 	= wait_time_max
