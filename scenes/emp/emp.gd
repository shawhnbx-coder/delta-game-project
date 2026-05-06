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
			

# -------------------------------------------------------------------
# -------------------------------------------------------------------
# make sure Monitoring=On in the Area2D (this is the default)
# make sure Pickable=On in the Area2D (this is the default)
@onready var area: Area2D 						= $Area2D
@onready var canvas_layer: CanvasLayer 			= $CanvasLayer
@onready var panel_container: PanelContainer	= $CanvasLayer/PanelContainer
@onready var margin_container: MarginContainer	= $CanvasLayer/PanelContainer/MarginContainer
@onready var talk_dialog: VBoxContainer 		= $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer

@onready var dialog_name_label: Label			= talk_dialog.get_node("NameLabel")
@onready var dialog_story_label: Label			= talk_dialog.get_node("StoryLabel")
@onready var dialog_desc_label: Label			= talk_dialog.get_node("DescLabel")
@onready var dialog_result_label: RichTextLabel	= talk_dialog.get_node("ResultLabel")
@onready var dialog_accuse_button: Button 		= talk_dialog.get_node("AccuseButton")
@onready var dialog_close_button: Button 		= talk_dialog.get_node("CloseButton")

signal clicked(emp_config: EmpConfig)
signal emp_completed(success: bool)

## delay in seconds before next room loads
const NEXT_ROOM_DELAY_SECS: float = 3.0

# -------------------------------------------------------------------
## enable the mouse click detection
func prepare_dialog():
	# Double-safety: ensure the UI layer keeps running while paused
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS

	# Hide dialog at start
	canvas_layer.hide()
	
	# set the look of the dialog box
	set_dialog_style()

	# Detect mouse clicks and put up the dialog box
	clicked.connect(_on_clicked)

	# Connect the area's input_event signal
	area.input_event.connect(_on_area_input_event)

	# Wire the accuse and close button
	dialog_accuse_button.pressed.connect(_on_dialog_accuse)
	dialog_close_button.pressed.connect(_on_dialog_close)

	# enable input event processing for this scene
	input_pickable = true

# -------------------------------------------------------------------
func set_dialog_style():
	const margin: int = 25
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)
	margin_container.add_theme_constant_override("margin_right", margin)

	var dialog_style = StyleBoxFlat.new()
	dialog_style.bg_color = Color(0.1, 0.1, 0.1, 0.9)   # near-black, 90% opaque
	dialog_style.border_color = Color(1, 1, 1, 1)         # white border
	panel_container.add_theme_stylebox_override("panel", dialog_style)

# -------------------------------------------------------------------
## Handle input events for this scene
# We use the Area CollisionShape for the clickable area
func _on_area_input_event(viewport: Node, event: InputEvent, _shape_idx: int):
	if event is InputEventMouseButton \
			and event.button_index == MOUSE_BUTTON_LEFT \
			and event.pressed:
		clicked.emit(emp_config)
		viewport.set_input_as_handled() # do not propagate event to children

# -------------------------------------------------------------------
## The mouse button was clicked over this employee
@warning_ignore("shadowed_variable")
func _on_clicked(emp_config: EmpConfig):
	# Freeze the entire game world
	get_tree().paused = true

	# Show text
	dialog_name_label.text 		= emp_config.name
	dialog_story_label.text 	= emp_config.story
	dialog_desc_label.text 		= emp_config.desc
	dialog_result_label.visible = false
	dialog_result_label.text 	= ""
	canvas_layer.show()

# -------------------------------------------------------------------
## Fancy bbcode display of room success message
# https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html
func success_message():
	var message: String = "[center][color=green][shake level=5 rate=10][font_size=24][b]"
	message += "Success!"
	message += "[/b][/font_size][/shake][/color][/center]"
	return message

# -------------------------------------------------------------------
## Fancy bbcode display of room failure message
# https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html
func failure_message():
	var message: String = "[center][color=red][shake level=5 rate=10][font_size=24][b]"
	message += "Failure!"
	message += "[/b][/font_size][/shake][/color][/center]"
	return message

# -------------------------------------------------------------------
## the accuse button on the dialog was pressed - end of level
func _on_dialog_accuse():
	var success: bool = true   # **************************
	dialog_result_label.bbcode_enabled = true # defaults to false
	dialog_result_label.fit_content = true # auto resize to fit contents - default is false
	dialog_result_label.text = (success_message() if success else failure_message())
	dialog_result_label.visible = true
	await get_tree().create_timer(NEXT_ROOM_DELAY_SECS).timeout
	canvas_layer.hide()
	get_tree().paused = false
	emp_completed.emit(success)

# -------------------------------------------------------------------
## The close button on the dialog box was clicked
func _on_dialog_close():
	# Hide the dialog box and resume the game
	canvas_layer.hide()
	get_tree().paused = false
