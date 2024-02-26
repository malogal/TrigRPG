extends HBoxContainer


var heart_scene = preload("res://scenes/misc/Heart.tscn")


# You should probably rewrite this.
func _on_health_changed(new_hp):
	for child in get_children():
		child.queue_free()
	for i in new_hp:
		var heart = heart_scene.instantiate()
		add_child(heart)
	
