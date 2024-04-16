extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().get_parent().success:
		label_settings.font_color = Color.FOREST_GREEN
		queue_redraw()
	else:
		label_settings.font_color = Color.CRIMSON
