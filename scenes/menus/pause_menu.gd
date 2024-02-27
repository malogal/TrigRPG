extends Control

@onready
var settingsContainer = $SettingsContainer


func continueGame():
	hide()
	get_tree().paused = false
	settingsContainer.hide()
	
	
func pause():
	get_tree().paused = true
	show()


func _ready():
	Globals.save_game()
	get_tree().set_auto_accept_quit(false)
	hide()


func _input(event):
	if event.is_action_pressed("pause") and !get_tree().paused:
		pause()
		
	elif event.is_action_pressed("pause") and get_tree().paused and !settingsContainer.is_visible():	
		continueGame()


func _on_continue_button_pressed():
	continueGame()
	

func _on_settings_button_pressed():
	settingsContainer.show()
	

func _on_quit_button_pressed():
	Globals.save_game()
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	settingsContainer.show()


func _on_back_button_pressed():
	settingsContainer.hide()
