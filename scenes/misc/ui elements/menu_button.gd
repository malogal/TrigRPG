extends Button

@export var referencePath = ""
@export var startFocused = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if startFocused:
		grab_focus()




func _on_pressed():
	if referencePath != "":
		get_tree().change_scene_to_file(referencePath)
	else: 
		get_tree().quit()
