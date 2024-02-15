extends CharacterBody2D

@export var WALK_SPEED: int = 350

var linear_vel = Vector2()
var facing = "down" # (String, "up", "down", "left", "right")

var anim = ""
var new_anim = ""

@export var move_range = 150 # The distance at which the NPC can move from its starting point (default 50)
@export_enum("Horizontal", "Vertical", "None") var default_move_type = "None"

var parent
var start_position

enum { MOVESTATE_IDLE, MOVESTATE_WALKING }
enum { MOVETYPE_NONE, MOVETYPE_HORIZONTAL, MOVETYPE_VERTICAL }
enum { MOVEDIR_UP, MOVEDIR_DOWN, MOVEDIR_LEFT, MOVEDIR_RIGHT }

var move_state = MOVESTATE_IDLE
var move_type = MOVETYPE_NONE
var move_direction = MOVEDIR_DOWN

func _ready():
	parent = get_parent()
	start_position = parent.position # The starting position of the NPC (doesn't change)
	
	if default_move_type == "Horizontal":
		move_direction = MOVEDIR_RIGHT
	elif default_move_type == "Vertical":
		move_direction = MOVEDIR_DOWN

#Runs every frame
func _physics_process(_delta):
	if Dialogs.active:
		move_state = MOVESTATE_IDLE
	else:
		move_state = MOVESTATE_WALKING
		match default_move_type:
			"None":
				move_type = MOVETYPE_NONE
			"Horizontal":
				move_type = MOVETYPE_HORIZONTAL
			"Vertical":
				move_type = MOVETYPE_VERTICAL
	
	if move_type != MOVETYPE_NONE:
		match move_state:
			MOVESTATE_IDLE: #If the NPC is idle, make their idle animation play in the direction they are facing
				new_anim = "idle_" + facing
			MOVESTATE_WALKING:
				match move_type: #If the NPC moves vertically/horizontally, they will change directions when they have exceeded their movement range
					MOVETYPE_HORIZONTAL:
						if move_direction == MOVEDIR_RIGHT:
							if parent.position.x > (start_position.x + move_range):
								facing = "left"
								move_direction = MOVEDIR_LEFT
							else:
								facing = "right"
						elif move_direction == MOVEDIR_LEFT:
							if parent.position.x < (start_position.x - move_range):
								facing = "right"
								move_direction = MOVEDIR_RIGHT
							else:
								facing = "left"
					MOVETYPE_VERTICAL:
						if move_direction == MOVEDIR_DOWN:
							if parent.position.y > (start_position.y + move_range):
								facing = "up"
								move_direction = MOVEDIR_UP
							else:
								facing = "down"
						elif move_direction == MOVEDIR_UP:
							if parent.position.y < (start_position.y - move_range):
								facing = "down"
								move_direction = MOVEDIR_DOWN
							else:
								facing = "up"
				
				linear_vel = velocity
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
				
				target_speed *= (WALK_SPEED / 200.0)
				parent.position += target_speed
				
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
