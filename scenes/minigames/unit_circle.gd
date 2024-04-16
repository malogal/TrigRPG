extends StaticBody2D

const AngleClass = preload("res://misc-utility/Angle.gd")

@export var return_value: float = 0
@export var goal_value: float = 0.5
@export var unique_name: String = ""
@export var str_goal_value_override: String = ""
@export var str_goal_numerator: String = ""
@export var str_goal_denominator: String = ""

var success: bool          = false
var previous_success: bool = false
var angle       		   = AngleClass.new(0)
var radius: int            = 154
var minAngle: int          = 0
var maxAngle: float        = PI/2

enum TrigFunc{ SIN, COS, TAN, SEC, CSC, COT }
@export var type := TrigFunc.SIN
@export var allow_hints := true
@onready var label_type: RichTextLabel = $TextureRect/LabelType
@onready var label_value: RichTextLabel = $TextureRect/LabelValue

var player
var detection
var prev_rotation: float    = 0.0
const success_color: String = "Greenyellow"
const ERROR: float = 0.001

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
	success = abs(return_value-goal_value) < ERROR
	if success == true:
		print_debug("unit circle success")

func type_to_str() -> String:
	match type:
		TrigFunc.SIN:
			return "sin"
		TrigFunc.COS:
			return "cos"
		TrigFunc.TAN:
			return "tan"
		TrigFunc.SEC:
			return "sec"
		TrigFunc.CSC:
			return "csc"
		TrigFunc.COT:
			return "cot"
	return "sin"
	
func get_current_bb_color() -> String:
	if success: return success_color
	# Convert to switch case:
	match type:
		TrigFunc.SIN:
			return "Crimson"
		TrigFunc.COS:
			return "Mediumblue"
		TrigFunc.TAN:
			return "Orange"
		TrigFunc.SEC:
			return "Crimson"
		TrigFunc.CSC:
			return "Crimson"
		TrigFunc.COT:
			return "Crimson"
	return "Crimson"
	
func bb_code_color_text(text: String) -> String:
	return "[color="+get_current_bb_color()+"]"+text+"[/color]"
func bb_code_underline_text(text: String) -> String:
	return "[u]"+text+"[/u]"
func bb_code_center_text(text: String) -> String:
	return "[center]"+text+"[/center]"
func bb_code_left_text(text: String) -> String:
	return "[left]"+text+"[/left]"
func bb_code_right_text(text: String) -> String:
	return "[right]"+text+"[/right]"
func set_type_label() -> void:
	label_type.text = bb_code_left_text(bb_code_color_text(type_to_str() + "(Ø)="))
	
# Example formated fraction string: [center][color=red][u]√2[/u]/n2[/color][/center]
func set_value_label() -> void:
	var text := ""
	# If override is set, use that
	if !str_goal_value_override.is_empty():
		text = str_goal_value_override
	elif !str_goal_numerator.is_empty() and !str_goal_denominator.is_empty():
		text = bb_code_underline_text(str_goal_numerator) + "\n" + str_goal_denominator
	elif abs(goal_value) < ERROR :
		text = "0"
	else:
		text = "%.2f" % goal_value
	label_value.text = bb_code_center_text(bb_code_color_text(text))
	
# Called when the node enters the scene tree for the first time.
func _ready():
	$hint.visible = false
	player = get_tree().get_nodes_in_group("player")[0]
	detection = $EdgeArea
	evaluate_return()
	set_type_label()
	set_value_label()
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
	angle.rads = -$EdgeArea.rotation
	$EdgeArea/Mover/Degrees.text = str(roundi(float(angle.get_str_deg()))) + "º" 
	angle.round(5,true)
	# Only update lines when the rotation changes
	if abs(prev_rotation - $EdgeArea.rotation) > 0.005:
		prev_rotation = $EdgeArea.rotation
		evaluate_return()
		queue_redraw()
	# Do not display the arc if the hint is visible, their circles are slightly offset
	$arc.visible = !$hint.visible
	# Only update text when the success state changes
	if success != previous_success:
		set_type_label()
		set_value_label()
		previous_success = success
	
func _draw():
	$sin.clear_points()
	$sin.add_point(Vector2(radius*cos($EdgeArea.rotation),0))
	$sin.add_point(Vector2(radius*cos($EdgeArea.rotation),radius*sin($EdgeArea.rotation)))
	$cos.clear_points()
	$cos.add_point(Vector2(0,0))
	$cos.add_point(Vector2(radius*cos($EdgeArea.rotation),0))

var player_first_entry: bool = true
var is_player_present: bool = false
func _input(event) -> void: #Handles quests and other events
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
