extends Button

var testGamePath = "res://scenes/levels/testing/TestOutside.tscn"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = Globals.demo_mode
	Globals.demo_mode_changed.connect(func(is_active: bool): visible=is_active)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	Globals.in_test_mode = true
	get_tree().change_scene_to_file(testGamePath)
