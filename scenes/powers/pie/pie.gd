extends RigidBody2D

var degree: int

# Pie rotation
const rotate_speed = 4

signal hit 
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedPie.play()


func new_pie(start_pos: Vector2, dir: Vector2, amount: int, pie_speed: int):
	global_position = get_parent().get_parent().global_position
	degree = amount
	linear_damp = -1
	angular_damp = -1
	angular_velocity = rotate_speed
	linear_velocity = global_position.direction_to(dir*500) * pie_speed
	#apply_central_impulse(global_position.direction_to(target*500) * speed)
	pass
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	print_debug("pie out of screen")

	
func _process(delta):
	queue_redraw()

	
func _physics_process(delta):
	pass
	# Multiply target by 500 incase they click somewhere near character

	
func _on_body_entered(body):
	print_debug("pie hit body", body)
