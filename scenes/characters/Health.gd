extends RichTextLabel

var is_radian: bool = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_angle_text(angle: Angle):
	if is_radian:
		text = "[center][color=Crimson]" + angle.get_rich_str_rad() + "[/color][/center]"
	else:
		text = "[center][color=Crimson]" + angle.get_str_deg() + "º[/color][/center]"
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
