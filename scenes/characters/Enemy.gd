extends CharacterBody2D

class_name Enemy

const AngleClass = preload("res://misc-utility/Angle.gd")

@export var WALK_SPEED: int = 350
@export var ROLL_SPEED: int = 1000
@export var hitpoints: int = 3
@export var health: float = PI/2
var health_angle = AngleClass.new(health)
var despawn_fx = preload("res://scenes/misc/DespawnFX.tscn")

var linear_vel = Vector2()
var facing = "down" # (String, "up", "down", "left", "right")

var anim = ""
var new_anim = ""

var player
var attack_hitbox

enum { STATE_IDLE, STATE_WALKING, STATE_ATTACK, STATE_ROLL, STATE_DIE, STATE_HURT }

var state = STATE_IDLE

func _ready():
	randomize()
	$anims.speed_scale = randf_range(0.25,2)
	player = get_tree().get_nodes_in_group("player")[0]
	attack_hitbox = $attack_range

func _physics_process(_delta):
	if Globals.isDialogActive:
		$anims.stop()
		return
		
	match state:
		STATE_IDLE:
			new_anim = "idle_" + facing
		
		STATE_WALKING:
			set_velocity(linear_vel)
			move_and_slide()
			linear_vel = velocity
			
			var target_speed = Vector2()
			target_speed = (player.position - position).normalized()
			target_speed *= WALK_SPEED
			linear_vel = linear_vel.lerp(target_speed, 0.9)
			
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
		STATE_ATTACK:
			new_anim = "attack_" + facing
			player.damage_player(attack_hitbox)
			pass
		STATE_ROLL:
			set_velocity(linear_vel)
			move_and_slide()
			linear_vel = velocity
			var target_speed = Vector2()
			if facing == "up":
				target_speed.y = -1
			if facing == "down":
				target_speed.y = 1
			if facing == "left":
				target_speed.x = -1
			if facing == "right":
				target_speed.x = 1
			target_speed *= ROLL_SPEED
			linear_vel = linear_vel.lerp(target_speed, 0.9)
			new_anim = "roll"
			pass
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

## Triggers when entering line of sight
func _on_enter_sight(body):
	if body.get_parent().is_in_group("player"):
		state = STATE_WALKING
	pass
		
## Triggers when exiting line of sight
func _on_exit_sight(body):
	if body.get_parent().is_in_group("player"):
		state = STATE_IDLE
	pass

## Triggers when entering attack range
func _on_enter_attack_range(body):
	if body.get_parent().is_in_group("player"):
		state = STATE_ATTACK
	pass
## Triggers when exiting attack range
func _on_exit_attack_range(body):
	if body.get_parent().is_in_group("player"):
		state = STATE_WALKING
	pass

func despawn():
	var despawn_particles = despawn_fx.instantiate()
	get_parent().add_child(despawn_particles)
	despawn_particles.global_position = global_position
	if has_node("item_spawner"):
		get_node("item_spawner").spawn()
	queue_free()
	pass

func _on_hurtbox_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("pie") and state != STATE_DIE and $DamageTimer.is_stopped():
		$DamageTimer.start()
		health_angle.add_angle(body.pie_get_amount())
		var pushback_direction = body.linear_velocity.normalized()
		set_velocity(pushback_direction * 5000)
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
