extends AnimatedSprite2D

func setup(pie_amount: Angle):
	var names: PackedStringArray = sprite_frames.get_animation_names()
	var increment: float           = 2 * PI / ( names.size()) 
	for i in range(1, names.size()+1):
		if pie_amount.rads <= i * increment:
			animation = names[0].split("_", false, 1)[0] + "_" + str(i)
			return
			
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
