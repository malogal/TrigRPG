extends Control

@onready
var achievementsList = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/AchievementsList

@onready
var achievementItemPanelScene = preload("res://scenes/menus/achievement_item_panel.tscn")

var achievementsPath = "user://achievements.save"

var defaultAchievements = [
	{
		"name": "Wiz...Zard",
		"description": "Get iseπ’d into another world and meet Mr. Zard.",
		"completed": false
	},
	{
		"name": "The Forest",
		"description": "Enter the forest.",
		"completed": false
	},
	{
		"name": "In Yo Face",
		"description": "Throw 100 pies.",
		"completed": false
	}
]

var currentAchievements = []


func _ready():
	#loadDefaultAcievements()
	loadAchievementsData()
	createAchievementsList()


func loadAchievementsData():
	if FileAccess.file_exists(achievementsPath):
		var achievementsFile = FileAccess.open(achievementsPath, FileAccess.READ)
		
		while achievementsFile.get_position() < achievementsFile.get_length():
			var json = JSON.new()
			json.parse(achievementsFile.get_line())
			var data = json.get_data()
			
			currentAchievements.append(data)

		achievementsFile.close()


func createAchievementsList():
	for item in achievementsList.get_children():
		item.queue_free()
		
	for achievement in currentAchievements:
		var name = achievement.name
		var description = achievement.description
		var completed = achievement.completed
		
		var achievementItemPanel = achievementItemPanelScene.instantiate()
		var nameLabel = achievementItemPanel.find_child("NameLabel")
		var descriptionLabel = achievementItemPanel.find_child("DescriptionLabel")
		
		nameLabel.text = name
		descriptionLabel.text = description
		if not completed:
			achievementItemPanel.modulate = Color(0, 0, 0, 0.4)
			
		achievementsList.add_child(achievementItemPanel)


func loadDefaultAcievements():

	currentAchievements = []
	var file = FileAccess.open(achievementsPath, FileAccess.WRITE)

	for achievement in defaultAchievements:
		currentAchievements.append(achievement)
		var json_string = JSON.stringify(achievement)

		file.store_line(json_string)
	file.close()


func _on_reset_button_pressed():
	loadDefaultAcievements()
	createAchievementsList()
