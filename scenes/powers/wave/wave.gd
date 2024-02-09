extends Node2D

var speed: int
var degree: int

const rotate_speed = 350
var current_rotation = 0
var vec: Vector2
var target: Vector2
#@export var texture : Texture2D:
	#set(value):
		#texture = value
		#queue_redraw()

#func _draw():
	#draw_texture(texture,position)

signal hit 
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Wave properties
var start_position: Vector2 # Starting position of the wave (relative coordinate (0,0))
var amplitude: float = 900.0 # Height of the wave
var frequency: float = 0.01 # How many waves within a certain distance
var is_sine_wave: bool = true # True for sine, false for cosine
var wave_length: float = 2000 # Length of the wave to be drawn
var wave_color: Color = Color(1, 0, 0, 1) # Bright red color
var is_horizontal: bool = false

var wave_points_positive: PackedVector2Array 
var wave_points_negative: PackedVector2Array 


func _draw():
	draw_polyline(wave_points_positive, wave_color, 10, true)
	draw_polyline(wave_points_negative, wave_color.inverted(), 10, true)
	
	#draw2()
	#return
	#if is_horizontal: 
		## Draw to the left of character
		#var direction = Vector2 (-1, 0) 
		#draw_horizontal(direction)
		## Draw to the right of character
		#wave_color = Color(0, 1, 1, 1)
		#direction = direction * -1
		#draw_horizontal(direction)
	#else: 
		## Draw to the left of character
		#var direction = Vector2 (1, 0) 
		#draw_vertical(direction)
		## Draw to the right of character
		#wave_color = Color(0, 1, 1, 1)
		#direction = direction * -1
		#draw_vertical(direction)
	#pass
	#
#func draw_horizontal(direction: Vector2): 
	#var last_point: Vector2 = position
	#var angle_step: float = direction.angle() # Calculate the step based on the direction
	## Calculate points and draw the wave
	#for i in range(1, wave_length):
		#var x: float = i
		#var y: float = (sin(frequency * x + angle_step) if is_sine_wave else cos(frequency * x + angle_step)) * amplitude
		#var current_point: Vector2 = position + direction.normalized() * x + Vector2(0, y)
		#if i != 1:
			#draw_line(last_point, current_point, wave_color, 10, true)
		#last_point = current_point
	#
#func draw_vertical(direction: Vector2): 
	#var last_point: Vector2 = position
	#var angle_step: float = direction.angle() # Calculate the step based on the direction
	## Calculate points and draw the wave
	#for i in range(1, wave_length):
		#var y: float = i
		#var x: float = (sin(frequency * y + angle_step) if is_sine_wave else cos(frequency * y + angle_step)) * amplitude
		#var current_point: Vector2 = position + direction.normalized() * x + Vector2(0, y)
		#if i != 1:
			#draw_line(last_point, current_point, wave_color, 10, true)
		#last_point = current_point
	#

func fill_array(start_pos: Vector2): 
	var direction = Vector2(1, 0) if is_horizontal else Vector2(0, 1)
	set_points(start_pos, 0, -wave_length, direction, wave_points_negative)
	set_points(start_pos, 0, wave_length, direction, wave_points_positive)
		
func set_points(start_pos: Vector2, first: int, last: int, direction: Vector2, arr: PackedVector2Array):
	#var last_point: Vector2 = start_position
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
		#if i != -wave_length:
			#draw_line(last_point, current_point, wave_color, 10, true)
		#last_point = current_point

func new_wave(start_pos):
	wave_points_positive = PackedVector2Array()
	wave_points_negative = PackedVector2Array()
	fill_array(Vector2(0,0))
	pass
	
func _process(delta):
	queue_redraw()
	pass
	
