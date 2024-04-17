extends Control

@onready
var settingsContainer = $SettingsContainer

var settingsPath = "user://settings.save"

@onready
var inputButtonScene = preload("res://scenes/menus/keybind_input_button.tscn")
@onready
var actionList = $SettingsContainer/PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

@onready
var musicAudioSlider = $SettingsContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MusicAudio
@onready
var masterAudioSlider = $SettingsContainer/PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MasterAudioSlider

var masterAudio
var musicAudio

@onready
var mainMenuScene = "res://scenes/menus/main_menu.tscn"

var isRemapping = false
var actionToRemap = null
var remappingButton = null

var inputActions = {
	"move_up": {"label": "Move Up", "keycode": KEY_W, "modifierKey": ""},
	"move_down": {"label": "Move Down", "keycode": KEY_S, "modifierKey": ""},
	"move_left": {"label": "Move Left", "keycode": KEY_A, "modifierKey": ""},
	"move_right": {"label": "Move Right", "keycode": KEY_D, "modifierKey": ""},
	"interact": {"label": "Interact", "keycode": KEY_E, "modifierKey": ""},	
	"throw_pie": {"label": "Throw Pie", "keycode": MOUSE_BUTTON_LEFT, "modifierKey": MOUSE_BUTTON_LEFT},
	"teleport": {"label": "Teleport", "keycode": KEY_TAB, "modifierKey": ""},
	"wave": {"label": "Wave", "keycode": KEY_F, "modifierKey": ""},
	"change_pie_measurement_positive": {"label": "Change Pie Measurement (Positive)", "keycode": KEY_SPACE, "modifierKey": ""},
	"change_pie_measurement_negative": {"label": "Change Pie Measurement (Negative)", "keycode": KEY_SPACE, "modifierKey": KEY_SHIFT},
	"skip_cutscene": {"label": "Skip Cutscene", "keycode": KEY_X, "modifierKey": ""}
}

var settingsDictionary = {}
var defaultKeybinds = []
var keybinds = []
var defaultMusicAudio = 0.25
var defaultMasterAudio = 0.25

var debug_teleport_btn = preload("res://scenes/menus/repeatable_button.tscn")

func continueGame():
	hide()
	get_tree().paused = false
	settingsContainer.hide()
	
	
func pause():
	Globals.save_game() 
	get_tree().paused = true
	show()


func _ready():
	get_tree().set_auto_accept_quit(false)
	hide()
	$SettingsContainer.hide()
	# for settings/remapping
	getSettingsFromFile()
	createActionList()
	load_menu_button()
	$PanelContainer/Grid/DropDownMenu.visible = Globals.demo_mode
	Globals.demo_mode_changed.connect(func(is_active: bool): $PanelContainer/Grid/DropDownMenu.visible=is_active)


func _input(event):
	# pause menu
	if event.is_action_pressed("pause") and !get_tree().paused:
		pause()
		
	elif event.is_action_pressed("pause") and get_tree().paused and !settingsContainer.is_visible():	
		continueGame()
		
	# settings/remapping
	if isRemapping:
		if event is InputEventKey || (event is InputEventMouseButton && event.pressed):
			# turn double click into single click
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false
				
			#if event is mouse event, non-modifier event, or modifier key that isn't pressed
			if event is InputEventMouseButton || !isModifierKey() || (isModifierKey() && !event.is_pressed()):
				InputMap.action_erase_events(actionToRemap)
				InputMap.action_add_event(actionToRemap, event)
			
				updateActionList(remappingButton, event)
				
				remapActionInProjectSettings(actionToRemap, event)

				isRemapping = false
				actionToRemap = null
				remappingButton = null
				accept_event()
				
## Create a list of places to teleport and display the buttons as an option from pause menu.
## Buttons disapear when not in demo-mode. 
func load_menu_button():
	var menuButton = $PanelContainer/Grid/DropDownMenu
	menuButton.button_down.connect(
		func():
			$PanelContainer/Grid/DropDownMenu/VBoxContainer.visible = !$PanelContainer/Grid/DropDownMenu/VBoxContainer.visible 
	)
	$PanelContainer/Grid/DropDownMenu/VBoxContainer.visible = false
	var container = $PanelContainer/Grid/DropDownMenu/VBoxContainer
	var nodes: Array =  get_tree().get_nodes_in_group("debug_teleport")
	var prev_btn: Button = null
	for node in nodes:
		var btn: Button = debug_teleport_btn.instantiate()
		btn.text = node.location_name
		btn.set_meta("location", node.global_position)
		# When a teleport location is pressed, unpause the game,teleport player, 
		# and then call re-pause the next frame. 
		btn.button_down.connect(
			func(): 
				node.teleport_player()
				pause_game(false)
				call_deferred("pause_game", true)
		)
		if prev_btn == null:
			container.add_child(btn)
		else:
			prev_btn.add_sibling(btn)
		prev_btn = btn

func pause_game(pause: bool):
	get_tree().paused = pause
						
func _on_continue_button_pressed():
	continueGame()
	

func _on_settings_button_pressed():
	settingsContainer.show()
	

func _on_quit_button_pressed():
	get_tree().paused = false
	hide()
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	settingsContainer.show()


func _on_back_button_pressed():
	settingsContainer.hide()
	
	
#for settings
func getSettingsFromFile():
	if FileAccess.file_exists(settingsPath):
		var savefile = FileAccess.open(settingsPath, FileAccess.READ)
		
		settingsDictionary = savefile.get_var()
		savefile.close()

		#set audio
		musicAudioSlider.value = settingsDictionary.musicAudio
		masterAudioSlider.value = settingsDictionary.masterAudio
		
		#set keybinds
		keybinds = settingsDictionary.keybinds

	decodeKeybinds()
	mapKeybindsToProject(keybinds)


#for decoding the keybinds that are saved as EncodedObjectAsID in file
func decodeKeybinds():
	var decodedKeybinds = []

	for keybind in keybinds:
		if keybind.action is EncodedObjectAsID:
			keybind.action = instance_from_id(keybind.action["object_id"])
		decodedKeybinds.append(keybind)
		
	keybinds = decodedKeybinds
	
	
func mapKeybindsToProject(keybindList):
	var currentKeybinds = []
	for action in keybindList:
		if action.action == null:
			if action.actionKey != -1:
				action.action = generateKey(action.actionKey, action.actionModifier)
			elif action.actionMouse != -1:
				action.action = generateKey(action.actionMouse, action.actionModifier)

		var tempAction = {
			"actionName": action.actionName,
			"actionLabel": action.actionLabel,
			"action": action.action,
			"actionKeycode": action.action.as_text(),
			"actionModifier": getKeybindModifier(action.action)
		}
		
		currentKeybinds.append(tempAction)
	
	keybinds = currentKeybinds
	
func createActionList():
	for item in actionList.get_children():
		item.queue_free()
		
	for action in keybinds:

		var actionKeycode = action.actionKeycode
		var actionInputName = action.actionName
		var actionFullLabel = action.actionLabel
		var events = action.action
#
		var button = inputButtonScene.instantiate()
		var actionLabel = button.find_child("LabelAction")
		var inputLabel = button.find_child("LabelInput")

		actionLabel.text = actionFullLabel
#
		if events:
			inputLabel.text = actionKeycode.trim_suffix(" (Physical)")
		else:
			inputLabel.text = ""
			
		actionList.add_child(button)
		button.pressed.connect(_on_keybind_input_button_pressed.bind(button, actionInputName))

		
func _on_keybind_input_button_pressed(button, action):
	if !isRemapping:
		isRemapping = true
		actionToRemap = action
		remappingButton = button
		button.find_child("LabelInput").text = "Press key to bind..."


func updateActionList(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")


func isModifierKey():
	return Input.is_key_pressed(KEY_SHIFT) || Input.is_key_pressed(KEY_ALT) || Input.is_key_pressed(KEY_CTRL) || Input.is_key_pressed(KEY_META)
	

func remapActionInProjectSettings(actionToRemap, newEvent):	
	var newSettingName = "input/" + actionToRemap
	var currentSetting = ProjectSettings.get_setting(newSettingName)
	var updatedEvent = {
		"deadzone": 0.5,
		"events": [newEvent]
	}

	ProjectSettings.set_setting(newSettingName, updatedEvent)


func _on_reset_button_pressed():
	# reset audio
	musicAudioSlider.value = defaultMusicAudio
	masterAudioSlider.value = defaultMasterAudio
	
	#reset keybinds
	resetKeybinds()

	#update action list
	createActionList()

func _on_save_button_pressed():
	saveSettings()

func generateKey(keycode, modifierKey):
	var key = InputEventKey.new()
	key.keycode = keycode
	
	if(int(modifierKey) == KEY_SHIFT):
		key.shift_pressed = true
	elif(int(modifierKey) == KEY_ALT):
		key.alt_pressed = true
	elif(int(modifierKey) == KEY_CTRL):
		key.ctrl_pressed = true
	elif(int(modifierKey) == KEY_META):
		key.meta_pressed = true
	elif (int(modifierKey) == MOUSE_BUTTON_LEFT):
		key = InputEventMouseButton.new()
		key.button_index = MOUSE_BUTTON_LEFT
		key.button_mask = MOUSE_BUTTON_MASK_LEFT
		key.double_click = false
	elif (int(modifierKey) == MOUSE_BUTTON_RIGHT):
		key = InputEventMouseButton.new()
		key.button_index = MOUSE_BUTTON_RIGHT
		key.button_mask = MOUSE_BUTTON_MASK_RIGHT
		key.double_click = false
	return key
	
func resetKeybinds():
	for action in inputActions:
		var actionInfo = inputActions[action]
		var key = generateKey(actionInfo.keycode, actionInfo.modifierKey)

		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, key)
		
		remapActionInProjectSettings(action, key)

	keybinds = getCurrentKeybinds()


func saveSettings():
	var settingsFile = FileAccess.open(settingsPath, FileAccess.WRITE)

	settingsDictionary.musicAudio = musicAudioSlider.value
	settingsDictionary.masterAudio = masterAudioSlider.value
	settingsDictionary.keybinds = getCurrentKeybinds()
	
	settingsFile.store_var(settingsDictionary)
	settingsFile.close()
	
	
func getKeybindModifier(keybind):
	if keybind is InputEventKey:
		if keybind.shift_pressed:
			return KEY_SHIFT
		elif keybind.alt_pressed:
			return KEY_ALT
		elif keybind.ctrl_pressed:
			return KEY_CTRL
		elif keybind.meta_pressed:
			return KEY_META
	if keybind is InputEventMouseButton:
		if keybind.button_index == 1:
			return MOUSE_BUTTON_LEFT
	return -1
	
func getCurrentKeybinds():
	InputMap.load_from_project_settings
	var currentKeybinds = []
	for action in inputActions:
		var events = InputMap.action_get_events(action)
		var key = events[0].keycode if events[0] is InputEventKey else -1
		var mouse = events[0].button_index if events[0] is InputEventMouseButton else -1
		
		var tempAction = {
			"actionName": action,
			"actionLabel": inputActions[action].label,
			"action": events[0],
			"actionKeycode": events[0].as_text(),
			"actionModifier": getKeybindModifier(events[0]),
			"actionKey": key,
			"actionMouse": mouse
		}

		currentKeybinds.append(tempAction)

	return currentKeybinds
