extends RigidBody2D

var original_position

enum { AMPLITUDE, FREQUENCY, SHIFT_LR, SHIFT_UD }
@export var type = FREQUENCY
@export var amount := 2

var teleport := false

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

func remove():
	teleport = true
	#set_sleeping(true)
	#$CollisionShape2D.disabled = true
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	set_deferred("sleeping",true)
	visible = false
func reset():
	teleport = true
	#set_sleeping(false)
	#$CollisionShape2D.disabled = false
	set_deferred("collision_layer", 1)
	set_deferred("collision_mask", 1)
	set_deferred("sleeping",false)
	visible = true
func _integrate_forces(state):
	if teleport:
		var new_transform = state.get_transform()
		new_transform.origin = original_position
		state.set_transform(new_transform)
		teleport = false

func _on_body_entered(body):
	print("transformation hit by")
	print(body)
	if body.is_in_group("pie") and visible:
		reset()
