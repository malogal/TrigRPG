extends Node2D

@export var location_name: String = ""

func teleport_player():
	Globals.get_player().teleport(global_position)
