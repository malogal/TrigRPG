extends CharacterBody2D

class_name Player

@export var WALK_SPEED: int = 150 # pixels per second
@export var ROLL_SPEED: int = 1000 # pixels per second
@export var hitpoints: int = 3
@export var time_invincible: float = 2.0
const time_to_teleport = .75

#const AngleClass = preload("res://misc-utility/Angle.gd")
var pie_amount = Angle.new(PI/2)
var pie_increment = Angle.new(PI/4)

var items: Dictionary = {}

var linear_vel: Vector2     = Vector2()
var roll_direction: Vector2 = Vector2.DOWN

const default_cooldown_pie: float = 2.0
const default_cooldown_wave: float = 1.5
const default_cooldown_teleport: float = 6.0
var freq_cooldown_modifier: float = 1.0

signal health_changed(current_hp)
# Signal new amount of pie
signal pie_changed(amount: Angle)


@export var facing: String = "down" # (String, "up", "down", "left", "right")

var despawn_fx: PackedScene = preload("res://scenes/misc/DespawnFX.tscn")

var anim: String                   = ""
var new_anim: String               = ""
var can_transition_animation: bool = true

enum { STATE_BLOCKED, STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT, PIE, WAVE}

var state
var action
var movement

var invincibility_timer
var is_invincible

var allowed_powers = {
	pie = true,
	teleport = true,
}

var movement_map: Dictionary = {
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

# Move the player to the corresponding spawnpoint, if any and connect to the dialog system
func _ready():
	var spawnpoints: Array[Variant] = get_tree().get_nodes_in_group("spawnpoints")
	for spawnpoint in spawnpoints:
		if spawnpoint.name == Globals.spawnpoint:
			global_position = spawnpoint.global_position
			break
	if not (
			Dialogs.dialog_started.connect(_on_dialog_started) == OK and
			Dialogs.dialog_ended.connect(_on_dialog_ended) == OK ):
		printerr("Error connecting to dialog system")
	$anims.play()
	

	
	# Probably a better way to do this incase running reinit causes items to be 'dropped'
	Inventory.item_changed.connect(_on_item_changed)
	freq_cooldown_modifier = Inventory.get_item("frequency", 1)
	set_cooldowns()
	
	$anims.animation_looped.connect(_on_anims_animation_looped)		
	$PieThrowing.turn_direction.connect(_on_pie_throwing_turn_direction)
	
	# getting current save path from load game screen
	print("currently in save " + Globals.currentSavePath)
	state = STATE_IDLE
	action = STATE_IDLE
	movement = movement_map.idle
	
	# Set up invincibility timer
	invincibility_timer = $invincibility_timer
	is_invincible = false

	# placeholder start run to run a dialog, fill with dialog file name
	#DialogueManager.show_example_dialogue_balloon(load("res://dialogue/cutscene1.dialogue"), "start")

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
		if !$WaveTeleport.is_wave_actived(): 
			if Input.is_action_just_pressed("throw_pie"):
				action = PIE
			if Input.is_action_just_pressed("change_pie_measurement_negative"):
				pie_amount.sub_angle(pie_increment)
				pie_changed.emit(pie_amount)
			elif Input.is_action_just_pressed("change_pie_measurement_positive"):
				pie_amount.add_angle(pie_increment)
				pie_changed.emit(pie_amount)
		if allowed_powers.teleport and Input.is_action_just_released("wave"):
			action = WAVE
		if allowed_powers.teleport and Input.is_action_just_pressed("teleport") && $WaveTeleport.can_teleport():
			$TeleportAnimated.visible = true
			$TeleportAnimated.play("teleport")
			# Start countdown until we teleport
			delayed_teleport($WaveTeleport.get_teleport_to())
			# Get out of wave teleport mode 
			$WaveTeleport.stop_wave()
			 
func _physics_process(_delta):
	if Globals.isDialogActive:
		$anims.stop()
		return
		
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
			new_anim = "die"
			#new_anim = "idle_"+facing
			state = STATE_IDLE
		STATE_HURT:
			new_anim = "hurt_"+facing
			#new_anim = "idle_"+facing
			state = STATE_IDLE
	match action:
		PIE: 
			var mouse_pos = get_local_mouse_position()
			$PieThrowing.throw(global_position, mouse_pos, pie_amount)
			new_anim = "throw_"+facing
		WAVE:
			var is_sine = true
			# To make sine the default in all cases except cosine picked up,
			# check for cosine in inventory instead of sine
			if Inventory.get_item("cosine", 0) != 0:
				is_sine = false
			$WaveTeleport.create_stop_wave(
				{
					"is_sine":is_sine,
					"is_horizontal": is_facing_horizontal(),
					"amplitude":Inventory.get_item("amplitude", 1),
					"frequency":Inventory.get_item("frequency", 1),
				})
			new_anim = "throw_"+facing
		_: 
			action = STATE_IDLE
			
	## UPDATE ANIMATION
	if new_anim != anim && can_transition_animation:
		# IF the old animation is one we don't want to inturrupt
		if new_anim.begins_with("throw") or new_anim.begins_with("hurt") or new_anim=="die":
			can_transition_animation = false
		assign_animation(new_anim)
		


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

func set_cooldowns():
	$PieThrowing.set_cooldown(default_cooldown_pie / freq_cooldown_modifier)
	$WaveTeleport.set_wave_cooldown(default_cooldown_wave / freq_cooldown_modifier)
	$WaveTeleport.set_teleport_cooldown(default_cooldown_teleport / freq_cooldown_modifier)

func _on_hurtbox_area_entered(area):
	damage_player(area)
	pass

func damage_player(area):
	if state != STATE_DIE and area.is_in_group("enemy_weapons") and !is_invincible:
		is_invincible = true
		invincibility_timer.wait_time = time_invincible
		invincibility_timer.start()
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
	var is_horizontal: bool = false
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
	
func _on_item_changed(action: String, type: String, amount: float) -> void:
	if type == "frequency":
		# Default frequency to 0 using 'get_item' instead of 'amount'
		freq_cooldown_modifier = Inventory.get_item("frequency", 1)
		set_cooldowns()
	# When an item is dropped, place it on the ground with the item spawner
	if action == "removed":
		$item_spawner.spawn(type, amount)
		
func get_pie_available_signal() -> Signal:
	return $PieThrowing.get_pie_available_signal()

func get_wave_available_signal() -> Signal:
	return $WaveTeleport.wave_available

func get_teleport_available_signal() -> Signal:
	return $WaveTeleport.teleport_available

func _on_invincibility_timer_timeout():
	is_invincible = false

func _on_teleport_animated_animation_finished() -> void:
	$TeleportAnimated.visible = false

func delayed_teleport(pos: Vector2):
	await get_tree().create_timer(time_to_teleport).timeout
	position.x += pos.x
	position.y += pos.y

func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y
	}
