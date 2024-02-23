extends RigidBody2D

var degree: int
# Pie rotation
const rotate_speed = 4
var amount = 1
signal hit 
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedPie.animation = "amount_"+str(amount)
	$AnimatedPie.play()


func new_pie(start_pos: Vector2, dir: Vector2, amt: int, pie_speed: int):
	global_position = start_pos
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

func get_velocity() -> Vector2:
	return linear_velocity

	
func _on_body_entered(body):
	print_debug("pie hit body", body)
