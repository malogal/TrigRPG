extends AnimatedSprite2D

func _ready():
	animation_finished.connect(queue_free)
	pass # Replace with function body.

