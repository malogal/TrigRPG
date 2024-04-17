extends CharacterBody2D

var is_player_present = false

@export var completed: bool = false # Has the game been finished in a previous save
@export var character_name: String = "Priestess"
@export var dialogs = ["..."] # (Array, String, MULTILINE)
@export var stored_dialogs_file: String
@export var puzzle : StaticBody2D

@onready var anims = $anims
@onready var npc_body = $NpcBody
@onready var trigger = $interact_area/trigger
# Called every frame. 'delta' is the elapsed time since the previous frame.

var temp_completed: bool = false

func _process(delta):
	if puzzle == null:
		puzzle = find_closest_minigame()
		if puzzle == null:
			set_state(true)
		return
	# If 'completed' is true, that means we have already completed this game in a previous save
	# Can't check in '_ready()' since save won't have loaded then 
	if completed: 
		get_parent().remove_child(self)
		queue_free()
		return
	# If the puzzle was temporarily complete
	if temp_completed: 
		# And if it is still complete, then stop processing 
		if puzzle.success:
			return
		set_state(false)
		# Bring priestess back
		anims.play("teleport")
		await get_tree().create_timer(1).timeout
		anims.play("default")
	
	# if puzzle has completed where it was not in the previous frame
	elif puzzle != null && puzzle.success:
		temp_completed = true 
		anims.play("teleport")
		await get_tree().create_timer(1).timeout
		set_state(true)

func set_state(finished: bool):
	anims.visible = !finished
	npc_body.disabled = finished
	trigger.disabled = finished
	temp_completed = finished
	
var current_dialog = 0	
# This scene only looks for input when the player is in the interact area
func _input(event): #Handles quests and other events
	# Bail if npc not active (player not inside the collider)
	if not is_player_present:
		return
	# Bail if the event is not a pressed "interact" action
	if not event.is_action_pressed("interact"):
		return
	
	if !stored_dialogs_file.is_empty():
		Globals.startDialogueStored(load(stored_dialogs_file), "start")
	elif !dialogs.is_empty():
		var title = "priestess" + str(get_rid().get_id())
		# If starting dialogue suceeds, increment current dialogue 
		if Globals.startDialogue(title, "Priestess", dialogs[current_dialog]):
			current_dialog = wrapi(current_dialog + 1, 0, dialogs.size())

func set_anims(anim: String):
	$anims.stop()
	$anims.animation = anim
	$anims.play()	
	
func _on_interact_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_present = true
		# Start listening for key binds now that the player is in the interact area
		set_process_input(true)


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_present = false
		# Stop listening for key binds now that the player has left the interact area
		set_process_input(false)

func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y,
		'dialogs': dialogs,
		'completed': temp_completed,
		'stored_dialogs_file': stored_dialogs_file,
	}

func find_closest_minigame():
	var closest_node = null
	var min_distance = INF  # Initialize with infinity

	# Get all nodes in the group
	var nodes_in_group = get_tree().get_nodes_in_group("minigame")
	
	for node in nodes_in_group:
		var distance = position.distance_to(node.position)  # Calculate the distance to each node
		if distance < min_distance:
			min_distance = distance
			closest_node = node
	
	return closest_node  # Returns the closest node, or null if no nodes are in the group
