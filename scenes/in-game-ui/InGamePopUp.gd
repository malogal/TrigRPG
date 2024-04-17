extends PopupPanel

# Duration before the popup hides automatically
var display_duration = 2.0  # seconds

func show_message(text: String, time_out: int = 0, is_transparent: bool = true):
	if time_out == 0:
		time_out = display_duration
	$Label.text = text  # If you're using PopupDialog without a Label
	transparent_bg = is_transparent
	#popup_centered(Vector2(200, 100))  # Adjust size as needed
	await get_tree().create_timer(time_out).timeout
	get_parent().remove_child(self)
	queue_free()

