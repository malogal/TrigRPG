extends Control

#change to save://save1.save for actual game
var save1Path = "res://save1.save"
var save2Path = "res://save2.save"
var save3Path = "res://save3.save"
var saveName
var lastPlayed
var timeSpent

#save box 1
@onready
var saveNameLabel1 = $PanelContainer/MarginContainer/Rows/PanelContainer/SaveRows/SaveNameLabel
@onready
var lastPlayedLabel1 = $PanelContainer/MarginContainer/Rows/PanelContainer/SaveRows/LastPlayedOnLabel
@onready
var timeSpentLabel1 = $PanelContainer/MarginContainer/Rows/PanelContainer/SaveRows/TimeSpentLabel
@onready
var panel1 = $PanelContainer/MarginContainer/Rows/PanelContainer

#save box 2
@onready
var saveNameLabel2 = $PanelContainer/MarginContainer/Rows/PanelContainer2/SaveRows/SaveNameLabel
@onready
var lastPlayedLabel2 = $PanelContainer/MarginContainer/Rows/PanelContainer2/SaveRows/LastPlayedOnLabel
@onready
var timeSpentLabel2 = $PanelContainer/MarginContainer/Rows/PanelContainer2/SaveRows/TimeSpentLabel
@onready
var panel2 = $PanelContainer/MarginContainer/Rows/PanelContainer2

#save box 3
@onready
var saveNameLabel3 = $PanelContainer/MarginContainer/Rows/PanelContainer3/SaveRows/SaveNameLabel
@onready
var lastPlayedLabel3 = $PanelContainer/MarginContainer/Rows/PanelContainer3/SaveRows/LastPlayedOnLabel
@onready
var timeSpentLabel3 = $PanelContainer/MarginContainer/Rows/PanelContainer3/SaveRows/TimeSpentLabel
@onready
var panel3 = $PanelContainer/MarginContainer/Rows/PanelContainer3

var savesData = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var saveSlot1 = SaveSlot.new(save1Path, saveNameLabel1, lastPlayedLabel1, timeSpentLabel1, panel1)	
	var saveSlot2 = SaveSlot.new(save2Path, saveNameLabel2, lastPlayedLabel2, timeSpentLabel2, panel2)
	var saveSlot3 = SaveSlot.new(save3Path, saveNameLabel3, lastPlayedLabel3, timeSpentLabel3, panel3)
	
	savesData.append(saveSlot1)
	savesData.append(saveSlot2)
	savesData.append(saveSlot3)
	

	
	#saveSavesData()
	loadSavesData()

	
# note: something similar will be used in new game code
func saveSavesData():
	var file = FileAccess.open(save1Path, FileAccess.WRITE)
	file.store_var(saveName)	
	file.store_var(lastPlayed)	
	file.store_var(timeSpent)
	
func loadSavesData():
	
	for save in savesData:		
		var savePath = save.savePath
		var saveNameLabel = save.saveName
		var lastPlayedLabel = save.lastPlayed
		var timeSpentLabel = save.timeSpent
		var panel = save.panel
		
		if FileAccess.file_exists(savePath):
			var file = FileAccess.open(savePath, FileAccess.READ)

			saveName = file.get_var()
			lastPlayed = file.get_var()
			timeSpent = file.get_var()
			
		else:
			print("no data in file: " + savePath)
			saveName = ""
			lastPlayed = "EMPTY SLOT"
			timeSpent = ""
			panel.modulate = Color(0, 0, 0, 0.4)
	
		# setting panel info
		saveNameLabel.text = saveName
		lastPlayedLabel.text = lastPlayed
		timeSpentLabel.text = timeSpent
