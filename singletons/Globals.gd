extends Node

# warning-ignore:unused_class_variable
var spawnpoint = ""
var current_level = ""
var currentSavePath = ""

#TODO: change to save://save1.save for actual game
var save1Path = "res://save1.save"
var save2Path = "res://save2.save"
var save3Path = "res://save3.save"

var saveName
var lastPlayed
var timeSpent

var loadGameToggle = false
var inventory

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

func _ready():
	RenderingServer.set_default_clear_color(Color.DODGER_BLUE)

"""
Really simple save file implementation. Just saving some variables to a dictionary
"""
func save_game(): 
	if currentSavePath != "":
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
		
		for node in savedNodes:
			# Check the node is an instanced scene so it can be instanced again during load.
			if node.scene_file_path.is_empty():
				print("persistent node '%s' is not an instanced scene, skipped" % node.name)
				continue

			# Check the node has a save function.
			if !node.has_method("getSaveStats"):
				print("persistent node '%s' is missing a getSaveStats() function, skipped" % node.name)
				continue

			# Call the node's save function.
			var nodeData = node.getSaveStats()

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
	
	if currentSavePath != "":
		if not FileAccess.file_exists(currentSavePath):
			return
			
		var savedNodes = get_tree().get_nodes_in_group("saved")
		for node in savedNodes:
			node.get_parent().remove_child(node)
			node.queue_free()
		
		var saveFile = FileAccess.open(currentSavePath, FileAccess.READ)
		
		while saveFile.get_position() < saveFile.get_length():
			# Get the saved dictionary from the next line in the save file
			var jsonString = saveFile.get_line()
			var json = JSON.new()
			var parseResult = json.parse(jsonString)
			if not parseResult == OK:
				printerr("JSON Parse Error: ", json.get_error_message(), " in ", jsonString, " at line ", json.get_error_line())
				continue
				
			var nodeData = json.get_data()
			
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
			
		saveFile.close()


func isSaveData(nodeData):
	return nodeData.has("saveName") or nodeData.has("lastPlayed") or nodeData.has("timeSpent")
	
func isInventoryData(nodeData):
	return nodeData == {} or nodeData.has("frequency") or nodeData.has("amplitude") or nodeData.has("sine") or nodeData.has("cosine")
