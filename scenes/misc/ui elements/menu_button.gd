extends Button

@export var referencePath = ""
@export var startFocused = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if startFocused:
		grab_focus()
		
	#connect("mouse_entered", self, "_on_Button_mouse_entered")
	#connect("pressed", self, "_on_Button_Pressed")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_pressed():
	if referencePath != "":
		get_tree().change_scene_to_file(referencePath)
	else: 
		get_tree().quit()
