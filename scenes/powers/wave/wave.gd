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
var amplitude: float = 900.0 # Height of the wave
var frequency: float = 0.01 # How many waves within a certain distance
var is_sine_wave: bool = true # True for sine, false for cosine
var wave_length: float = 2000 # Length of the wave to be drawn
var wave_color: Color = Color(1, 0, 0, 1) # Bright red color
var is_horizontal: bool = true

var wave_points_positive: PackedVector2Array 
var wave_points_negative: PackedVector2Array 


func _draw():
	draw_polyline(wave_points_positive, wave_color, 10, true)
	draw_polyline(wave_points_negative, wave_color.inverted(), 10, true)
	
func fill_array():
	var start_pos = Vector2(0,0) 
	wave_points_positive = PackedVector2Array()
	wave_points_negative = PackedVector2Array()
	var direction = Vector2(1, 0) if is_horizontal else Vector2(0, 1)
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
			current_point = start_pos + Vector2(displacement.x, wave_offset)
		else:
			current_point = start_pos + Vector2(wave_offset, displacement.y)
		# Skip first line which would draw straight from player to begining of wave
		arr.append(current_point)

func new_wave(specs: Dictionary):
	if "amp" in specs:
		amplitude = specs.amp
	if "freq" in specs:
		frequency = specs.freq
	if "is_sine" in specs:
		is_sine_wave = specs.is_sine
	if "is_horizontal" in specs:
		is_horizontal = specs.is_horizontal
	if "color" in specs:
		wave_color = specs.color
	fill_array()
	pass
	
func _process(delta):
	queue_redraw()
	pass
	
