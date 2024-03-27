extends Control
var settingsPath = "res://settings.save"

@onready
var inputButtonScene = preload("res://scenes/menus/keybind_input_button.tscn")
@onready
var actionList = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

@onready
var musicAudioSlider = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MusicAudio
@onready
var masterAudioSlider = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/MasterAudioSlider

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
}

var settingsDictionary = {}
var defaultKeybinds = []
var keybinds = []
var defaultMusicAudio = 0.25
var defaultMasterAudio = 0.25

func _ready():
	# audio, for now added here to help demonstrate the music slider
	$Music.play()

	getSettingsFromFile()
	createActionList()

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
	
	
func _input(event):
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


func _on_exit_button_pressed():
	get_tree().change_scene_to_file(mainMenuScene)


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
	if FileAccess.file_exists(settingsPath):
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
