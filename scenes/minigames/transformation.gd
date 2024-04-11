extends RigidBody2D

var original_position

enum { AMPLITUDE, FREQUENCY, SHIFT_LR, SHIFT_UD }
@export var type = AMPLITUDE
@export var amount := 1

var teleport_cd := -1

func evaluate(input):
	if type==AMPLITUDE or type==FREQUENCY:
		return input*amount
	return input+amount

# Called when the node enters the scene tree for the first time.
func _ready():
	original_position = global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	linear_velocity *= 0.5
	if teleport_cd>=0:
		global_position = original_position
		teleport_cd -= 1
	if teleport_cd==0:
		set_physics_process(true)


func reset():
	set_physics_process(false)
	teleport_cd = 10
