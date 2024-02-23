extends RigidBody2D


const AngleClass = preload("res://misc-utility/Angle.gd")

var speed: int
var amount: Angle = AngleClass.new(PI/2)
var test_count = 100
# Pie rotation
const rotate_speed = 4

signal hit 
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedPie.play()

func new_pie(start_pos: Vector2, dir: Vector2, amount_of_pie: Angle, pie_speed: int):
	global_position = start_pos
	amount = amount_of_pie
	speed = pie_speed

	linear_damp = -1
	angular_damp = -1
	angular_velocity = rotate_speed
	linear_velocity = global_position.direction_to(dir*500) * pie_speed

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	print_debug("pie out of screen")
	
func _process(delta):
	queue_redraw()

func get_velocity() -> Vector2:
	return linear_velocity

func pie_get_amount() -> Angle: 
	return amount
