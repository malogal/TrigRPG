extends Node2D

"""
Using a dictionary of directions -> animation names, call the parent's function 'set_anims()' 
with the matching animation based on the parents current velocity. 

If velocity is zero, the dictionary at the zero vector should contain a list of 
idle animations associated with directions. The idle direction to use is chosen based
on the previous velocity direction

If no dictionary is provided, the default (below) will be used. 
"""

# Default dictionary mapping direction vectors to animation names
var direction_to_animation = {
	Vector2.DOWN: "walk_down",
	Vector2.UP: "walk_up",
	Vector2.LEFT: "walk_left",
	Vector2.RIGHT: "walk_right",
	Vector2.ZERO: {
		Vector2.DOWN: "idle_down",
		Vector2.UP: "idle_up",
		Vector2.LEFT: "idle_left",
		Vector2.RIGHT: "idle_right",
	}
}

var parent_body: Node
"""
Some arbitary last direction that won't match the very first direction
In the event the first velocity direction is zero, the default:
	direction_to_animation[Vector2.ZERO][Vector2.DOWN]
will be chosen. 
"""

var last_direction: Vector2 = Vector2(99,99)
var deactivate: bool = false

func _ready():
	parent_body = get_parent()

func _process(delta):
	var direction = get_movement_direction()
	var new_dir: Vector2 = get_animation_for_direction(direction)
	if last_direction == new_dir:
		return
	# Default to downwards idle 
	var animation_name: String = direction_to_animation[Vector2.ZERO][Vector2.DOWN]
	if new_dir == Vector2.ZERO:
		# Get idle direction based on last direction traveled
		if direction_to_animation[Vector2.ZERO].has(last_direction):
			animation_name =  direction_to_animation[Vector2.ZERO][last_direction]
	else:
		animation_name = direction_to_animation[new_dir]
	last_direction = new_dir
	parent_body.set_anims(animation_name)

func set_animation_map(dict: Dictionary = direction_to_animation):
	direction_to_animation = dict

func get_last_direction() -> Vector2:
	return last_direction
	
func get_movement_direction() -> Vector2:
	var velocity: Vector2 = parent_body.velocity  
	if velocity.is_zero_approx():
		return Vector2.ZERO
	return velocity.normalized()

func get_animation_for_direction(direction: Vector2) -> Vector2:
	var best_match = Vector2.ZERO
	var highest_dot = -1.0  # Dot product ranges from -1 to 1

	if direction.length_squared() == 0:
		return Vector2.ZERO  # Return zero vector animation if no movement

	for dir_vector in direction_to_animation.keys():
		# Skip the idle direction for comparison
		if dir_vector == Vector2.ZERO:
			continue

		var dot_product = direction.normalized().dot(dir_vector.normalized())
		if dot_product > highest_dot:
			highest_dot = dot_product
			best_match = dir_vector

	return best_match

func set_deactivate(is_deactivated: bool):
	deactivate = is_deactivated
	# Disable the _process() function if deactivated 
	set_process(!deactivate)
		
