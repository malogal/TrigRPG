extends Node2D

@export var speed = 350

signal wave_available(is_available: bool)
signal teleport_available(is_available: bool)

var is_wave_active: bool = false
var waves: PackedScene
var wave_main: Node
@onready var wave_cooldown: Timer = $WaveCooldown
var land_point_query: PhysicsShapeQueryParameters2D

func create_stop_wave(wave_specs: Dictionary):
	# If the wave was just started, don't cancel it yet. Likely a double trigger on keypress
	if is_wave_active and wave_cooldown.wait_time - wave_cooldown.time_left  > .1:
			stop_wave()
	elif $WaveCooldown.is_stopped():
		$WaveCooldown.start()
		is_wave_active = true			
		wave_main = waves.instantiate()
		wave_main.new_wave(wave_specs)
		add_child(wave_main)
		wave_available.emit(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	waves = preload("res://scenes/powers/wave/wave.tscn")
	set_wave_cooldown(1.5)
	set_teleport_cooldown(6.0)
 	# Layer 1
	var normal_physics_collision_mask: float = pow(2, 1-1)
	land_point_query = PhysicsShapeQueryParameters2D.new() 
	land_point_query.set_collision_mask(normal_physics_collision_mask)
	land_point_query.set_collide_with_bodies(true)
	land_point_query.set_collide_with_areas(false)
	land_point_query.set_shape(get_parent().get_shape())

func move_inner_wave(is_positive: bool):
	wave_main.move_inner_wave(is_positive)
	
func set_wave_cooldown(cd: float = 1.5):
	$WaveCooldown.wait_time = cd

func set_teleport_cooldown(cd: float = 6.0):
	$TeleportCooldown.wait_time = cd

func can_teleport() -> bool: 
	if wave_main == null:
		return false
	var point: Vector2 = wave_main.get_inner_wave_point()
	if !is_wave_active || !$TeleportCooldown.is_stopped() || point.is_zero_approx():
		return false
		
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	if is_disallowed_point(space_state) || is_disallowed_line(space_state):
		Globals.create_popup_window("Can't teleport here.", 1)
		return false
	return true

## Check if wave crosses the 'you shall not teleport' physics tilemap 
func is_disallowed_line(space_state: PhysicsDirectSpaceState2D) -> bool:
	var point: Vector2 = wave_main.get_inner_wave_point()
	var collision_mask = pow(2, 8-1)  # Layer 8
	var dest = to_global(point)
	var start = get_parent().global_position
	var query: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(start, dest, collision_mask, [])
	return !space_state.intersect_ray(query).is_empty()

## Check if wave ending lands on physics tile (or other collisions) 
func is_disallowed_point(space_state: PhysicsDirectSpaceState2D) -> bool:
	land_point_query.transform.origin = to_global(wave_main.get_inner_wave_point())
	return !space_state.intersect_shape(land_point_query, 1).is_empty()
			

## Returns location of inner wave. Only starts cooldown if point is not zero
## Should not be used if user is not teleporting. 
func get_teleport_to() -> Vector2:	
	var point: Vector2 = wave_main.get_inner_wave_point()
	# If the teleportation point is near zero, don't start the cool down
	if point.is_zero_approx():
		return point
	$TeleportCooldown.start()
	teleport_available.emit(false)
	return point

func stop_wave():
	if is_wave_active: 
		is_wave_active = false
		remove_child(wave_main)
		wave_main.free()
	
func is_wave_actived() -> bool:
	return is_wave_active

func _on_wave_cooldown_timeout() -> void:
	wave_available.emit(true)

func _on_teleport_cooldown_timeout() -> void:
	teleport_available.emit(true)
