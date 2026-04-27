extends CharacterBody2D
class_name EmpScript

# -------------------------------------------------------------------
const EMP_SCENE: PackedScene = preload("res://scenes/emp/Emp.tscn")

var emp_config: EmpConfig = null

var is_emp_pct:	  float = 20.0

# -------------------------------------------------------------------
## A handle to the NPCs navigation agent used for pathfinding.
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

## Contains a handle to the animation sequences of tiles.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## Used to play the footsteps sound for the NPC.
@onready var footsteps_player: AudioStreamPlayer2D = $FootstepsPlayer2D

const speed_scale_factor: float =  60.0

# -------------------------------------------------------------------
var entry_markers: Array[Marker2D]
var  idle_markers: Array[Marker2D]
var  work_markers: Array[Marker2D]

# -------------------------------------------------------------------
var movement_targets: Array[Marker2D]

func create_movement_targets() -> void:
	var total_ratio = emp_config.entry_ratio + emp_config.idle_ratio + emp_config.work_ratio
	var entry_pct 	= emp_config.entry_ratio / total_ratio
	var idle_pct 	= (emp_config.entry_ratio + emp_config.idle_ratio) / total_ratio

	for i in range(0, 100):
		var which_type_pct: float = randf_range(0, 100)
		if which_type_pct < entry_pct:
			movement_targets.append(entry_markers.pick_random())
		elif which_type_pct < idle_pct:
			movement_targets.append(idle_markers.pick_random())
		else:
			movement_targets.append(work_markers.pick_random())

# -------------------------------------------------------------------
var   is_waiting:     bool  = false
var   is_spy:         bool  = false

# -------------------------------------------------------------------
# -------------------------------------------------------------------
@warning_ignore("shadowed_variable")
static func create(emp_config: EmpConfig, entry_markers: Array[Marker2D],
			   	   idle_markers: Array[Marker2D], work_markers: Array[Marker2D],
			 	   is_spy: bool) -> CharacterBody2D:
	var emp_instance = EMP_SCENE.instantiate() # create, calls _init()
	emp_instance.configure(emp_config, entry_markers, idle_markers, work_markers, is_spy)
	return emp_instance

# -------------------------------------------------------------------
## Custom setup function to be called by the level spawner
@warning_ignore("shadowed_variable")
func configure(emp_config: EmpConfig, entry_markers: Array[Marker2D],
			   idle_markers: Array[Marker2D], work_markers: Array[Marker2D], is_spy: bool) -> void:
	assert(!entry_markers.is_empty())
	assert(!idle_markers.is_empty())
	assert(!work_markers.is_empty())
	self.emp_config 	= emp_config
	self.is_spy			= is_spy
	self.entry_markers	= entry_markers
	self.idle_markers	= idle_markers
	self.work_markers	= work_markers
	create_movement_targets()

# -------------------------------------------------------------------
## Called when node and children have been added to scene tree.
func _ready() -> void:
	animated_sprite.sprite_frames = emp_config.sprites
	animated_sprite.play("idle_down") # Ensure all your NPCs use the same animation names

	add_to_group("NPCs")
	animated_sprite.set_sprite_frames(emp_config.sprites)
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	_select_next_target()
	footsteps_player.stream = emp_config.footsteps
 
# -------------------------------------------------------------------
# -------------------------------------------------------------------
func set_movement_target(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

# -------------------------------------------------------------------
func _select_next_target():
	if movement_targets.is_empty(): # Fallback: if we have no queue, try to rebuild it
		print("_select_next_target: movement_targets.is_empty()")
		create_movement_targets()
		if movement_targets.is_empty(): return 

	var next_marker = movement_targets.pick_random() # Pick a random marker from the array
	navigation_agent.target_position = next_marker.global_position
	is_waiting = false

# -------------------------------------------------------------------
## Perform physics calculation such as movement.
## [delta] Number of seconds since the last physics clock tick.
##         Underscore prefix signifies the variable is not used.
##         move_and_slide() has its own copy of the value
func _physics_process(_delta: float) -> void:
	# Do not query when the map has never synchronized and is empty.
	if is_waiting or NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		_start_waiting()
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * emp_config.movement_speed
	navigation_agent.set_velocity(new_velocity)

# -------------------------------------------------------------------
func _start_waiting():
	is_waiting = true
	velocity = Vector2.ZERO
	# Create a one-shot timer for 1 to 5 seconds
	var wait_time: float = randf_range(emp_config.wait_time_min, emp_config.wait_time_max)
	await get_tree().create_timer(wait_time).timeout
	_select_next_target()

# -------------------------------------------------------------------
## Gets called when the pathfinding (NavigationAgent) has computed the direction of travel.
## Only gets called if AnimatedSprite2D.Avoidance == true.
func _on_velocity_computed(safe_velocity: Vector2):
	velocity = safe_velocity
	move_and_slide()
	update_animation()
	play_footsteps()

# -------------------------------------------------------------------
## Get the name of the direction the NPC is heading towards.
## Returns left, right, up, or down depending on the velocity direction.
func get_direction_name() -> String:
	# Normalize the velocity to get a direction vector (e.g., (0.7, 0.3))
	var direction = velocity.normalized()

	if abs(direction.x) > abs(direction.y): # Is horizontal movement more dominant?
		if direction.x > 0:
			return "right"
		else:
			return "left"
	else: # Vertical movement is dominant
		if direction.y < 0:
			return "up"
		else:
			return "down" # also used for Vector2(0, 0)

# -------------------------------------------------------------------
## Play a different animation depending on what the NPC is doing.
func update_animation() -> void:
	var dir_name = get_direction_name()
	var current_velocity = velocity.length()

	# If the NPC isn't moving, play the idle animation or stay on the current frame
	if current_velocity < 0.1:
		animated_sprite.play("idle_" + dir_name)
		animated_sprite.speed_scale = 1.0 # Reset to normal speed when idle
	else:
		animated_sprite.play("walk_" + dir_name)
		# Adjust the 100.0 divisor based on your intended 'normal' walk speed
		animated_sprite.speed_scale = current_velocity / speed_scale_factor

# -------------------------------------------------------------------
func play_footsteps() -> void:
	if velocity.length() >= 0.1:
		if not footsteps_player.playing:
			footsteps_player.bus = "Sfx"
			footsteps_player.play()
			footsteps_player.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	else:
		if footsteps_player.playing:
			footsteps_player.stop()
