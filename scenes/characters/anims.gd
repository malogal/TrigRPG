extends AnimatedSprite2D

var action_prefixes = ["throw"]
signal action_animation_complete
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if frame == sprite_frames.get_frame_count(animation) and animation.split("_",true,0)[0] in action_prefixes:
		action_animation_complete.emit()



	
