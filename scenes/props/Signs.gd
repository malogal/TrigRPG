extends Node2D

# Look at sprite frames to pick a sign type (0-5)
@export var sign_type: int = 0
@export var sign_text: String = "I am a helpful sign."
@export var sign_name: String = "Sign"
@export var is_interactable: bool = true

var is_player_present: bool = false

func _ready():
	# Only start listening for input once player is in area
	set_process_input(false)
	$AnimatedSprite2D.frame = sign_type

# This scene only looks for input when the player is in the interact area
func _input(event): #Handles quests and other events
	# Bail if player is not near
	if not is_player_present:
		return
	# Bail if the event is not a pressed "interact" action
	if not event.is_action_pressed("interact"):
		return
	
	if not sign_text.is_empty():
		var title: String = sign_name + str(randi_range(0,5000))
		title = title.replace(" ", "")
		Globals.startDialogue(title, sign_name, sign_text)
		$BobNoise.play()



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && is_interactable:
		is_player_present = true
		# Start listening for key binds now that the player is in the interact area
		set_process_input(true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") && is_interactable:
		is_player_present = false
		# Stop listening for key binds now that the player has left the interact area
		set_process_input(false)
