extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.loadGameToggle:	
		Globals.load_game()
		Globals.showGameOverScreen = false
	Input.set_use_accumulated_input(false)