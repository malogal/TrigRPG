extends CharacterBody2D

@export var WALK_SPEED: int = 350

var linear_vel = Vector2()
@export var facing = "down" # (String, "up", "down", "left", "right")

var anim = ""
var new_anim = ""

var start_position = get_parent().get_position # The starting position of the NPC (doesn't change)
var current_position = start_position # The current position of the NPC (updates every frame)

@export var move_range = 50 # The distance at which the NPC can move from its starting point (default 50)
@export var default_move_type = "none";

enum { MOVESTATE_IDLE, MOVESTATE_WALKING }
enum { MOVETYPE_NONE, MOVETYPE_HORIZONTAL, MOVETYPE_VERTICAL }

var move_state = MOVESTATE_IDLE
var move_type = MOVETYPE_NONE

func _physics_process(_delta):
	if Dialogs.active:
		move_state = MOVESTATE_IDLE
	else:
		match default_move_type:
			"none":
				move_type = MOVETYPE_NONE
			"horizontal":
				move_type = MOVETYPE_HORIZONTAL
			"vertical":
				move_type = MOVETYPE_VERTICAL
	
	if move_type != MOVETYPE_NONE:
		match move_state:
			MOVESTATE_IDLE:
				new_anim = "idle_" + facing
			MOVESTATE_WALKING:
				current_position = get_parent().get_position;
				
				match move_type: #If the NPC moves vertically/horizontally, they will change directions when they have exceeded their movement range
					MOVETYPE_HORIZONTAL:
						if facing == "right" and current_position.x > (start_position.x + move_range):
							facing = "left"
						if facing == "left" and current_position.x < (start_position.x - move_range):
							facing = "right"
					MOVETYPE_VERTICAL:
						if facing == "down" and current_position.y > (start_position.y + move_range):
							facing = "up"
						if facing == "up" and current_position.y < (start_position.y - move_range):
							facing = "down"
				
				get_parent().set_velocity(linear_vel)
				get_parent().move_and_slide()
				linear_vel = get_parent().velocity
				
				var target_speed = Vector2()
				
				if facing == "down":
					target_speed += Vector2.DOWN
				if facing == "left":
					target_speed += Vector2.LEFT
				if facing == "right":
					target_speed += Vector2.RIGHT
				if facing == "up":
					target_speed += Vector2.UP
				
				target_speed *= WALK_SPEED
				linear_vel = linear_vel.lerp(target_speed, 0.9)
				
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

	if has_node("anims"):
		if new_anim != anim:
			anim = new_anim
			$anims.play(anim)
		pass


func goto_idle():
	move_state = MOVESTATE_IDLE
