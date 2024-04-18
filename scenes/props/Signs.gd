extends Node2D

## Discontinued, do not use. Use [code]sign_style[/code] instead. 
@export var sign_type: int = 0
@export var sign_style: SignStyle = SignStyle.NORMAL
@export var sign_text: String = "I am a helpful sign."
@export var sign_name: String = "Sign"
@export var is_interactable: bool = true
@export var demo_mode_only: bool = false

enum SignStyle {NORMAL, RIGHT, LEFT, NORMAL_MOSSY, RIGHT_MOSSY, LEFT_MOSSY}
var type_to_frame:Dictionary = {
	SignStyle.NORMAL:0,
	SignStyle.RIGHT:1,
	SignStyle.LEFT:2,
	SignStyle.NORMAL_MOSSY:3,
	SignStyle.RIGHT_MOSSY:4,
	SignStyle.LEFT_MOSSY:5,
}
var is_player_present: bool = false

func _ready():
	if demo_mode_only:
		# If in demo mode, do NOT disable signs, else do 
		disable(!Globals.demo_mode)
		Globals.demo_mode_changed.connect(func(is_active: bool):disable(!is_active))
	# Only start listening for input once player is in area
	set_process_input(false)
	if sign_type != 0: 
		$AnimatedSprite2D.frame = sign_type
	else:
		$AnimatedSprite2D.frame = type_to_frame[sign_style]

func disable(do_disable: bool):
	visible = !do_disable
	$Area2D/CollisionShape2D.disabled = do_disable
	$StaticBody2D/CollisionShape2D.disabled = do_disable
	
# This scene only looks for input when the player is in the interact area
func _input(event): #Handles quests and other events
	# Bail if player is not near
	if not is_player_present:
		return
	# Bail if the event is not a pressed "interact" action
	if not event.is_action_pressed("interact"):
		return
	
	if not sign_text.is_empty():
		Globals.consume_input("interact")
		var title: String = sign_name + str(randi_range(0,5000))
		title = title.replace(" ", "")
		Globals.startDialogue(title, sign_name, sign_text)



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
