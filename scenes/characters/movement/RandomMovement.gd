extends Node2D

"""
!!!THIS IS NO LONGER BEING USED AND IS A LEFT INCASE IT'S NEEDED !!!
-- USE 'RandomMover.tscn' instead


Parent must have a CharacterBody2D and an Animation to use. 

Parent must have a method called set_anims(anim) where anim is the name of an animation to play.

Parent must have a method called get_anims() -> String: that returns the current animation
"""

"""
var active = false

@export var character_name: String = "Nameless NPC"
@export var dialogs = ["..."] # (Array, String, MULTILINE)
var current_dialog = 0

@export var WALK_SPEED: int = 100

var linear_vel = Vector2()
var target_position = Vector2()
var facing = "down" # (String, "up", "down", "left", "right")

var anim = ""
var new_anim = ""

@export var move_range = 50 # The distance at which the NPC can move from its starting point (default 50)
@export_enum("Horizontal", "Vertical", "None") var default_move_type = "None"

var bounding_rec: Rect2

var start_position: Vector2

enum { MOVESTATE_IDLE, MOVESTATE_WALKING_DEFAULT, MOVESTATE_WALKING_TOWARDS }
enum { MOVETYPE_NONE, MOVETYPE_HORIZONTAL, MOVETYPE_VERTICAL }
enum { MOVEDIR_UP, MOVEDIR_DOWN, MOVEDIR_LEFT, MOVEDIR_RIGHT }

var move_state = MOVESTATE_WALKING_DEFAULT
var move_type = MOVETYPE_NONE
var move_direction = MOVEDIR_DOWN

var rng
var time_to_change: Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	rng = RandomNumberGenerator.new()
	start_position = get_parent().position # The starting position of the NPC (doesn't change)
	
	match default_move_type:
		"Horizontal":
			move_direction = MOVEDIR_RIGHT
		"Vertical":
			move_direction = MOVEDIR_DOWN
		# If no default set, pick random
		_:
			if rng.randi() % 2 == 0:
				default_move_type = "Horizontal"
				move_direction = MOVEDIR_RIGHT
			else:
				default_move_type = "Vertical" 
				move_direction = MOVEDIR_DOWN
	time_to_change = Timer.new()
	add_child(time_to_change)
	time_to_change.one_shot = true
	time_to_change.wait_time = rng.randi_range(2, 6)
	time_to_change.start()
	time_to_change.timeout.connect(_on_change_timeout)
	
	pass # Replace with function body.

#Runs every frame
func _process(_delta): ##Handles movement and other physics-related functions
	anim = get_parent().get_anims()
	match move_state:
		MOVESTATE_IDLE: #If the NPC is idle, make their idle animation play in the direction they are facing
			new_anim = "idle_" + facing
		MOVESTATE_WALKING_DEFAULT: #Make the NPC adhere to their default moving type
			match default_move_type:
				"None":
					move_type = MOVETYPE_NONE
				"Horizontal":
					move_type = MOVETYPE_HORIZONTAL
				"Vertical":
					move_type = MOVETYPE_VERTICAL
			match move_type: #If the NPC moves vertically/horizontally, they will change directions when they have exceeded their movement range
				MOVETYPE_HORIZONTAL:
					if move_direction == MOVEDIR_RIGHT:
						if get_parent().position.x > (start_position.x + move_range):
							facing = "left"
							move_direction = MOVEDIR_LEFT
						else:
							facing = "right"
					elif move_direction == MOVEDIR_LEFT:
						if get_parent().position.x < (start_position.x - move_range):
							facing = "right"
							move_direction = MOVEDIR_RIGHT
						else:
							facing = "left"
				MOVETYPE_VERTICAL:
					if move_direction == MOVEDIR_DOWN:
						if get_parent().position.y > (start_position.y + move_range):
							facing = "up"
							move_direction = MOVEDIR_UP
						else:
							facing = "down"
					elif move_direction == MOVEDIR_UP:
						if get_parent().position.y < (start_position.y - move_range):
							facing = "down"
							move_direction = MOVEDIR_DOWN
						else:
							facing = "up"
			if move_type != MOVETYPE_NONE:
				get_parent().set_velocity(linear_vel)
				get_parent().move_and_slide()
				linear_vel = get_parent().velocity
				
				var target_speed = Vector2()
				match move_direction:
					MOVEDIR_DOWN:
						target_speed += Vector2.DOWN
					MOVEDIR_LEFT:
						target_speed += Vector2.LEFT
					MOVEDIR_RIGHT:
						target_speed += Vector2.RIGHT
					MOVEDIR_UP:
						target_speed += Vector2.UP
				
				target_speed *= WALK_SPEED

			if start_position.distance_to(target_position) > move_range: 
				target_position = start_position
			
			target_speed = (goal - current).normalized()
			target_speed *= WALK_SPEED
			linear_vel = linear_vel.lerp(target_speed, 0.9)
				linear_vel = target_speed
				
				new_anim = ""
				if abs(linear_vel.x) > abs(linear_vel.y):
					if linear_vel.x < 0:
						facing = "left"
					if linear_vel.x > 0:
						facing = "right"
				if abs(linear_vel.y) > abs(linear_vel.x):
					if linear_vel.y < 0:
						facing = "up"
					if linear_vel.y > 0:
						facing = "down"
				
				if linear_vel != Vector2.ZERO:
					new_anim = "walk_" + facing
				else:
					move_state = MOVESTATE_IDLE
				pass
		MOVESTATE_WALKING_TOWARDS:
			if get_parent().position == target_position: #If the position has been reached, switch to default move type
				goto_default_movetype()
				start_position = get_parent().position
				pass
			
			get_parent().set_velocity(Vector2.ZERO) #Stops any erratic movement from previous movement pattern
			
			if get_parent().position.x > target_position.x:
				facing = "left"
			if get_parent().position.x < target_position.x:
				facing = "right"
			if get_parent().position.y > target_position.y:
				facing = "up"
			if get_parent().position.y < target_position.y:
				facing = "down"
			
			get_parent().set_velocity(get_parent().position.move_toward(target_position, _delta * WALK_SPEED))
			get_parent().move_and_slide()
			pass

	if get_parent().has_node("anims"):
		if new_anim != anim:
			anim = new_anim
			get_parent().set_anims(anim)
		pass

## HELPER FUNCS
func goto_idle(): #Sets move state to idle
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + facing
	move_state = MOVESTATE_IDLE

func goto_default_movetype(): #Sets move state to the NPC's default move type
	move_state = MOVESTATE_WALKING_DEFAULT

func move_to_point(moveX: float, moveY: float): #Sets the move state to walk towards the given coordinates
	move_state = MOVESTATE_WALKING_TOWARDS
	target_position = Vector2(moveX, moveY)

func _on_change_timeout():
	time_to_change.wait_time = rng.randi_range(2, 6)
	time_to_change.start()
	move_to_point(start_position.x + rng.randi_range(-move_range,move_range), start_position.y + rng.randi_range(-move_range,move_range))
"""
