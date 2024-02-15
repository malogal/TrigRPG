extends Node2D

@export var speed = 350

var can_throw: bool
var pies: PackedScene

func throw(char_pos: Vector2, click_pos: Vector2, amount_of_pie: int = 10):
	if can_throw:
		$PieCooldown.start()
		var pie = pies.instantiate()
		add_child(pie)
		pie.new_pie(char_pos, click_pos, amount_of_pie, speed)
	

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
	
