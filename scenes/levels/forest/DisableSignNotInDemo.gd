extends Node2D

func _ready():
	if !Globals.demo_mode:
		visible = false
