extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var wave_points_positive: PackedVector2Array 
var wave_points_negative: PackedVector2Array 
var speed_max: int = 5
var speed_min: int = 2
var inner_wave_speed: float = 4
var inner_wave_index: int = 0
var inner_wave_color_pos: Color = Color(0.42985674738884, 0.05698623508215, 0.70890939235687)
var inner_wave_color_neg: Color = Color(0.60181617736816, 0, 0.28337466716766)

# If 0 do nothing, if 1 go in positive dir, if -1 go in negative dir
var queue_wave_change: int = 0

signal teleport_player(point: Vector2)

func _draw():
	if abs(inner_wave_index) < 2:
		return
	if inner_wave_index > 0: 
		draw_polyline(wave_points_positive.slice(0, inner_wave_index), inner_wave_color_pos, 2, true)
	else:
		draw_polyline(wave_points_negative.slice(0, abs(inner_wave_index)), inner_wave_color_neg, 2, true)

func new_inner_wave(positive: PackedVector2Array, negative: PackedVector2Array):
	wave_points_positive = positive
	wave_points_negative = negative
		
func move_inner_wave(is_positive):
	if is_positive:
		queue_wave_change = 1
	else:
		queue_wave_change = -1
	

func _process(delta):
	if queue_wave_change == 0:
		inner_wave_speed = speed_min
		return
	if inner_wave_speed < speed_max:
		inner_wave_speed += delta
	if inner_wave_speed > speed_max:
		inner_wave_speed = speed_max
	calc_index(queue_wave_change, delta)
	queue_redraw()
	queue_wave_change = 0
	
func calc_index(dir, delta: float):
	inner_wave_index += roundi(inner_wave_speed * dir * roundi(delta * 100))
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

