extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button_up.connect(func(): 
		Globals.demo_mode = !Globals.demo_mode
		Globals.create_popup_window("Save settings to apply changes.", 2.0, false)
	)
