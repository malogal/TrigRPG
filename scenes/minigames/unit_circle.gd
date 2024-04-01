extends Area2D

class_name UnitCircle

const AngleClass = preload("res://misc-utility/Angle.gd")

@export var return_value: float = 0
@export var goal_value: float = 0.5
var success = false
var angle = AngleClass.new(0)
var radius = 80

enum { SIN, COS, TAN, SEC, CSC, COT }
@export var type = SIN

var player
var detection

func evaluate_return():
	var theta = angle.rads
	if type==SIN:
		return_value = sin(theta)
	elif type==COS:
		return_value = cos(theta)
	elif type==TAN and cos(theta)!=0:
		return_value = tan(theta)
	elif type==SEC and cos(theta)!=0:
		return_value = 1./cos(theta)
	elif type==CSC and sin(theta)!=0:
		return_value = 1./sin(theta)
	elif type==COT and sin(theta!=0):
		return_value = cos(theta)/sin(theta)
	success = abs(return_value-goal_value)<0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_tree().get_nodes_in_group("player")[0]
	detection = $EdgeArea
	evaluate_return()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	evaluate_return()


func _movement_area_entered(area):
	if area.get_parent().is_in_group("player"):
		var x = global_position.x-area.global_position.x+radius*cos(angle.rads)
		var y = global_position.y-area.global_position.y+radius*sin(angle.rads)
		var a = AngleClass.new(0,x,y)
		var rel_a = AngleClass.new(angle.rads-a.rads)
		if(rel_a.rads<PI):
			angle.sub_rad(PI/12)
		else:
			angle.add_rad(PI/12)
		detection.position.x = radius*cos(angle.rads)
		detection.position.y = radius*sin(angle.rads)




