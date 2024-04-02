extends Node2D


var bounding_rect : Rect2
var target_point : Vector2
var movement_speed : float = 100.0
var timer_interval_min : float = 2.0
var timer_interval_max : float = 5.0
var timer: Node
var rng = RandomNumberGenerator.new()
var parent_body : Node 

func _ready():
	parent_body = get_parent()
	set_process(false)
	

func setup(rect: Rect2 = Rect2(0, 0, 100, 100), speed: float = 100.0, timer_min: float = 2.0, timer_max: float = 5.0):
	set_process(true)
	bounding_rect = rect
	movement_speed = speed
	timer_interval_min = timer_min
	timer_interval_max = timer_max
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = rng.randf_range(timer_interval_min, timer_interval_max)
	timer.one_shot = true
	timer.timeout.connect(_on_Timer_timeout)
	timer.start()
	
func _process(delta):
	move_character(delta)

func move_character(delta):
	var direction = (target_point - parent_body.position).normalized()
	parent_body.velocity = direction * movement_speed 
	parent_body.move_and_slide()
	# If parent has reached destination, give 50/50 chance of picking a new target or waiting for timeout 
	if parent_body.position.distance_to(target_point) < 10 && rng.randi() % 2 == 0:
		generate_new_target_point()

func generate_new_target_point():
	if not bounding_rect.has_point(parent_body.position):
		# If outside, reset to center
		target_point = bounding_rect.position + bounding_rect.size * 0.5
	else:
		target_point = bounding_rect.position + Vector2(rng.randi_range(0, bounding_rect.size.x), rng.randi_range(0, bounding_rect.size.y))

func _on_Timer_timeout():
	timer.wait_time = rng.randf_range(timer_interval_min, timer_interval_max)
	timer.start()
	generate_new_target_point()
