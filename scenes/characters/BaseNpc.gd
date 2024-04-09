extends CharacterBody2D

"""
It just wraps around a sequence of dialogs. If it contains a child node named 'Quest'
which should be an instance of Quest.gd it'll become a quest giver and show whatever
text Quest.process() returns
"""

var active = false
enum NPC_TYPE {NPC_A, NPC_B, NPC_WIZARD}
enum START_ANIMATION_DIR {DOWN, UP, LEFT, RIGHT}

@export var npc_type: NPC_TYPE = NPC_TYPE.NPC_A
@export var character_name: String = "Nameless NPC"
@export var dialogs = ["..."] # (Array, String, MULTILINE)
@export var pause_movement_time: float = 2
@export var start_animation = START_ANIMATION_DIR.DOWN

var current_dialog = 0

# Multiplied by delta, so 1000 is not a lot 
@export var WALK_SPEED: int = 1000

var linear_vel = Vector2()
var target_position = Vector2()
var facing = "down" # (String, "up", "down", "left", "right")


@export var move_range = 50 # The distance at which the NPC can move from its starting point (default 50)
@export_enum("Horizontal", "Vertical", "None") var default_move_type = "None"

var start_position

enum { MOVESTATE_IDLE, MOVESTATE_WALKING_DEFAULT, MOVESTATE_WALKING_TOWARDS }
enum { MOVETYPE_NONE, MOVETYPE_HORIZONTAL, MOVETYPE_VERTICAL }
enum { MOVEDIR_UP, MOVEDIR_DOWN, MOVEDIR_LEFT, MOVEDIR_RIGHT }

var move_state = MOVESTATE_WALKING_DEFAULT
var move_type = MOVETYPE_NONE
var move_direction = MOVEDIR_DOWN
var timer: Node
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	$anims.animation = "idle_" + get_animation_direction_string() + "_" + get_npc_type_prefix()
	start_position = position # The starting position of the NPC (doesn't change)
	
	if default_move_type == "Horizontal":
		move_direction = MOVEDIR_RIGHT
	elif default_move_type == "Vertical":
		move_direction = MOVEDIR_DOWN
	elif default_move_type == "None":
		$DirectionalAnimationSetter.set_deactivate(true)
	timer = Timer.new()
	timer.wait_time = pause_movement_time
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_timer_stop)
	
# This scene only looks for input when the player is in the interact area
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
		
#Runs every frame
func _physics_process(delta: float): ## Handles movement and other physics-related functions
	if 	Globals.isDialogActive:
		return
	match move_state:
		MOVESTATE_WALKING_DEFAULT: #Make the NPC adhere to their default moving type
			match default_move_type:
				"None":
					move_type = MOVETYPE_NONE
				"Horizontal":
					move_type = MOVETYPE_HORIZONTAL
				"Vertical":
					move_type = MOVETYPE_VERTICAL
			var prev_move_dir = move_direction
			match move_type: #If the NPC moves vertically/horizontally, they will change directions when they have exceeded their movement range
				MOVETYPE_HORIZONTAL:
					if move_direction == MOVEDIR_RIGHT:
						if position.x > (start_position.x + move_range):
							move_direction = MOVEDIR_LEFT
					elif move_direction == MOVEDIR_LEFT:
						if position.x < (start_position.x - move_range):
							move_direction = MOVEDIR_RIGHT
				MOVETYPE_VERTICAL:
					if move_direction == MOVEDIR_DOWN:
						if position.y > (start_position.y + move_range):
							move_direction = MOVEDIR_UP
					elif move_direction == MOVEDIR_UP:
						if position.y < (start_position.y - move_range):
							move_direction = MOVEDIR_DOWN
			# If we just changed directions and we are set to pause on direction switches,
			# then stop moving and start the timer for pause_movement_time
			if move_direction != prev_move_dir and pause_movement_time != 0:
				goto_idle()
				timer.start()
				
			if move_type != MOVETYPE_NONE and timer.is_stopped():
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
				
				target_speed *= WALK_SPEED * delta
				linear_vel = target_speed
				
				if linear_vel == Vector2.ZERO:
					move_state = MOVESTATE_IDLE
		MOVESTATE_WALKING_TOWARDS:
			if position == target_position: #If the position has been reached, switch to default move type
				goto_default_movetype()
				start_position = position
				pass
			
			set_velocity(Vector2.ZERO) #Stops any erratic movement from previous movement pattern
			
			position = position.move_toward(target_position, delta * WALK_SPEED)
			pass
		MOVESTATE_IDLE:
			# Do nothing
			pass

func set_anims(anim: String):
	$anims.stop()
	$anims.animation = anim + "_" + get_npc_type_prefix()
	$anims.play()	

func get_anims() -> String:
	return $anims.get_animation()

func get_npc_type_prefix() -> String: 
	match npc_type:
		NPC_TYPE.NPC_A: 
			return "a"
		NPC_TYPE.NPC_B:
			return "b"
		NPC_TYPE.NPC_WIZARD:
			return "z"
		_: 
			printerr("failed to set Npc Type")
	return ""

func get_animation_direction_string() -> String: 
	match start_animation:
		START_ANIMATION_DIR.DOWN: 
			return "down"
		START_ANIMATION_DIR.UP:
			return "up"
		START_ANIMATION_DIR.LEFT:
			return "left"
		START_ANIMATION_DIR.RIGHT: 
			return "right"
		_: 
			printerr("failed to set Npc Type")
	return ""


## HELPER FUNCS
func goto_idle(): #Sets move state to idle
	velocity = Vector2.ZERO
	linear_vel = Vector2.ZERO
	move_state = MOVESTATE_IDLE

func goto_default_movetype(): #Sets move state to the NPC's default move type
	move_state = MOVESTATE_WALKING_DEFAULT

func move_to_point(moveX: float, moveY: float): #Sets the move state to walk towards the given coordinates
	move_state = MOVESTATE_WALKING_TOWARDS
	target_position = Vector2(moveX, moveY)

func _on_interact_area_body_entered(body: Node2D) -> void:
	if body is Player:
		active = true
		# Start listening for key binds now that the player is in the interact area
		set_process_input(true)


func _on_interact_area_body_exited(body: Node2D) -> void:
	if body is Player:
		active = false
		# Stop listening for key binds now that the player has left the interact area
		set_process_input(false)

func _on_timer_stop():
	move_state = MOVESTATE_WALKING_DEFAULT
