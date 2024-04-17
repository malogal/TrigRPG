extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var save_location = "user://settings.save"
	if FileAccess.file_exists(save_location):
		var savefile = FileAccess.open(save_location, FileAccess.READ)
		
		var settingsDictionary = savefile.get_var()
		savefile.close()		
		#set demo_mode
		if settingsDictionary.has("demo_mode"):
			Globals.demo_mode = settingsDictionary.demo_mode
