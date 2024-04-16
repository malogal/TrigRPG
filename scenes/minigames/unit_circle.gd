extends StaticBody2D

const AngleClass = preload("res://misc-utility/Angle.gd")

@export var return_value: float = 0
@export var goal_value: float = 0.5
@export var unique_name: String = ""
@export var str_goal_value_override: String = ""
var success = false
var angle = AngleClass.new(0)
var radius = 154

var minAngle = 0
var maxAngle = PI/2

enum TrigFunc{ SIN, COS, TAN, SEC, CSC, COT }
@export var type := TrigFunc.SIN
@export var allow_hints := true
@onready var lever := $EdgeArea/Mover

var player
var detection
var prev_rotation: float = 0.0

func evaluate_return():
	var theta = angle.rads
	if type==TrigFunc.SIN:
		return_value = sin(theta)
	elif type==TrigFunc.COS:
		return_value = cos(theta)
	elif type==TrigFunc.TAN and cos(theta)!=0:
		return_value = tan(theta)
	elif type==TrigFunc.SEC and cos(theta)!=0:
		return_value = 1./cos(theta)
	elif type==TrigFunc.CSC and sin(theta)!=0:
		return_value = 1./sin(theta)
	elif type==TrigFunc.COT and sin(theta!=0):
		return_value = cos(theta)/sin(theta)
	success = abs(return_value-goal_value)<0.001
	if success == true:
		print_debug("unit circle success")

func type_to_str():
	if type==TrigFunc.SIN:
		return "sin"
	elif type==TrigFunc.COS:
		return "cos"
	elif type==TrigFunc.TAN:
		return "tan"
	elif type==TrigFunc.SEC:
		return "sec"
	elif type==TrigFunc.CSC:
		return "csc"
	elif type==TrigFunc.COT:
		return "cot"

# Called when the node enters the scene tree for the first time.
func _ready():
	$hint.visible = false
	player = get_tree().get_nodes_in_group("player")[0]
	detection = $EdgeArea
	evaluate_return()
	$TextureRect/Label.text = type_to_str()+"(θ)=" + ( str(goal_value) if str_goal_value_override.is_empty() else str_goal_value_override )
	$sin.default_color = Color(1,0,0,1)
	$sin.width = 2
	$cos.default_color = Color(0,0,1,1)
	$cos.width = 2
	$arc.default_color = Color(0,0,0,1)
	$arc.width = 1
	$arc.clear_points()
	for t in range(-1,12):
		var theta = PI*t/20
		$arc.add_point(Vector2(radius*cos(theta),-radius*sin(theta)))
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if unique_name == "first":
		var erx = 1
	angle.rads = -$EdgeArea.rotation
	$EdgeArea/Mover/Degrees.text = str(roundi(float(angle.get_str_deg()))) + "º" 
	angle.round(5,true)
	if abs(prev_rotation - $EdgeArea.rotation) > 0.005:
		prev_rotation = $EdgeArea.rotation
		evaluate_return()
		queue_redraw()
		
	#var text_rect = $TextureRect
	#if success:
		#text_rect.modulate = Color(0.20106519758701, 0.62987112998962, 0.00000864161939)
		#$Label2.label_settings.font_color = Color(0.20153121650219, 0.62822264432907, 0.12438380718231)
	#else:
		#$Label2.label_settings.font_color = Color(0.91036748886108, 0.15973426401615, 0.53727507591248)
		#text_rect.modulate = Color(255,255,255,255)
	$arc.visible = !$hint.visible
	
func _draw():
	$sin.clear_points()
	$sin.add_point(Vector2(radius*cos($EdgeArea.rotation),0))
	$sin.add_point(Vector2(radius*cos($EdgeArea.rotation),radius*sin($EdgeArea.rotation)))
	$cos.clear_points()
	$cos.add_point(Vector2(0,0))
	$cos.add_point(Vector2(radius*cos($EdgeArea.rotation),0))

var player_first_entry: bool = true
var is_player_present: bool = false
func _input(event): #Handles quests and other events
	# Bail if npc not active (player not inside the collider)
	if not is_player_present:
		return
	# Bail if the event is not a pressed "interact" action
	if not event.is_action_pressed("interact"):
		return
	# reverse visibility
	$hint.visible = not $hint.visible
	 
	
func _on_sight_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and allow_hints:
		is_player_present = true
		# Start listening for key binds now that the player is in the interact area
		set_process_input(true)
		# The first time the player enters this Unit Circle give a pop-up reminding them of the hint
		if player_first_entry:
			Globals.create_popup_window("Press 'E' for a hint.", 2.5)
			player_first_entry = false
			


func _on_sight_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and allow_hints:
		is_player_present = false
		# Stop listening for key binds now that the player has left the interact area
		set_process_input(false)
		$hint.visible = false
