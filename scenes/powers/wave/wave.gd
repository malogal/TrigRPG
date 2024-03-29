extends Node2D

var speed: int
var degree: int

const rotate_speed = 350
var current_rotation = 0
var vec: Vector2
var target: Vector2

signal hit 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Wave properties, default values
var amplitude: float = 450 # Height of the wave
var frequency: float = 0.009 # How many waves within a certain distance
var is_sine_wave: bool = true # True for sine, false for cosine
var wave_color_pos: Color = Color(0.00000100867101, 0.5642226934433, 0.51764661073685, 0.7)
var wave_color_neg: Color = Color(0.79184025526047, 0.31729644536972, 0.10155173391104, 0.7)
var is_horizontal: bool = true

var wave_points_positive: PackedVector2Array 
var wave_points_negative: PackedVector2Array 


func _draw():
	draw_polyline(wave_points_positive, wave_color_pos, 1, true)
	draw_polyline(wave_points_negative, wave_color_neg, 1, true)
	
func fill_array():
	var start_pos = Vector2(0,0) 
	wave_points_positive = PackedVector2Array()
	wave_points_negative = PackedVector2Array()
	var  direction
	var wave_length 
	if is_horizontal:
		direction = Vector2(1, 0)
		# Screen width (halved)
		wave_length = 850
	else:
		direction = Vector2(0, 1)
		# Screen height (halved)
		wave_length = 450
	set_points(start_pos, 0, -wave_length, direction, wave_points_negative)
	set_points(start_pos, 0, wave_length, direction, wave_points_positive)
		
func set_points(start_pos: Vector2, first: int, last: int, direction: Vector2, arr: PackedVector2Array):
	# Calculate points and draw the wave
	var step = 1 if first < last else -1
	for i in range(first, last, step):
		var displacement = direction.normalized() * i
		var wave_offset: float = (sin(frequency * i) if is_sine_wave else cos(frequency * i)) * amplitude
		var current_point: Vector2
		
		if is_horizontal:
			current_point = start_pos + Vector2(displacement.x, -wave_offset)
		else:
			current_point = start_pos + Vector2(wave_offset, displacement.y)
		# Skip first line which would draw straight from player to begining of wave
		arr.append(current_point*.2)

# Create a new wave, multiply default stats by passed in dictionary
func new_wave(specs: Dictionary):
	if "amplitude" in specs:
		amplitude *= specs.amplitude
	if "frequency" in specs:
		frequency *= specs.frequency
	if "is_sine" in specs:
		is_sine_wave = specs.is_sine
	if "is_horizontal" in specs:
		is_horizontal = specs.is_horizontal
	# TODO Disable vertical wave for now
	is_horizontal = true
	fill_array()
	$InnerWave.new_inner_wave(wave_points_positive, wave_points_negative)

func get_inner_wave_point() -> Vector2:
	return $InnerWave.get_inner_wave_point()

func move_inner_wave(is_positive): 
	$InnerWave.move_inner_wave(is_positive)
