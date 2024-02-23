extends Node

class_name SaveSlot


var savePath
var saveName
var lastPlayed
var timeSpent
var panel
var deleteButton

#constructor
func _init(initialSavePath, initialSaveName, initialLastPlayed, intialTimeSpent, initialPanel, initialDeleteButton):
	savePath = initialSavePath	
	saveName = initialSaveName	
	lastPlayed = initialLastPlayed
	timeSpent = intialTimeSpent
	panel = initialPanel
	deleteButton = initialDeleteButton
