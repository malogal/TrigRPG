extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = Globals.demo_mode
	Globals.demo_mode_changed.connect(func(is_active: bool): visible=is_active)
