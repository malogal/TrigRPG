extends RigidBody2D


var degree: int
var test_count = 100

# Pie rotation
const rotate_speed = 10
var current_rotation = 0

signal hit 
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedPie.play()
	pass # Replace with function body.

func new_pie(start_pos: Vector2, dir: Vector2, amount: int, pie_speed: int):
	position = start_pos
	degree = amount
	linear_velocity = Vector2(pie_speed, 0).rotated(dir.angle())
	pass
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	#queue_free()
	print_debug("pie out of screen")
	pass # Replace with function body.
	
func _process(delta):
	current_rotation = roundi(current_rotation + delta*rotate_speed) % 360
	set_rotation_degrees(current_rotation)

func _on_body_entered(body):
	print_debug("pie hit body", body)
	pass # Replace with function body.
