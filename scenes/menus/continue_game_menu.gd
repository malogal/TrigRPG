extends Control

#TODO: change to save://save1.save for actual game
var save1Path = "res://save1.save"
var save2Path = "res://save2.save"
var save3Path = "res://save3.save"
var saveName
var lastPlayed
var timeSpent

var mainGamePath = "res://scenes/levels/Outside.tscn"

#save box 1
@onready
var saveNameLabel1 = $PanelContainer/MarginContainer/Rows/PanelContainer/SaveRows/SaveNameLabel
@onready
var lastPlayedLabel1 = $PanelContainer/MarginContainer/Rows/PanelContainer/SaveRows/LastPlayedOnLabel
@onready
var timeSpentLabel1 = $PanelContainer/MarginContainer/Rows/PanelContainer/SaveRows/TimeSpentLabel
@onready
var panel1 = $PanelContainer/MarginContainer/Rows/PanelContainer
@onready
var deleteButton1 = $Save1DeleteButton
var mouseOverPanel1 = false
var slot1Filled = false

#save box 2
@onready
var saveNameLabel2 = $PanelContainer/MarginContainer/Rows/PanelContainer2/SaveRows/SaveNameLabel
@onready
var lastPlayedLabel2 = $PanelContainer/MarginContainer/Rows/PanelContainer2/SaveRows/LastPlayedOnLabel
@onready
var timeSpentLabel2 = $PanelContainer/MarginContainer/Rows/PanelContainer2/SaveRows/TimeSpentLabel
@onready
var panel2 = $PanelContainer/MarginContainer/Rows/PanelContainer2
@onready
var deleteButton2 = $Save2DeleteButton
var mouseOverPanel2 = false
var slot2Filled = false

#save box 3
@onready
var saveNameLabel3 = $PanelContainer/MarginContainer/Rows/PanelContainer3/SaveRows/SaveNameLabel
@onready
var lastPlayedLabel3 = $PanelContainer/MarginContainer/Rows/PanelContainer3/SaveRows/LastPlayedOnLabel
@onready
var timeSpentLabel3 = $PanelContainer/MarginContainer/Rows/PanelContainer3/SaveRows/TimeSpentLabel
@onready
var panel3 = $PanelContainer/MarginContainer/Rows/PanelContainer3
@onready
var deleteButton3 = $Save3DeleteButton
var mouseOverPanel3 = false
var slot3Filled = false

var savesData = []

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.debug_mode = false
	var saveSlot1 = SaveSlot.new(save1Path, saveNameLabel1, lastPlayedLabel1, timeSpentLabel1, panel1, deleteButton1)	
	var saveSlot2 = SaveSlot.new(save2Path, saveNameLabel2, lastPlayedLabel2, timeSpentLabel2, panel2, deleteButton2)
	var saveSlot3 = SaveSlot.new(save3Path, saveNameLabel3, lastPlayedLabel3, timeSpentLabel3, panel3, deleteButton3)
	
	savesData.append(saveSlot1)
	savesData.append(saveSlot2)
	savesData.append(saveSlot3)
	
	loadSavesData()

	
func loadSavesData():
	for save in savesData:		
		var savePath = save.savePath
		var saveNameLabel = save.saveName
		var lastPlayedLabel = save.lastPlayed
		var timeSpentLabel = save.timeSpent
		var panel = save.panel
		var deleteButton = save.deleteButton

		if FileAccess.file_exists(savePath):
			var file = FileAccess.open(savePath, FileAccess.READ)

			var json = JSON.new()
			json.parse(file.get_line())
			var data = json.get_data()

			saveName = data.saveName
			lastPlayed = data.lastPlayed
			timeSpent = data.timeSpent
			
			file.close()
			
		else:
			saveName = ""
			lastPlayed = "EMPTY SLOT"
			timeSpent = ""
			panel.modulate = Color(0, 0, 0, 0.4)
			deleteButton.hide()
			
		saveNameLabel.text = saveName
		lastPlayedLabel.text = lastPlayed
		timeSpentLabel.text = timeSpent

func _on_save_1_delete_button_pressed():
	# Delete save slot
	if FileAccess.file_exists(save1Path):
		DirAccess.remove_absolute(save1Path)
		print("deleted data in " + save1Path)
		loadSavesData()
	

func _on_save_2_delete_button_pressed():
	# Delete save slot
	if FileAccess.file_exists(save2Path):
		DirAccess.remove_absolute(save2Path)
		print("deleted data in " + save2Path)
		loadSavesData()

func _on_save_3_delete_button_pressed():
	# Delete save slot
	if FileAccess.file_exists(save3Path):
		DirAccess.remove_absolute(save3Path)
		print("deleted data in " + save3Path)
		loadSavesData()


func _input(event):
	if event is InputEventMouseButton:
		if mouseOverPanel1 and event.pressed and savesData[0].saveName.text != "":
			print("loading save 1")
			Globals.currentSavePath = save1Path
			get_tree().change_scene_to_file(mainGamePath)
			Globals.loadGameToggle = true
			
		if mouseOverPanel2 and event.pressed and savesData[1].saveName.text != "":
			print("loading save 2")
			Globals.currentSavePath = save2Path
			get_tree().change_scene_to_file(mainGamePath)
			Globals.loadGameToggle = true	
					
		if mouseOverPanel3 and event.pressed and savesData[2].saveName.text != "":
			print("loading save 3")
			Globals.currentSavePath = save3Path
			get_tree().change_scene_to_file(mainGamePath)
			Globals.loadGameToggle = true
				
func _on_panel_container_mouse_entered():
	mouseOverPanel1 = true

func _on_panel_container_mouse_exited():
	mouseOverPanel1 = false

func _on_panel_container_2_mouse_entered():
	mouseOverPanel2 = true

func _on_panel_container_2_mouse_exited():
	mouseOverPanel2 = false

func _on_panel_container_3_mouse_entered():
	mouseOverPanel3 = true

func _on_panel_container_3_mouse_exited():
	mouseOverPanel3 = false
