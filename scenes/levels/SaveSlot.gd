extends Node

class_name SaveSlot


var savePath
var saveName
var lastPlayed
var timeSpent
var panel

#constructor
func _init(initialSavePath, initialSaveName, initialLastPlayed, intialTimeSpent, initialPanel):
	savePath = initialSavePath	
	saveName = initialSaveName	
	lastPlayed = initialLastPlayed
	timeSpent = intialTimeSpent
	panel = initialPanel


