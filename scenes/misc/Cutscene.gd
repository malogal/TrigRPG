extends Node2D

const Balloon = preload("res://dialogue/balloon.tscn")
const Radian = preload("res://scenes/characters/Radian.tscn")

@export var cutscenePath = ""
@export var visited = false

var cutsceneList = ["res://dialogue/cutscene1.dialogue", "res://dialogue/cutscene2.dialogue"]

# Called when the node enters the scene tree for the first time.
func _ready():
	var dialogue_manager = Engine.get_singleton("DialogueManager")
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not visited and body.is_in_group("player"):
		start_intro()

func start_intro():
	if cutscenePath == cutsceneList[0]:
		# Start teleportation circle animation 
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play("teleport")
	elif cutscenePath == cutsceneList[1]:
		var radian = Radian.instantiate()
		radian.position = Vector2(-1476, 670) # Put Radian in front of player
		get_parent().add_child(radian)
	visited = true
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load(cutscenePath), "start")
	Globals.isDialogActive = true
	
func _on_dialogue_ended(_resource: DialogueResource):
	if !visited:
		return
	Globals.isDialogActive = false
	if cutscenePath == cutsceneList[0]:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.visible = false
	elif cutscenePath == cutsceneList[1]:
		pass
func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y,
		'visited': visited,
		'cutscenePath': cutscenePath
	}



