extends Node2D

@export var speed = 350

signal wave_available(is_available: bool)
signal teleport_available(is_available: bool)

var is_wave_active: bool = false
var waves: PackedScene
var wave_main: Node

func create_stop_wave(wave_specs: Dictionary):
	if is_wave_active:
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

func set_wave_cooldown(cd: float = 1.5):
	$WaveCooldown.wait_time = cd

func set_teleport_cooldown(cd: float = 6.0):
	$TeleportCooldown.wait_time = cd

func can_teleport() -> bool: 
	return $TeleportCooldown.is_stopped() && is_wave_active
	
# Returns (0,0) if wave_main has not been initatited yet, it is freed, or 
# teleport teleport is on CD. Should not be used if user is not teleporting. 
func get_teleport_to() -> Vector2:	
	# if wave has not been init, the wave isn't active, or teleport is still on CD, return (0,0)
	if wave_main == null || !is_wave_active || !$TeleportCooldown.is_stopped(): 
		return Vector2(0,0) 
	var point: Vector2 = wave_main.get_inner_wave_point()
	# If the teleportation point is near zero, don't start the cool down
	if point.is_zero_approx():
		return point
	$TeleportCooldown.start()
	teleport_available.emit(false)
	return wave_main.get_inner_wave_point()

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
