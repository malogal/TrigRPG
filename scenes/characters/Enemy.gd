extends CharacterBody2D

class_name Enemy

const AngleClass = preload("res://misc-utility/Angle.gd")

var WALK_SPEED: int = 3800
@export var health: float = PI/2
@export var health_in_radian: bool = true
@export var allow_2x_amplitude_drop: bool = false

var health_angle
var despawn_fx = preload("res://scenes/misc/DespawnFX.tscn")

var linear_vel = Vector2()
var facing = "down" # (String, "up", "down", "left", "right")

var anim = ""
var new_anim = ""

var player
# A crude way to do a rarity of drop set-up
var drop_array = ["sine", "sine", "sine", "cosine", "cosine", "frequency", "frequency", "frequency", "amplitude"]
var drop_ammount_array = [1.0, 1.0, 1.0, 1.0, 1.2, 1.2, 1.2, 1.2, 1.5, 1.5, 1.5, 1.75, 1.75, 2.0]

enum { STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT }

var state = STATE_IDLE

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var give_up_timer = $GiveUpFollowingTimer

func _ready():
	health_angle = AngleClass.new(health)
	randomize()
	$anims.speed_scale = randf_range(0.25,2)
	player = get_tree().get_nodes_in_group("player")[0]
	$Health.is_radian = health_in_radian
	$Health.set_angle_text(health_angle)
	# Connect the navigation agent's 	signal for path readiness
	navigation_agent.path_desired_distance = 4.0
	navigation_agent.target_desired_distance = 4.0

var num_reloads := 3
func actor_setup():
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			num_reloads += 1
			if num_reloads < 3:
				call_deferred("actor_setup")
			printerr("No player found in scene")
			return
	set_movement_target(player.global_position)


func set_movement_target(movement_target: Vector2):
	navigation_agent.target_position = movement_target
			
func _physics_process(_delta):
	if Globals.isDialogActive:
		$anims.stop()
		return
	
	match state:
		STATE_IDLE:
			new_anim = "idle_" + facing
		
		STATE_WALKING:

			var current_agent_position: Vector2 = global_position
			var next_path_position: Vector2 = navigation_agent.get_next_path_position()

			velocity = current_agent_position.direction_to(next_path_position) * WALK_SPEED*_delta
			move_and_slide()
			linear_vel = velocity
			#var collisions = move_and_collide(velocity, true)
			##collisions.get_collider()
			#set_velocity(linear_vel)
			#move_and_slide()
			#linear_vel = velocity
			#
			#var target_speed = Vector2()
			#target_speed = (player.global_position - global_position).normalized()
			#target_speed *= WALK_SPEED*_delta
			#linear_vel = linear_vel.lerp(target_speed, 0.9)
			
			if linear_vel != Vector2.ZERO:
				new_anim = "walk_" + facing
			else:
				state = STATE_IDLE
			
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
			pass
		#STATE_ATTACK:
			#new_anim = "attack_" + facing
			#pass
		STATE_DIE:
			new_anim = "die"
		#STATE_HURT:
			#new_anim = "hurt"
	
	#override for testing
	#new_anim = "walk_right"
	
	if new_anim != anim:
		anim = new_anim
		$anims.stop()
		$anims.play(anim)
	pass


func goto_idle():
	state = STATE_IDLE

## Triggers when entering attack range
func _on_enter_attack_range(body):
	if body.get_parent().is_in_group("player"):
		#state = STATE_ATTACK
		$AnimationPlayer.play("attack")
	pass
## Triggers when exiting attack range
func _on_exit_attack_range(body):
	if body.get_parent().is_in_group("player"):
		await get_tree().create_timer(0.5).timeout
		$AnimationPlayer.play("RESET")
		#state = STATE_WALKING
	pass

func despawn():
	var despawn_particles = despawn_fx.instantiate()
	get_parent().add_child(despawn_particles)
	despawn_particles.global_position = global_position
	var drop_item: String= drop_array[randi() % drop_array.size()]
	var drop_amount: float = drop_ammount_array[randi() % drop_ammount_array.size()]
	if drop_item == "amplitude" && allow_2x_amplitude_drop && drop_amount > 1.75:
		drop_amount = 1.75
	if has_node("item_spawner"):
		get_node("item_spawner").spawn(drop_item, drop_amount)
	queue_free()
	pass

func _on_hurtbox_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("pie") and state != STATE_DIE and $DamageTimer.is_stopped():
		$DamageTimer.start()
		health_angle.add_angle(body.pie_get_amount())
		var pushback_direction = body.linear_velocity.normalized()
		set_velocity(pushback_direction * 30)
		move_and_slide()
		#state = STATE_HURT
		$state_changer.start()
		$Health.set_angle_text(health_angle)
		if health_angle.is_zero():
			$state_changer.stop()
			state = STATE_DIE
			despawn()


func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y
	}


func _on_sight_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		give_up_timer.stop()
		state = STATE_WALKING
		actor_setup()
		$NavigationAgent2D/Timer.start()


func _on_sight_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Don't stop following the player right away 
		give_up_timer.start()



func _on_timer_timeout() -> void:
	actor_setup()



func _on_give_up_following_timer_timeout() -> void:
	state = STATE_IDLE
	$NavigationAgent2D/Timer.stop()
