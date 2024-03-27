extends Node2D

@export var amount: float = 1

func get_amount() -> float:
	return amount

func get_item_type() -> String:
	return "amplitude"


func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y
	}
