extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if rotation_degrees <= -90 and rotation_degrees > -91:
		angular_velocity = 0
	if rotation_degrees <= -91:
		angular_velocity = 1
	if rotation_degrees >= 0 and rotation_degrees < 1:
		angular_velocity = 0
	if rotation_degrees >= 1:
		angular_velocity = -1
