extends StaticBody2D

@export var puzzle : StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CollisionShape2D.disabled = puzzle.success
	$Locked.visible = not puzzle.success
	$Unlocked.visible = puzzle.success
