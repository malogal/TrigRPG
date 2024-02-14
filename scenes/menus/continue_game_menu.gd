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

	
	#var saveNameLabel2 = 
	#var lastPlayedLabel2 = 
	#var timeSpentLabel2 = 
	#
	#var saveNameLabel3 = 
	#var lastPlayedLabel3 = 
	#var timeSpentLabel3 = 

	#var theme = "res://textures/themes/main_theme.tres"
	#theme.

	
	#saveNameLabel1.text = "Save 1"
	#lastPlayedLabel1.text = "Last Played on: 02/08/2024"
	#timeSpentLabel1.text = "Time Spent: 01:43"
	
	#saveNameLabel1.color = "red"
	#saveName = "Save 1"
	#lastPlayed = "Last Played on: 02/08/2024"
	#timeSpent = "Time Spent: 01:43"
	

	
	var save1Array = [save1Path, saveNameLabel1, lastPlayedLabel1, timeSpentLabel1, panel1]
	var save2Array = [save2Path, saveNameLabel2, lastPlayedLabel2, timeSpentLabel2, panel2]
	var save3Array = [save3Path, saveNameLabel3, lastPlayedLabel3, timeSpentLabel3, panel3]
	
	savesData.append(save1Array)
	savesData.append(save2Array)
	savesData.append(save3Array)
	

	
	#saveSavesData()
	loadSavesData()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func saveSavesData():
	var file = FileAccess.open(save1Path, FileAccess.WRITE)
	file.store_var(saveName)	
	file.store_var(lastPlayed)	
	file.store_var(timeSpent)
	
func loadSavesData():
	
	for save in savesData:		
		
		var savePath = save[0]
		var saveNameLabel = save[1]
		var lastPlayedLabel = save[2]
		var timeSpentLabel = save[3]
		var panel = save[4]
		
		
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
			
			
			
		#print(saveName)
		#print(lastPlayed)
		#print(timeSpent)
	
		saveNameLabel.text = saveName
		lastPlayedLabel.text = lastPlayed
		timeSpentLabel.text = timeSpent
