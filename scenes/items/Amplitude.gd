extends Node2D

@export var amount: float = 1
@export var should_save: bool = true

func _ready() -> void:
	if !should_save:
		remove_from_group("saved")
func get_amount() -> float:
	return amount

func get_item_type() -> String:
	return "amplitude"


func getSaveStats():
	if !should_save:
		return null
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path(),
		'posX': position.x,
		'posY': position.y
	}
