extends Line2D

@export var point_density := 1
@export var frequency := .01
@export var length := 2000
@export var amplitude := 900
# Called when the node enters the scene tree for the first time.

var array: PackedVector2Array

func _ready() -> void:
	array = PackedVector2Array()
	antialiased = true
	width = 10
	var i = 0
	while i < length: 
		array.append(Vector2(i, sin(i*frequency)*amplitude))
		i += point_density
	points = array
	apply(Vector2(20,20))
	

func apply(trans: Vector2):
	for i in range(array.size()): 
		array[i] = array[i]*trans

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
