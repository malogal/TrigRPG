extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_auto_accept_quit(false)
	hide()
	Globals.game_over_screen_status.connect(func(is_active: bool): if is_active: pause())
	$PanelContainer/HBoxContainer/VBoxContainer/ContinueButton.disabled = !Globals.demo_mode

func _input(event):
	#print(event)
	pass
	
func pause():
	if Globals.get_player().is_in_group("in_cutscene"):
		resetPlayerHealth()
		Globals.showGameOverScreen = false
		return
	# Only save in demo mode. Otherwise saving would leave the player with no health
	if Globals.demo_mode:
		Globals.save_game() 
	var btn1 = $PanelContainer/HBoxContainer/VBoxContainer/ContinueButton
	$PanelContainer/HBoxContainer/VBoxContainer/ContinueButton.disabled = !Globals.demo_mode
	var btn2 = $PanelContainer/HBoxContainer/VBoxContainer/ContinueButton
	var stat = btn1.disabled
	var stat2 = btn2.disabled
	get_tree().paused = true
	show()
	
func _on_quit_button_pressed():	
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
	var player: Player = Globals.get_player()
	if player == null:
		player = get_tree().get_first_node_in_group("player")	
	player.emit_signal("health_changed", 3)
	player.hitpoints = 3
