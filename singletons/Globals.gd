extends Node

# warning-ignore:unused_class_variable
var spawnpoint = ""
var current_level = ""
var currentSavePath = ""

var save1Path = "user://save1.save"
var save2Path = "user://save2.save"
var save3Path = "user://save3.save"

var saveName
var lastPlayed
var timeSpent

var loadGameToggle = false
var inventory
signal player_class_reloaded
signal demo_mode_changed

var consumed_actions: Dictionary = {
	"interact":false,
	"throw_pie":false,
}

## This indicates the user is in the 'play-test' area and the game should not make saves
var in_test_mode: bool = false
## The game is in demo mode and should have demo features available 
var demo_mode: bool = true:
	set(value):
		demo_mode = value
		demo_mode_changed.emit(value)

const Balloon = preload("res://dialogue/balloon.tscn")
const PopUpScene = preload("res://scenes/in-game-ui/InGamePopUp.tscn")

var dialogue_manager: Object 

var loadNodeIgnoreTypes = {
	"fileName": true,
	"filePath": true,
	"parent": true,
	"posX": true,
	"posY": true
}
var isDialogActive = false

var currentTimeInMs
var startTimeInMs

signal game_over_screen_status

var showGameOverScreen: bool = false:
	set(value):
		showGameOverScreen = value
		game_over_screen_status.emit(value)
		
var achievementsPath = "user://achievements.save"
var currentAchievements = []
var achievementStatuses = {
	"seenWizard": false,
	"enteredForest": false,
	"thrown100Pies": false,
}

var player: Player:
	set(value):
		player = value
		player_class_reloaded.emit()

func _ready():
	RenderingServer.set_default_clear_color(Color.DODGER_BLUE)
		
"""
Really simple save file implementation. Just saving some variables to a dictionary
"""
func save_game(): 
	handleAchievementConfig()
	if currentSavePath != "" and !in_test_mode:
		currentTimeInMs = Time.get_unix_time_from_system()
		var diffInTimes = currentTimeInMs - startTimeInMs
	
		#getting base save info
		var saveFileW = FileAccess.open(currentSavePath, FileAccess.READ)
		var json = JSON.new()
		json.parse(saveFileW.get_line())
		saveFileW.close()
		
		var saveData = json.get_data()
		
		var timeSpentInSeconds = saveData.timeSpentInSeconds
		timeSpentInSeconds += diffInTimes

		var h = floor(timeSpentInSeconds / 3600)
		var m = floor((int(timeSpentInSeconds) % 3600) / 60)
		var s = floor((int(timeSpentInSeconds) % 60))
	
		var formattedElapsedTime = "%02d:%02d:%02d" % [h, m, s]
		var timeSpent = "Time spent: " + formattedElapsedTime
		var lastPlayed = "Last played on: " + Time.get_date_string_from_system(false)
		
		saveData.timeSpentInSeconds = int(timeSpentInSeconds)
		saveData.timeSpent = timeSpent		
		saveData.lastPlayed = lastPlayed
		
		#getting stuff to save to file
		var saveFile = FileAccess.open(currentSavePath, FileAccess.WRITE)
		
		# JSON provides a static method to serialized JSON string.
		var jsonString = JSON.stringify(saveData)

		# Store the save info as a new line in the save file.
		saveFile.store_line(jsonString)
		
		jsonString = JSON.stringify(Inventory.inventory)
		saveFile.store_line(jsonString)

		var savedNodes = get_tree().get_nodes_in_group("saved")
		savedNodes.reverse()

		for node in savedNodes:
			# Check the node is an instanced scene so it can be instanced again during load.
			if node.scene_file_path.is_empty():
				printerr("persistent node '%s' is not an instanced scene, skipped" % node.name)
				continue

			# Check the node has a save function.
			if !node.has_method("getSaveStats"):
				continue

			# Call the node's save function.
			var nodeData = node.getSaveStats()
			if nodeData == null:
				continue
			# JSON provides a static method to serialized JSON string.
			jsonString = JSON.stringify(nodeData)

			# Store the save dictionary as a new line in the save file.
			saveFile.store_line(jsonString)
		
		saveFile.close()
		
		startTimeInMs = Time.get_unix_time_from_system()
		
"""
If check_only is true it will only check for a valid save file and return true or false without
restoring any data
"""
func load_game():
	startTimeInMs = Time.get_unix_time_from_system()
	loadGameToggle = false
	
	if currentSavePath != "" and !in_test_mode:
		if not FileAccess.file_exists(currentSavePath):
			return
			
		var saveFile = FileAccess.open(currentSavePath, FileAccess.READ)
				
		var is_player_present: bool = false
		var savedNodes: Array
		
		while saveFile.get_position() < saveFile.get_length():
			# Get the saved dictionary from the next line in the save file
			var jsonString = saveFile.get_line()
			var json = JSON.new()
			var parseResult = json.parse(jsonString)
			if not parseResult == OK:
				printerr("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
				continue
			var savedNode = json.get_data()
			savedNodes.append(savedNode)
			if savedNode.has("fileName") && savedNode.fileName == "res://scenes/characters/Player.tscn":
				is_player_present = true
		saveFile.close()
		
		# Need to confirm there is a player node before deleting nodes
		if !is_player_present:
			return
		var removeNodes = get_tree().get_nodes_in_group("saved")
		for node in removeNodes:
			node.get_parent().remove_child(node)
			node.queue_free()


		for nodeData in savedNodes:
			if isSaveData(nodeData):
				continue
				
			if isInventoryData(nodeData):
				Inventory.init_inventory(nodeData)
				continue
			## Firstly, we need to create the object and add it to the tree and set its position.
			var newObject = load(nodeData.fileName).instantiate()
			newObject.add_to_group("saved", true)
			get_node(nodeData.parent).add_child(newObject)
			if nodeData.has("posX") and nodeData.has("posY"):
				newObject.position = Vector2(nodeData.posX, nodeData.posY)

			## Now we set the remaining variables.
			for i in nodeData.keys():
				if loadNodeIgnoreTypes.has(i) and loadNodeIgnoreTypes[i]:
					continue
				newObject.set(i, nodeData[i])
			
		
		


func isSaveData(nodeData):
	return nodeData.has("saveName") or nodeData.has("lastPlayed") or nodeData.has("timeSpent")
	
func isInventoryData(nodeData):
	return nodeData == {} or nodeData.has("frequency") or nodeData.has("amplitude") or nodeData.has("sine") or nodeData.has("cosine")


func handleAchievementConfig():
	currentAchievements = []
	#get existing achievements
	if FileAccess.file_exists(achievementsPath):
		var achievementsFile = FileAccess.open(achievementsPath, FileAccess.READ)
		
		while achievementsFile.get_position() < achievementsFile.get_length():
			var json = JSON.new()
			json.parse(achievementsFile.get_line())
			var data = json.get_data()
			
			currentAchievements.append(data)

		achievementsFile.close()
	
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null: 
			printerr("achievements unable to get player")
			return
	#get player achievements

	var nodeAchievementStats = player.getAchievementStats()
	achievementStatuses.seenWizard = nodeAchievementStats.hasVisitedCamp
	achievementStatuses.enteredForest = nodeAchievementStats.hasVisitedForest
	achievementStatuses.thrown100Pies = nodeAchievementStats.thrownPieCount >= 100
	
	# update current achievements
	var updatedAchievements = []
	for achievement in currentAchievements:
		if achievement.name == "Wiz...Zard":
			achievement.completed = achievementStatuses.seenWizard
		if achievement.name == "The Forest":
			achievement.completed = achievementStatuses.enteredForest
		if achievement.name == "In Yo Face":
			achievement.completed = achievementStatuses.thrown100Pies
		updatedAchievements.append(achievement)
	
	# save updated achievements
	var file = FileAccess.open(achievementsPath, FileAccess.WRITE)

	for achievement in updatedAchievements:
		currentAchievements.append(achievement)
		var json_string = JSON.stringify(achievement)

		file.store_line(json_string)
	file.close()

func _get_dialogue_manager():
	dialogue_manager = Engine.get_singleton("DialogueManager")
	dialogue_manager.dialogue_ended.connect(_set_is_dialog_active_false)

# Go to this URL for examples: https://github.com/nathanhoad/godot_dialogue_manager/blob/main/docs/Using_Dialogue.md#generating-dialogue-resources-at-runtime
# startDialogue will create a dialogue bubble with the characters name. 
# Use \n in your text for new lines. Make the title unique 
func startDialogue(title: String, character: String, text: String):
	if dialogue_manager == null:
		_get_dialogue_manager()
	if isDialogActive:
		return false
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	var resource = dialogue_manager.create_resource_from_text("~ " + title + "\n" + character + ": " + text)
	balloon.start(resource, title)
	isDialogActive = true
	return true;

func startDialogueStored(cutscene_resource: Resource, title: String):
	if dialogue_manager == null:
		_get_dialogue_manager()
	if isDialogActive:
		return false
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(cutscene_resource, title)
	isDialogActive = true
	return true;

func _set_is_dialog_active_false(any_: Variant = null):
	isDialogActive = false

func create_popup_window(text: String, time_out: int = 0, transparent_bg: bool = true):
	var popup: Node = PopUpScene.instantiate()
	get_tree().current_scene.add_child(popup)
	popup.show_message(text, time_out, transparent_bg)
	
func register_player(player_in: Player):
	player = player_in

func get_player() -> Player:
	return player

func just_pressed_not_consumed(action: String) -> bool:
	return Input.is_action_just_pressed(action) && consume_input(action)

func just_released_not_consumed(action: String) -> bool:
	return Input.is_action_just_released(action) && consume_input(action)
	
## Prevent double using an input (like picking up an item)
## Returns true of that action has been used this frame
func consume_input(consumed_input: String) -> bool:
	if consumed_actions[consumed_input]:
		return false
	consumed_actions[consumed_input] = true
	call_deferred("_clear_consumed_input", consumed_input)
	return true
	
func _clear_consumed_input(cleared_input: String):
	consumed_actions[cleared_input] = false
