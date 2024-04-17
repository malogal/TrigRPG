extends Node2D

const Balloon = preload("res://dialogue/balloon.tscn")
const Radian = preload("res://scenes/characters/Radian.tscn")
const InvisArena = preload("res://scenes/levels/forest/Cutscene2FightBoundary.tscn")

@export var cutscenePath = ""
@export var visited = false
@export var finished = false

var cutsceneList = ["res://dialogue/cutscene1.dialogue",
"res://dialogue/cutscene2.dialogue",
"res://dialogue/cutscene3.dialogue"]

# Called when the node enters the scene tree for the first time.
func _ready():
	var dialogue_manager = Engine.get_singleton("DialogueManager")
	dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)
	#pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not visited and cutscenePath != cutsceneList[2] and body.is_in_group("player"):
		start_intro()

func start_intro():
	if cutscenePath == cutsceneList[0]:
		# Start teleportation circle animation 
		$AnimatedSprite2D.visible = true
		$AnimatedSprite2D.play("teleport")
	elif cutscenePath == cutsceneList[1]:
		var radian = Radian.instantiate()
		radian.position = Vector2(-1476, 700) # Put Radian in front of player
		radian.name = "Scene2Radian"
		get_parent().add_child(radian)
		var c2Arena = InvisArena.instantiate()
		c2Arena.position = position
		c2Arena.visible = false
		get_parent().add_child(c2Arena)
	elif cutscenePath == cutsceneList[2]:
		get_node("/root/Outside/level/ForestLevel/Scene2Radian").queue_free() # Delete Radian
		get_node("/root/Outside/level/ForestLevel/Cutscene2FightBoundary").queue_free() # Delete fight boundary
	visited = true
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(load(cutscenePath), "start")
	Globals.isDialogActive = true
	
func _on_dialogue_ended(_resource: DialogueResource):
	if !visited || finished:
		return
	Globals.isDialogActive = false
	if cutscenePath == cutsceneList[0]:
		$AnimatedSprite2D.stop()
		$AnimatedSprite2D.visible = false
	elif cutscenePath == cutsceneList[1]:
		var fightTimer = Timer.new()
		fightTimer.wait_time = 60.0
		fightTimer.one_shot = true
		fightTimer.autostart = false
		fightTimer.timeout.connect(self._on_fight_timer_timeout)
		add_child(fightTimer)
		fightTimer.start()
	elif cutscenePath == cutsceneList[2]:
		pass
	finished = true

func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y,
		'visited': visited,
		'cutscenePath': cutscenePath
	}

func _on_fight_timer_timeout():
	if get_parent().find_child("Cutscene3").visited == false:
		get_parent().find_child("Cutscene3").start_intro()
