extends StaticBody2D

const AngleClass = preload("res://misc-utility/Angle.gd")

var success = false
enum { AMPLITUDE, FREQUENCY, SHIFT_LR, SHIFT_UD }
var transformations = []

enum { SIN, COS, TAN, SEC, CSC, COT }
@export var type := SIN
@export var frequency := 2
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
	$Current.width = 1
	$Goal.default_color = Color(0,1,0,1)
	$Goal.width = 1
	$xaxis.default_color = Color(0,0,0,1)
	$xaxis.width = 1
	$yaxis.default_color = Color(0,0,0,1)
	$yaxis.width = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$yaxis.add_point(Vector2(0,-15))
	$yaxis.add_point(Vector2(0,15))
	$xaxis.add_point(Vector2(-80,0))
	$xaxis.add_point(Vector2(80,0))
	queue_redraw()


func _draw():
	#for simplification, also figure out if successful
	success = true
	$Current.clear_points()
	$Goal.clear_points()
	for x in range(-80,80):
		#current
		var y = TAU/80*x
		for t in transformations:
			if(t.type==FREQUENCY or t.type==SHIFT_LR):
				y = t.evaluate(y)
		y = trig_func(y)
		for t in transformations:
			if(t.type==AMPLITUDE or t.type==SHIFT_UD):
				y = t.evaluate(y)
		y *= -15
		var current = y
		$Current.add_point(Vector2(x,y))
		#goal
		y = TAU/80*x
		y *= frequency
		y -= h_shift
		y = trig_func(y)
		y *= amplitude
		y += v_shift
		y *= -15
		var goal = y
		$Goal.add_point(Vector2(x,y))
		if abs(current-goal)>0.01:
			success = false



func _on_body_entered(body):
	print("transformation hit by")
	print(body)
	if body.is_in_group("transformation"):
		transformations.append(body)
		body.remove()


func _on_hurtbox_body_entered(body):
	print("transformation hit by")
	print(body)
	if body.is_in_group("pie"):
		print("pie")
		for t in transformations:
			t.reset()
		transformations = []
