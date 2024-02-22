extends RigidBody2D

const AngleClass = preload("res://misc-utility/Angle.gd")

var speed: int
var amount: Angle = AngleClass.new(PI/2)
var test_count = 100

# Pie rotation
const rotate_speed = 350
var current_rotation = 0
var vec: Vector2
var target: Vector2
#@export var texture : Texture2D:
	#set(value):
		#texture = value
		#queue_redraw()

#func _draw():
	#draw_texture(texture,position)

signal hit 
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedPie.play()


func new_pie(start_pos: Vector2, dir: Vector2, amount_of_pie: Angle, pie_speed: int):
	global_position = start_pos
	target = dir
	amount = amount_of_pie
	speed = pie_speed

	pass
	
func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	print_debug("pie out of screen")

	
func _process(delta):
	queue_redraw()

	
func _physics_process(delta):
	linear_velocity = global_position.direction_to(target*500) * speed
	angular_velocity = delta*rotate_speed

	
func _on_body_entered(body):
	print_debug("pie hit body", body)

