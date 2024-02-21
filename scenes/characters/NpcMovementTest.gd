extends CharacterBody2D

"""
It just wraps around a sequence of dialogs. If it contains a child node named 'Quest'
which should be an instance of Quest.gd it'll become a quest giver and show whatever
text Quest.process() returns
"""

var active = false

@export var character_name: String = "Nameless NPC"
@export var dialogs = ["..."] # (Array, String, MULTILINE)
var current_dialog = 0

@export var WALK_SPEED: int = 350

var linear_vel = Vector2()
var target_position = Vector2()
var facing = "down" # (String, "up", "down", "left", "right")

var anim = ""
var new_anim = ""

@export var move_range = 150 # The distance at which the NPC can move from its starting point (default 50)
@export_enum("Horizontal", "Vertical", "None") var default_move_type = "None"

var start_position

enum { MOVESTATE_IDLE, MOVESTATE_WALKING_DEFAULT, MOVESTATE_WALKING_TOWARDS }
enum { MOVETYPE_NONE, MOVETYPE_HORIZONTAL, MOVETYPE_VERTICAL }
enum { MOVEDIR_UP, MOVEDIR_DOWN, MOVEDIR_LEFT, MOVEDIR_RIGHT }

var move_state = MOVESTATE_WALKING_DEFAULT
var move_type = MOVETYPE_NONE
var move_direction = MOVEDIR_DOWN

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	# warning-ignore:return_value_discarded
	#body_entered.connect(_on_body_entered)
	# warning-ignore:return_value_discarded
	#body_exited.connect(_on_body_exited)
	start_position = position # The starting position of the NPC (doesn't change)
	
	if default_move_type == "Horizontal":
		move_direction = MOVEDIR_RIGHT
	elif default_move_type == "Vertical":
		move_direction = MOVEDIR_DOWN
	pass # Replace with function body.

func _input(event): #Handles quests and other events
	# Bail if npc not active (player not inside the collider)
	if not active:
		return
	# Bail if Dialogs singleton is showing another dialog
	if Dialogs.active:
		return
	# Bail if the event is not a pressed "interact" action
	if not event.is_action_pressed("interact"):
		return
	
	# If the character is a questgiver delegate getting the text
	# to the Quest node, show it and end the function
	if has_node("Quest"):
		var quest_dialog = get_node("Quest").process()
		if quest_dialog != "":
			Dialogs.show_dialog(quest_dialog, character_name)
			return
	
	# If we reached here and there are generic dialogs to show, rotate among them
	if not dialogs.is_empty():
		Dialogs.show_dialog(dialogs[current_dialog], character_name)
		current_dialog = wrapi(current_dialog + 1, 0, dialogs.size())
		
#func _on_body_entered(body):
	#if body is Player:
		#active = true
		#
#func _on_body_exited(body):
	#if body is Player:
		#active = false

#Runs every frame
func _physics_process(_delta): ##Handles movement and other physics-related functions
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
						if position.x > (start_position.x + move_range):
							facing = "left"
							move_direction = MOVEDIR_LEFT
						else:
							facing = "right"
					elif move_direction == MOVEDIR_LEFT:
						if position.x < (start_position.x - move_range):
							facing = "right"
							move_direction = MOVEDIR_RIGHT
						else:
							facing = "left"
				MOVETYPE_VERTICAL:
					if move_direction == MOVEDIR_DOWN:
						if position.y > (start_position.y + move_range):
							facing = "up"
							move_direction = MOVEDIR_UP
						else:
							facing = "down"
					elif move_direction == MOVEDIR_UP:
						if position.y < (start_position.y - move_range):
							facing = "down"
							move_direction = MOVEDIR_DOWN
						else:
							facing = "up"
			if move_type != MOVETYPE_NONE:
				set_velocity(linear_vel)
				move_and_slide()
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
				
				target_speed *= WALK_SPEED
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
			if position == target_position: #If the position has been reached, switch to default move type
				goto_default_movetype()
				start_position = position
				pass
			
			set_velocity(Vector2.ZERO) #Stops any erratic movement from previous movement pattern
			
			if position.x > target_position.x:
				facing = "left"
			if position.x < target_position.x:
				facing = "right"
			if position.y > target_position.y:
				facing = "up"
			if position.y < target_position.y:
				facing = "down"
			
			position = position.move_toward(target_position, _delta * WALK_SPEED)
			pass

	if has_node("anims"):
		if new_anim != anim:
			anim = new_anim
			$anims.play(anim)
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
