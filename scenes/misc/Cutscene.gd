extends Node2D

const Balloon = preload("res://dialogue/balloon.tscn")

@export var cutscenePath = ""
@export var visited = false

# Called when the node enters the scene tree for the first time.
func _ready():
	var dialogue_manager = Engine.get_singleton("DialogueManager")
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_area_entered(body):	
	if not visited and body.get_parent().is_in_group("player"):
		visited = true

		var balloon = Balloon.instantiate()
		get_tree().current_scene.add_child(balloon)
		balloon.start(load(cutscenePath), "start")

		Globals.isDialogActive = true
		
func _on_dialogue_ended(_resource: DialogueResource):
	Globals.isDialogActive = false
	
func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y,
		'visited': visited,
		'cutscenePath': cutscenePath
	}

