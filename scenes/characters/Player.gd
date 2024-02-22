extends CharacterBody2D

class_name Player

"""
This implements a very rudimentary state machine. There are better implementations
in the AssetLib if you want to make something more complex. Also it shares code with Enemy.gd
and probably both should extend some parent script
"""

@export var WALK_SPEED: int = 350 # pixels per second
@export var ROLL_SPEED: int = 1000 # pixels per second
@export var hitpoints: int = 3

var linear_vel = Vector2()
var roll_direction = Vector2.DOWN

var cooldown = 1.0

signal health_changed(current_hp)

@export var facing = "down" # (String, "up", "down", "left", "right")

var despawn_fx = preload("res://scenes/misc/DespawnFX.tscn")

var anim = ""
var new_anim = ""
var can_transition_animation: bool = true

enum { STATE_BLOCKED, STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT, PIE, WAVE}

var state
var action
var movement

# Move the player to the corresponding spawnpoint, if any and connect to the dialog system
func _ready():
	var spawnpoints = get_tree().get_nodes_in_group("spawnpoints")
	for spawnpoint in spawnpoints:
		if spawnpoint.name == Globals.spawnpoint:
			global_position = spawnpoint.global_position
			break
	if not (
			Dialogs.dialog_started.connect(_on_dialog_started) == OK and
			Dialogs.dialog_ended.connect(_on_dialog_ended) == OK ):
		printerr("Error connecting to dialog system")
	$anims.play()
	$anims.animation_looped.connect(_on_anims_animation_looped)
	$PieThrowing.set_cooldown(1.0)
	$PieThrowing.turn_direction.connect(_on_pie_throwing_turn_direction)
	# getting current save path from load game screen
	print("currently in save " + Globals.currentSavePath)
	state = STATE_IDLE
	action = STATE_IDLE
	movement = movement_map.idle

	# placeholder start run to run a dialog, fill with dialog file name
	#DialogueManager.show_example_dialogue_balloon(load("res://dialogue/cutscene1.dialogue"), "start")


var movement_map = { 
	up = { 
		input = "move_up",
		facing = "up",
		direction = Vector2(0,1),
		horizontal_wave = false
	},
	down = { 
		input = "move_down",
		facing = "down",
		direction = Vector2(0,-1),
		horizontal_wave = false
	},
	left = { 
		input = "move_left",
		facing = "left",
		direction = Vector2(-1,0),
		horizontal_wave = true
	},
	right = { 
		input = "move_right",
		facing = "right",
		direction = Vector2(1,0),
		horizontal_wave = true
	},
	idle = {
		horizontal_wave = false,
		facing = "down",
		direction = Vector2(0,0)
	},
}

# Updates state, action, and velocity
func get_input(): 
		var input_direction: Vector2 = Input.get_vector(movement_map.left.input, movement_map.right.input, movement_map.up.input, movement_map.down.input)
		velocity = input_direction * WALK_SPEED		
		movement = movement_map.idle
		move_and_slide()
		## FIXME this won't work if diagnal
		for dir in movement_map:
			var input = movement_map[dir]
			if input.has("input") && Input.is_action_pressed(input.input): 
				movement = input
				facing = input.facing
				state = STATE_WALKING
		action = STATE_IDLE
		if Input.is_action_just_pressed("throw_pie"):
			action = PIE
		if Input.is_action_just_released("wave"):
			action = WAVE
		if Input.is_action_just_pressed("teleport"):
			var point: Vector2 = $WaveTeleport.get_inner_wave_point()
			# Point recieved from wave teleport is relative
			position.x += point.x
			position.y += point.y
			$WaveTeleport.stop_wave()
			 
func _physics_process(_delta):
	## PROCESS STATES
	get_input()
	match state:
		STATE_BLOCKED:
			new_anim = "idle_" + facing
			pass
		STATE_IDLE:
			new_anim = "idle_" + facing
			pass
		STATE_WALKING:
			if velocity.length() > 5:
				new_anim = "walk_" + facing
			else:
				goto_idle()
			pass
		STATE_ATTACK:
			#new_anim = "slash_" + facing
			new_anim = "throw_"+facing
			pass
		STATE_DIE:
			#new_anim = "die"
			new_anim = "idle_"+facing
		STATE_HURT:
			#new_anim = "hurt"
			new_anim = "idle_"+facing
	match action:
		PIE: 
			var mouse_pos = get_local_mouse_position()
			$PieThrowing.throw(global_position, mouse_pos, 10)
			new_anim = "throw_"+facing
		WAVE:
			$WaveTeleport.create_wave({"is_sine":true, "is_horizontal": is_facing_horizontal()})
			new_anim = "throw_"+facing
		_: 
			action = STATE_IDLE
			
	## UPDATE ANIMATION
	if new_anim != anim && can_transition_animation:
		# IF the old animation is one we don't want to inturrupt
		if new_anim.begins_with("throw"):
			can_transition_animation = false
		assign_animation(new_anim)
		
	pass

func assign_animation(a: String):
	anim = new_anim
	$anims.stop()
	$anims.animation = anim
	$anims.play()			

func _on_dialog_started():
	state = STATE_BLOCKED

func _on_dialog_ended():
	state = STATE_IDLE


## HELPER FUNCS
func goto_idle():
	linear_vel = Vector2.ZERO
	new_anim = "idle_" + facing
	state = STATE_IDLE
	movement = movement_map.idle


func despawn():
	var despawn_particles = despawn_fx.instantiate()
	get_parent().add_child(despawn_particles)
	despawn_particles.global_position = global_position
	hide()
	await get_tree().create_timer(5.0).timeout
	get_tree().reload_current_scene()
	pass


func _on_hurtbox_area_entered(area):
	if state != STATE_DIE and area.is_in_group("enemy_weapons"):
		hitpoints -= 1
		emit_signal("health_changed", hitpoints)
		var pushback_direction = (global_position - area.global_position).normalized()
		set_velocity(pushback_direction * 5000)
		move_and_slide()
		state = STATE_HURT
		if hitpoints <= 0:
			state = STATE_DIE
	pass

func is_facing_horizontal() -> bool:
	var is_horizontal = false
	if facing.ends_with("left") or facing.ends_with("right"):
		is_horizontal = true
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		is_horizontal = true
	return is_horizontal or movement.horizontal_wave

func _on_anims_animation_finished() -> void:
	can_transition_animation = true


func _on_anims_animation_looped() -> void:
	can_transition_animation = true

func _on_pie_throwing_turn_direction(dir: String):
	facing = dir
	assign_animation("throw_" + facing)
	
