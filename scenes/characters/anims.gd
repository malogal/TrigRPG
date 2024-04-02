extends AnimatedSprite2D

var action_prefixes = ["throw"]
var queued_anims: Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func queue_anim(anim):
	queued_anims.push_back(anim)

func clear_queue():
	queued_anims.clear()
