extends Node2D

@export var speed = 700

var can_throw: bool
var pies: PackedScene
signal turn_direction(dir: String)
signal pie_available(is_available: bool)

func throw(char_pos: Vector2, click_pos: Vector2, amount_of_pie: Angle):

	if can_throw:
		can_throw = false
		$PieCooldown.start()
		pie_available.emit(false)
		var pie = pies.instantiate()
		add_child(pie)
		pie.new_pie(char_pos, click_pos, amount_of_pie, speed)
		
		var deg = rad_to_deg(pie.get_velocity().angle())
		var str_dir 
		if abs(deg) < 45:
			str_dir = "right"
		if deg >= 45 && deg <= 135:
			str_dir = "down"
		if abs(deg) > 135:
			str_dir = "left"
		if deg <= -45 && deg >= -135:
			str_dir = "up"
		turn_direction.emit(str_dir)
	

# Called when the node enters the scene tree for the first time.
func _ready():
	pies = preload("res://scenes/powers/pie/pie.tscn")
	can_throw = true
	set_cooldown(1.5)

func set_cooldown(cd: float):
	$PieCooldown.wait_time = cd
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_pie_cooldown_timeout():
	can_throw = true
	pie_available.emit(true)

func get_pie_available_signal() -> Signal:
	return pie_available
