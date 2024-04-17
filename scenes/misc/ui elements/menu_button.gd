extends Button

@export var referencePath = ""
@export var startFocused = false

var packed_scene: PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	packed_scene = load(referencePath)
	if startFocused:
		grab_focus()




func _on_pressed():
	if referencePath != "":
		get_tree().change_scene_to_packed(packed_scene)
	else: 
		get_tree().quit()
