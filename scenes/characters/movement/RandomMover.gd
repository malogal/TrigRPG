extends Node2D


var max_distance : float
var starting_point: Vector2
var target_point : Vector2
var movement_speed : float = 100.0
var timer_interval_min : float = 2.0
var timer_interval_max : float = 5.0
var timer: Node
var rng = RandomNumberGenerator.new()
var parent_body : Node2D
var pause_movement: bool = false
@export var disabled: bool = false:
	set(value):
		disabled = value
		set_process(!disabled)
			
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	parent_body = get_parent()
	set_process(false)
	

func setup(distance: float, off_center:Vector2 = Vector2.ZERO, speed: float = 100.0, timer_min: float = 2.0, timer_max: float = 5.0):
	set_process(true)
	max_distance = distance
	starting_point = parent_body.global_position + off_center
	movement_speed = speed
	timer_interval_min = timer_min
	timer_interval_max = timer_max
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = rng.randf_range(timer_interval_min, timer_interval_max)
	timer.one_shot = true
	timer.timeout.connect(_on_Timer_timeout)
	timer.start()
		
func _physics_process(delta: float) -> void:
	if pause_movement:
		return
	if Globals.isDialogActive: # If dialogue is active, stop moving character
		return
	move_character(delta)
	
	
func move_character(delta):

	#if parent_body.global_position.distance_to(target_point) < 10:
		#parent_body.velocity = Vector2.ZERO
		#pause_movement = true
		#if rng.randi() % 2 == 0:
			#generate_new_target_point()
		#return
	#
	if navigation_agent.is_navigation_finished():
		pause_movement = true
		parent_body.velocity = Vector2.ZERO
		return
	if parent_body.global_position.distance_to(starting_point) > max_distance: 
		target_point = starting_point
		navigation_agent.target_position = starting_point

	var current_agent_position: Vector2 = parent_body.global_position
	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	if next_path_position.distance_to(starting_point) > max_distance:
		navigation_agent.target_position = starting_point

	parent_body.velocity = current_agent_position.direction_to(next_path_position) * movement_speed * (delta*40)
	parent_body.move_and_slide()
	#
	#var direction: Vector2 = (target_point - parent_body.global_position).normalized()
	#parent_body.velocity = direction * movement_speed 
	# If parent has reached destination, give 50/50 chance of picking a new target or waiting for timeout 

func generate_new_target_point():
	pause_movement = false
	# Generate random distances with a bias towards max_distance
	var dx = rng.randf() * max_distance
	var dy = rng.randf() * max_distance
	
	# Square the normalized random number to bias towards the edge, then scale to max_distance
	dx *= (1 if rng.randf() > 0.5 else -1)  # Random sign
	dy *= (1 if rng.randf() > 0.5 else -1)  # Random sign
	
	# Add to the starting point to get the new target point
	target_point = starting_point + Vector2(dx, dy)
	navigation_agent.target_position = target_point
	
	#pause_movement = false
	#target_point = starting_point + Vector2(rng.randi_range(-max_distance, max_distance), rng.randi_range(-max_distance, max_distance))
	#navigation_agent.target_position = target_point
	#
func _on_Timer_timeout():
	timer.wait_time = rng.randf_range(timer_interval_min, timer_interval_max)
	timer.start()
	pause_movement = false
	generate_new_target_point()
