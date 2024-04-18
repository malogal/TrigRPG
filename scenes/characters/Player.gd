extends CharacterBody2D

class_name Player

@export var WALK_SPEED: int = 150 # pixels per second
@export var ROLL_SPEED: int = 1000 # pixels per second
@export var hitpoints: int = 3
@export var time_invincible: float = 2.0
# impulse_power is used to push objects. Is multiplied by delta
@export var impulse_power: float = 1000

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

var thrownPieCount: int = 0

@export var facing: String = "down" # (String, "up", "down", "left", "right")

var despawn_fx: PackedScene = preload("res://scenes/misc/DespawnFX.tscn")
var bestow_teleport_dialogue = preload("res://dialogue/receive_teleport.dialogue")

var anim: String                   = ""
var new_anim: String               = ""
var can_transition_animation: bool = true

enum { STATE_BLOCKED, STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT, PIE, WAVE}

var state
var action
var movement

var invincibility_timer
var is_invincible
var shapes_in_hurtbox: Dictionary = {}


## Teleport is unlocked through demo mode or through priestess. If unlocked naturally, save it
var allowed_powers = {
	pie = true,
	teleport = false,
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

var hasVisitedCamp = false
var hasVisitedForest = false
var hasVisitedTemple = false

# Move the player to the corresponding spawnpoint, if any and connect to the dialog system
func _ready():
	Globals.register_player(self)
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
	
	# Assuming inventory loaded before dependent nodes, re-emit it's current state (for player, UI, ect.)
	Inventory.emit_current()
	Inventory.emit_missing()
	# placeholder start run to run a dialog, fill with dialog file name
	#DialogueManager.show_example_dialogue_balloon(load("res://dialogue/cutscene1.dialogue"), "start")
	
	# Recieve teleport either from visting in past or from an assignment of allowed_powers.
	allowed_powers.teleport = hasVisitedTemple || allowed_powers.teleport
	if !allowed_powers.teleport:
		# Only allow teleport powers in debug mode (unless player has unlocked it)
		allowed_powers.teleport = Globals.demo_mode
		# If we had received teleportation naturally, we wouldn't want to subscribe to this signal
		Globals.demo_mode_changed.connect(func(is_active: bool): allowed_powers.teleport = is_active)
	health_changed.emit(hitpoints)
		
# Handles only movement
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
			if Globals.just_pressed_not_consumed("throw_pie"):
				action = PIE
			if Input.is_action_just_pressed("change_pie_measurement_negative"):
				pie_amount.sub_angle(pie_increment)
				pie_changed.emit(pie_amount)
			elif Input.is_action_just_pressed("change_pie_measurement_positive"):
				pie_amount.add_angle(pie_increment)
				pie_changed.emit(pie_amount)
		else:
			if Input.is_action_pressed("change_pie_measurement_negative"):
				$WaveTeleport.move_inner_wave(false)
			elif Input.is_action_pressed("change_pie_measurement_positive"):
				$WaveTeleport.move_inner_wave(true)
		if Input.is_action_just_released("wave"):
			if allowed_powers.teleport:
				action = WAVE
			else:
				Globals.create_popup_window("Must unlock teleport", 1.5)
		if Input.is_action_just_pressed("teleport"):
			if allowed_powers.teleport:
				if $WaveTeleport.can_teleport():
					$TeleportAnimated.visible = true
					$TeleportAnimated.play("teleport")
					# Start countdown until we teleport
					delayed_teleport($WaveTeleport.get_teleport_to())
					# Get out of wave teleport mode 
					$WaveTeleport.stop_wave()
			else:
				Globals.create_popup_window("Must unlock teleport", 1.5)

func _physics_process(delta):		
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
			var mouse_pos = get_global_mouse_position()
			# Only update animation if pie is actually thrown
			if $PieThrowing.throw(global_position, mouse_pos, pie_amount):
				new_anim = "throw_"+facing
				thrownPieCount = thrownPieCount + 1
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
	
	# Push objects without the object clipping out 
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		if col.get_collider() is RigidBody2D \
			and col.get_collider().get_groups().has("moveable"):
#			and not col.get_collider().is_sleeping():
			
			col.get_collider().apply_central_impulse(-col.get_normal()*impulse_power*delta)

	#checking coordinates to see where in map for achievements
	if not hasVisitedCamp:
		if global_position.y > -1250:
			hasVisitedCamp = true
	if not hasVisitedForest:
		if position.y < -1250:
			hasVisitedForest = true
	if not hasVisitedTemple:
		var x = global_position
		if global_position.x < -1000:
			hasVisitedTemple = true
			allowed_powers.teleport = true

# Used by external nodes that need to teleport the player. Example, a ladder that moves the character 
# To another area. 
func teleport(out_location: Vector2): 
	global_position = out_location

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

func bestow_teleport():
	allowed_powers.teleport = true
	if get_tree().paused:
		assert(false)
	$BestowTeleportAnimation.play("teleport")
	$BestowTeleportAnimation.visible = true
	Globals.startDialogueStored(bestow_teleport_dialogue, "start")
	var dialogue_manager = Engine.get_singleton("DialogueManager")
	await dialogue_manager.dialogue_ended
	$BestowTeleportAnimation.stop()
	$BestowTeleportAnimation.visible = false
	
func _on_hurtbox_area_entered(area):
	damage_player(area)
	shapes_in_hurtbox[area] = true
	pass

func _on_hurtbox_body_entered(body: Node2D) -> void:
	damage_player(body)
	shapes_in_hurtbox[body] = true
		
func emit_pie_changed():
	pie_changed.emit(pie_amount)


func _on_hurtbox_area_exited(area: Area2D) -> void:
	shapes_in_hurtbox.erase(area)
	
func _on_hurtbox_body_exited(body: Node2D) -> void:
	shapes_in_hurtbox.erase(body)

func _on_invincibility_timer_timeout():
	is_invincible = false
	# If nodes that hurt the player are still in shapes_in_hurtbox, then they have not yet left 
	# the area. So attempt to damage the player again. 
	for key in shapes_in_hurtbox:
		damage_player(key)
	
# Returns true if the player was allowed to be damaged 
func damage_player(area):
	if state != STATE_DIE and !is_invincible and (area.is_in_group("enemy_weapons") or area.is_in_group("radian-pie")):
		is_invincible = true
		invincibility_timer.wait_time = time_invincible
		invincibility_timer.start()
		# Check if cutscene 2 is done and cutscene 3 isn't (meaning player is in first Radian fight), and play cutscene 3 instead of the game over screen if so
		#if hitpoints == 1 and get_node("/root/Outside/level/ForestLevel/Cutscene2").finished == true and get_node("/root/Outside/level/ForestLevel/Cutscene3").visited == false:
			#get_node("/root/Outside/level/ForestLevel/Cutscene3").start_intro()
			#hitpoints = 3
		#else: # Otherwise, lower health
		hitpoints -= 1
		emit_signal("health_changed", hitpoints)
		var pushback_direction = (global_position - area.global_position).normalized()
		set_velocity(pushback_direction * 1000)
		move_and_slide()
		state = STATE_HURT
		if hitpoints <= 0:
			state = STATE_DIE
			# toggle death screen
			Globals.showGameOverScreen = true
		return true
	return false
	

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
	# Even if item_changed action is "missing" or "removed" we should still set frequency
	# cooldown to the base value of '1'. It will only not be 1 when the Inventory has Freq and it's 1+
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

func get_shape() -> Shape2D:
	return $player_body.shape

func delayed_teleport(pos: Vector2):
	await get_tree().create_timer(time_to_teleport).timeout
	position.x += pos.x
	position.y += pos.y

func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y,
		'hitpoints': hitpoints,
		'thrownPieCount': thrownPieCount,
		'hasVisitedCamp': hasVisitedCamp,
		'hasVisitedForest': hasVisitedForest,
		'hasVisitedTemple': hasVisitedTemple,
		'allowed_powers': allowed_powers,
	}
	
func getAchievementStats():
	return {
		'thrownPieCount': thrownPieCount,
		'hasVisitedCamp': hasVisitedCamp,
		'hasVisitedForest': hasVisitedForest
	}

# Stop showing teleport sparkles after it finishes animating 
func _on_teleport_animated_animation_looped() -> void:
	$TeleportAnimated.visible = false

# Stop showing teleport sparkles after it finishes animating 
func _on_teleport_animated_animation_finished() -> void:
	$TeleportAnimated.visible = false


