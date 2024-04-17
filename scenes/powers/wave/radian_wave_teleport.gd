extends Node2D


var is_wave_active: bool = false
var waves: PackedScene
var wave_main: Node
var land_point_query: PhysicsShapeQueryParameters2D

func create_stop_wave(wave_specs: Dictionary):
	if is_wave_active:
		stop_wave()
	elif $WaveCooldown.is_stopped():
		$WaveCooldown.start()
		is_wave_active = true			
		wave_main = waves.instantiate()
		wave_main.new_wave(wave_specs)
		add_child(wave_main)

# Called when the node enters the scene tree for the first time.
func _ready():
	waves = preload("res://scenes/powers/wave/wave.tscn")
	set_wave_cooldown(1.5)
	set_teleport_cooldown(6.0)
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
	
# Returns (0,0) if wave_main has not been initatited yet, it is freed, or 
# teleport teleport is on CD. Should not be used if user is not teleporting. 
func get_teleport_to() -> Vector2:
	var point: Vector2 = wave_main.get_inner_wave_point()
	# If the teleportation point is near zero, don't start the cool down
	if point.is_zero_approx():
		return point
	$TeleportCooldown.start()
	return wave_main.get_inner_wave_point()

func stop_wave():
	if is_wave_active: 
		is_wave_active = false
		remove_child(wave_main)
		wave_main.free()
	
func is_wave_actived() -> bool:
	return is_wave_active
