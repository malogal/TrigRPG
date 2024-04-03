extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_auto_accept_quit(false)
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Globals.showGameOverScreen:
		pause()

func _input(event):
	#print(event)
	pass
	
func pause():
	Globals.save_game() 
	get_tree().paused = true
	show()
	
func _on_quit_button_pressed():
	resetPlayerHealth()
	
	Globals.save_game() 
	get_tree().paused = false
	hide()
	Globals.showGameOverScreen = false
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")


func _on_continue_button_pressed():
	resetPlayerHealth()

	get_tree().paused = false
	hide()
	Globals.showGameOverScreen = false
	
	
func resetPlayerHealth():
	var player_group = get_tree().get_nodes_in_group("player")
	if not player_group.is_empty():
		var player = player_group.pop_front()
		player.emit_signal("health_changed", 3)
		player.hitpoints = 3
