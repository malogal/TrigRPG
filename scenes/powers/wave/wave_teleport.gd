extends Node2D

@export var speed = 350

var can_teleport: bool
var is_wave_active: bool = false
var waves: PackedScene
var wave_main: Node

func create_wave(char_pos: Vector2):
	if can_teleport:
		if is_wave_active:
			is_wave_active = false
			remove_child(wave_main)
		else:
			is_wave_active = true			
			$WaveCooldown.start()
			wave_main = waves.instantiate()
			wave_main.new_wave(char_pos)
			add_child(wave_main)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	waves = preload("res://scenes/powers/wave/wave.tscn")
	can_teleport = true
	set_cooldown(1.5)
	pass # Replace with function body.

func set_cooldown(cd: float):
	$WaveCooldown.wait_time = cd
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_wave_cooldown_timeout():
	can_teleport = true
	
