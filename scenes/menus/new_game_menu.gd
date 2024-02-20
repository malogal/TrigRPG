extends Control

@onready
var saveNameInput = $PanelContainer/MarginContainer/Rows/LineEdit

var save1Path = "res://save1.save"
var save2Path = "res://save2.save"
var save3Path = "res://save3.save"

var mainGamePath = "res://scenes/levels/Outside.tscn"

@onready
var cannotCreateSaveLabel = $PanelContainer/MarginContainer/Rows/CannotCreateSaveLabel

@onready
var createSaveButton = $PanelContainer/MarginContainer/Rows/CreateSaveButton


# Called when the node enters the scene tree for the first time.
func _ready():	
	# load text box and stuff
	if canNewSaveCanBeMade():
		cannotCreateSaveLabel.hide()
	# load error message for not being able to create new save
	else:
		saveNameInput.hide()
		createSaveButton.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_create_save_button_pressed():
	saveNewSave()

func saveNewSave():
	# determine save slot
	var currentSaveSlot = determineSaveSlot()
	
	# save to new slot with default values
	var saveName = saveNameInput.text
	var lastPlayed = "Last played on: " + str(Time.get_date_string_from_system(false))
	var timeSpent = "Time spent: 00:00"

	var file = FileAccess.open(currentSaveSlot, FileAccess.WRITE)
	file.store_var(saveName)	
	file.store_var(lastPlayed)	
	file.store_var(timeSpent)
	
	# set global variable to new save
	Globals.currentSavePath = currentSaveSlot
	
	# load game with that save
	get_tree().change_scene_to_file(mainGamePath)

	
func determineSaveSlot():	
	if not FileAccess.file_exists(save1Path):
		return save1Path
	if not FileAccess.file_exists(save2Path):
		return save2Path
	if not FileAccess.file_exists(save3Path):
		return save3Path
	else:
		return ""
	
func canNewSaveCanBeMade():
	var save1Exists = FileAccess.file_exists(save1Path);
	var save2Exists = FileAccess.file_exists(save2Path);
	var save3Exists = FileAccess.file_exists(save3Path);
	
	return not (save1Exists and save2Exists and save3Exists)
