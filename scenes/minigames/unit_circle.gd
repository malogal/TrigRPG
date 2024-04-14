extends StaticBody2D

const AngleClass = preload("res://misc-utility/Angle.gd")

@export var return_value: float = 0
@export var goal_value: float = 0.5
var success = false
var angle = AngleClass.new(0)
var radius = 80

var minAngle = 0
var maxAngle = PI/2

enum TrigFunc{ SIN, COS, TAN, SEC, CSC, COT }
@export var type := TrigFunc.SIN
@onready var lever := $EdgeArea/Mover

var player
var detection

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
	success = abs(return_value-goal_value)<0.00001

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
	player = get_tree().get_nodes_in_group("player")[0]
	detection = $EdgeArea
	evaluate_return()
	$TextureRect/Label.text = type_to_str()+"(θ)=" + str(goal_value)
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	angle.rads = -$EdgeArea.rotation
	$EdgeArea/Mover/Degrees.text = str(roundi(float(angle.get_str_deg()))) + "º"
	angle.round(5,true)
	evaluate_return()
	if success:
		$TextureRect/Label.label_settings.font_color = Color(0, 0.61960786581039, 0, 0.88627451658249)
	else:
		$TextureRect/Label.label_settings.font_color = Color(1, 0.1176470592618, 0.37647059559822, 0.8941176533699)

