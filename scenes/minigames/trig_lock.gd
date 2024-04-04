extends StaticBody2D

const AngleClass = preload("res://misc-utility/Angle.gd")

var success = false
var transformations = []

enum { SIN, COS, TAN, SEC, CSC, COT }
@export var type := SIN
@export var frequency := 1
@export var h_shift := 0
@export var amplitude := 1
@export var v_shift := 0

func trig_func(theta:float):
	if type==SIN:
		return sin(theta)
	elif type==COS:
		return cos(theta)
	elif type==TAN and cos(theta)!=0:
		return tan(theta)
	elif type==SEC and cos(theta)!=0:
		return 1./cos(theta)
	elif type==CSC and sin(theta)!=0:
		return 1./sin(theta)
	elif type==COT and sin(theta!=0):
		return cos(theta)/sin(theta)
	return 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Current.default_color = Color(1,0,0,1)
	$Current.width = 2
	$Goal.default_color = Color(0,1,0,1)
	$Goal.width = 2


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _draw():
	$Current.clear_points()
	for x in range(-80,80):
		var y = TAU/80*x
		#for t in transformations:
			#if(t.type==INSIDE):
				#y = t.evaluate(y)
		y = trig_func(y)
		#for t in transformations:
			#if(t.type==OUTSIDE):
				#y = t.evaluate(y)
		y *= -15
		$Current.add_point(Vector2(x,y))



