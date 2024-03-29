extends CharacterBody2D

@export var health: float = PI/92
const AngleClass = preload("res://misc-utility/Angle.gd")
var health_angle = AngleClass.new(health)
var ignore_new_anims: bool
var is_attacking: bool
var is_increasing_teleport: bool
var player_body: Node2D
@export var can_die: bool = false

var rng = RandomNumberGenerator.new()

func _ready():
	$PieThrowing.set_pie_group_name("radian-pie")
	$Health.set_angle_text(health_angle)

func _physics_process(delta: float) -> void:
	if is_attacking:
		$PieThrowing.throw(global_position, player_body.global_position, AngleClass.new(2*PI))
		$PieThrowing.set_cooldown(rng.randf_range(.75, 4))
	if rng.randi() % 18 && !$WaveTeleport.is_wave_actived():
		is_increasing_teleport = rng.randi() % 2 == 0
		$WaveTeleport.create_stop_wave({
			"is_sine":rng.randi() % 2 == 0,
			"amplitude":rng.randf_range(.75, 2),
			"frequency":rng.randf_range(.75, 2),
			})
		$WaveTeleport.set_wave_cooldown(rng.randf_range(2, 5))
	if $WaveTeleport.is_wave_actived():
		if rng.randi() % 4 == 0:
			$WaveTeleport.move_inner_wave(is_increasing_teleport)
		if $WaveTeleport.can_teleport():
			$TeleportAnimated.visible = true
			$TeleportAnimated.play("teleport")
			# Start countdown until we teleport
			delayed_teleport($WaveTeleport.get_teleport_to())
			# Get out of wave teleport mode 
			$WaveTeleport.stop_wave()
			$WaveTeleport.set_teleport_cooldown(rng.randf_range(4, 8))
	
func set_anims(anim: String):
	if ignore_new_anims:
		return
	$anims.stop()
	$anims.animation = anim
	$anims.play()	

func get_anims() -> String:
	return $anims.get_animation()


func _on_sight_range_body_entered(body: Node2D) -> void:
	if body.get_parent().is_in_group("player"):
		is_attacking = true
		player_body = body

func _on_sight_range_body_exited(body: Node2D) -> void:
	if body.get_parent().is_in_group("player"):
		is_attacking = false


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("pie"):
		health_angle.add_angle(body.pie_get_amount())
		var pushback_direction = body.linear_velocity.normalized()
		set_velocity(pushback_direction * 5000)
		move_and_slide()
		#state = STATE_HURT
		$Health.set_angle_text(health_angle)
		if health_angle.is_zero() && can_die:
			$state_changer.stop()

func delayed_teleport(pos: Vector2):
	await get_tree().create_timer(.75).timeout
	position.x += pos.x
	position.y += pos.y
