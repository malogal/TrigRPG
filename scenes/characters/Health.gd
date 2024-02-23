extends Label

@export var is_radian: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_angle_text(angle: Angle):
	if is_radian:
		text = angle.get_str_rad()
	else:
		text = angle.get_str_deg()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
