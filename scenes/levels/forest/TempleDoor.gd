extends AnimatedSprite2D

@export var radius: int = 20
var is_player_present = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		play("default")
		is_player_present = true
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
#		play("default", 1.0, true)
		play_backwards(	"default")
		is_player_present = false