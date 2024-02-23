extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var wave_points_positive: PackedVector2Array 
var wave_points_negative: PackedVector2Array 

var inner_wave_speed: int = 10
var inner_wave_index: int = 0
var inner_wave_color_pos: Color = Color(0.42985674738884, 0.05698623508215, 0.70890939235687)
var inner_wave_color_neg: Color = Color(0.60181617736816, 0, 0.28337466716766)


signal teleport_player(point: Vector2)

func _draw():
	if inner_wave_index > 0: 
		draw_polyline(wave_points_positive.slice(0, inner_wave_index), inner_wave_color_pos, 10, true)
	else:
		draw_polyline(wave_points_negative.slice(0, abs(inner_wave_index)), inner_wave_color_neg, 10, true)

func new_inner_wave(positive: PackedVector2Array, negative: PackedVector2Array):
	wave_points_positive = positive
	wave_points_negative = negative
		
func _process(delta):
	var direction = 1
	if Input.is_action_pressed("shift-space"):
		calc_index(-1, delta)
		queue_redraw()
	elif Input.is_action_pressed("space"):
		calc_index(1, delta)
		queue_redraw()
	
func calc_index(dir, delta: float):
	inner_wave_index += inner_wave_speed * dir * roundi(delta * 100)
	# if index is greater than the size of the array, set at size of array - 1 (relative for negatives)
	if dir > 0:
		inner_wave_index = min(inner_wave_index, wave_points_positive.size()-1)
	else:
		inner_wave_index = max(inner_wave_index, -1 * (wave_points_positive.size()-1))

func get_inner_wave_point() -> Vector2: 
	if inner_wave_index > 0: 
		return wave_points_positive[inner_wave_index]
	else:
		return wave_points_negative[abs(inner_wave_index)]

