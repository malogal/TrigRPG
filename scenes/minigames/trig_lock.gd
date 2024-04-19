extends StaticBody2D

const AngleClass = preload("res://misc-utility/Angle.gd")

var success = false
enum TransTypes{ AMPLITUDE, FREQUENCY, SHIFT_LR, SHIFT_UD }
var transformations = []

enum TrigFunc{ SIN, COS, TAN, SEC, CSC, COT }
@export var type := TrigFunc.SIN
@export var frequency : float = 2.0
@export var h_shift : float = 0.0
@export var amplitude : float = 1.0
@export var v_shift : float = 0.0

var current_frequency : float = 1.0
var current_h_shift : float = 0.0
var current_amplitude : float = 1.0
var current_v_shift : float = 0.0

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

func trig_func(theta:float):
	if type==TrigFunc.SIN:
		return sin(theta)
	elif type==TrigFunc.COS:
		return cos(theta)
	elif type==TrigFunc.TAN and cos(theta)!=0:
		return tan(theta)
	elif type==TrigFunc.SEC and cos(theta)!=0:
		return 1./cos(theta)
	elif type==TrigFunc.CSC and sin(theta)!=0:
		return 1./sin(theta)
	elif type==TrigFunc.COT and sin(theta!=0):
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
	$Label.add_theme_color_override("font_color",Color(1,0,0,1))
	$Label.text = "y="+type_to_str()+"(x)"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$yaxis.add_point(Vector2(0,-15))
	$yaxis.add_point(Vector2(0,15))
	$xaxis.add_point(Vector2(-80,0))
	$xaxis.add_point(Vector2(80,0))
	queue_redraw()
	if success:
		$Label.add_theme_color_override("font_color",Color(0,1,0,1))
	else:
		$Label.add_theme_color_override("font_color",Color(1,0,0,1))
	$CollisionShape2D.disabled = success


func _draw():
	#for simplification, also figure out if successful
	success = true
	$Current.clear_points()
	$Goal.clear_points()
	for x in range(-80,80):
		#current
		var y = TAU/80*x
		for t in transformations:
			if(t.type==TransTypes.FREQUENCY):
				y = t.evaluate(y)
		for t in transformations:
			if(t.type==TransTypes.SHIFT_LR):
				y = t.evaluate(y)
		y = trig_func(y)
		for t in transformations:
			if(t.type==TransTypes.AMPLITUDE):
				y = t.evaluate(y)
		for t in transformations:
			if(t.type==TransTypes.SHIFT_UD):
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
		if(body.type==TransTypes.FREQUENCY):
			current_frequency = body.evaluate(current_frequency)
		elif(body.type==TransTypes.SHIFT_LR):
			current_h_shift = body.evaluate(current_h_shift)
		elif(body.type==TransTypes.AMPLITUDE):
			current_amplitude = body.evaluate(current_amplitude)
		elif(body.type==TransTypes.SHIFT_UD):
			current_v_shift = body.evaluate(current_v_shift)
		var equation = "y="
		if current_amplitude==-1:
			equation += "-"
		elif current_amplitude!=1:
			equation += str(current_amplitude)
		equation += type_to_str()+"("
		if current_frequency==-1:
			equation += "-"
		elif current_frequency!=1:
			equation += str(current_frequency)
		equation += "x"
		if current_h_shift>0:
			equation += "+"+str(current_h_shift)
		if current_h_shift<0:
			equation += str(current_h_shift)
		equation += ")"
		if current_v_shift>0:
			equation += "+"+str(current_v_shift)
		if current_v_shift<0:
			equation += str(current_v_shift)
		$Label.text = equation


func _on_hurtbox_body_entered(body):
	if body.is_in_group("pie"):
		for t in transformations:
			t.reset()
		transformations = []
		$Label.text = "y="+type_to_str()+"(x)"
		current_frequency = 1
		current_h_shift = 0
		current_amplitude = 1
		current_v_shift = 0
