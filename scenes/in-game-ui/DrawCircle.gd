extends Control


# Hold the fraction of the circle to shade (in radians)
@export var shade_fraction: float = PI/2:
	set(value):
		shade_fraction = value
		queue_redraw()

func _ready():
	queue_redraw()

func _draw():
	var parent_size = get_parent().get_rect()
	var my_size: Rect2 = get_rect()	
	var radius = my_size.size.x if my_size.size.x <= my_size.size.y else my_size.size.y # Radius of the circle
	radius = radius/2 
	var center = my_size.size/2 # Center of the circle
	var color_shaded = Color(0.82880473136902, 0.01938244886696, 0.00002892900557, 0.79607844352722) # Color for the shaded area
	var color_rest = Color(0.32413104176521, 0.352733284235, 0.33514034748077, 0.85882353782654) # Color for the rest of the circle

	# Draw the rest of the circle first
	draw_circle(center, radius, color_rest)
	# Draw the shaded fraction -- Radius of the arc is not like the circle. Using a radius of R/2 and a width or R makes a segment relating to a normal circle
	# draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = -1.0, antialiased: bool = false)
	draw_arc(center, radius/2, 0, -shade_fraction, 64, color_shaded, radius)
