extends CharacterBody2D

@export var health: float = PI/92
const AngleClass = preload("res://misc-utility/Angle.gd")
var health_angle

var ignore_new_anims: bool
var is_attacking: bool
var is_increasing_teleport: bool

var player_body: Node2D

@export var bounding_rect_size: float = 500.0
@export var off_center: Vector2 = Vector2.ZERO
@export var can_die: bool = false
@export var disabled: bool = false:
	set(value):
		disabled = value
		set_process(!disabled)
		$DirectionalAnimationSetter.disabled = true
		$RandomMover.disabled = true
		
var heart_class = preload("res://scenes/misc/RadianHeartScene.tscn")
@onready var heart_container = $GridContainer
var heart_arr = []
var is_dead = false
var rng = RandomNumberGenerator.new()

var use_wave_delay: Node
var damage_timer: Node
var teleport_timer: Node

func _ready():
	health_angle = AngleClass.new(health)
	if can_die:
		for i in 3:
			var heart = heart_class.instantiate()
			heart_container.add_child(heart)
			heart_arr.append(heart)
			
	# Weird hack to set scale down to a small value so we can grow it again later.
	# This is in case the player starts in the sight range 
	$sight_range.scale = $sight_range.scale * .1
	delayed_scale()
	
	$PieThrowing.set_pie_group_name("radian-pie")
	$Health.set_angle_text(health_angle)
	# Set up the random mover node with a rectangle centered on our position. Use default values for remaining parameters 
	$RandomMover.setup(bounding_rect_size, off_center)
	# This call is not necessary, as we are just telling it to use the default params. But it's here 
	# to show how the DirectionalAnimationSetter is used. Normally would pass in a dictionary
	$DirectionalAnimationSetter.set_animation_map()
	# Add a repeated delay to prevent constant teleporting
	# Could just use the WaveTeleport's built in cool down timer, but this prevents teleporting at spawn
	use_wave_delay = Timer.new()
	use_wave_delay.one_shot = true
	use_wave_delay.wait_time = 10
	add_child(use_wave_delay)
	use_wave_delay.start()
	
	damage_timer = Timer.new()
	damage_timer.one_shot = true
	damage_timer.wait_time = 1
	add_child(damage_timer)

	teleport_timer = Timer.new()
	teleport_timer.one_shot = true
	teleport_timer.wait_time = 2
	add_child(teleport_timer)
	
func _process(_delta: float) -> void:
	if can_die && heart_arr.is_empty():
		die()
		return
	if Globals.isDialogActive:
		return
	if is_attacking:
		$PieThrowing.throw(global_position, player_body.global_position, AngleClass.new(2*PI))
		$PieThrowing.set_cooldown(rng.randf_range(.75, 4))
	if rng.randi() % 18 == 0 && !$WaveTeleport.is_wave_actived() && use_wave_delay.is_stopped():
		use_wave_delay.start()
		teleport_timer.start()
		is_increasing_teleport = rng.randi() % 2 == 0
		$WaveTeleport.create_stop_wave({
			"is_sine":rng.randi() % 2 == 0,
			"amplitude":rng.randf_range(.75, 2),
			"frequency":rng.randf_range(.75, 2),
			})
	if $WaveTeleport.is_wave_actived():
		if rng.randi() % 4 == 0:
			$WaveTeleport.move_inner_wave(is_increasing_teleport)
		if $WaveTeleport.can_teleport() && teleport_timer.is_stopped():
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
	if velocity.is_zero_approx():
		$anims.stop()

func get_anims() -> String:
	return $anims.get_animation()

func get_shape() -> Shape2D:
	return $CollisionShape2D.shape	

func _on_sight_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_attacking = true
		player_body = body

func _on_sight_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_attacking = false


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("pie") && damage_timer.is_stopped():
		damage_timer.start()
		health_angle.add_angle(body.pie_get_amount())
		var pushback_direction = body.linear_velocity.normalized()
		set_velocity(pushback_direction * 500)
		move_and_slide()
		$Health.set_angle_text(health_angle)
		
		if health_angle.is_zero() && !heart_arr.is_empty():
			var heart = heart_arr.pop_back()
			heart_container.remove_child(heart)
			health_angle = AngleClass.new(0)

func die():
	modulate = modulate.darkened(1.0)
	is_dead = true
	velocity = Vector2.ZERO
	await get_tree().create_timer(2).timeout
	get_parent().remove_child(self)
	queue_free()

func delayed_teleport(pos: Vector2):
	await get_tree().create_timer(.75).timeout
	position.x += pos.x
	position.y += pos.y

func delayed_scale():
	await get_tree().create_timer(1).timeout
	$sight_range.scale = Vector2(1,1)
	
func _on_teleport_animated_animation_looped() -> void:
	$TeleportAnimated.visible = false


func _on_teleport_animated_animation_finished() -> void:
	$TeleportAnimated.visible = false
