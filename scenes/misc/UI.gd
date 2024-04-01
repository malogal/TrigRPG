extends CanvasLayer

var player : Player = null
func _ready():
	# Try to get the player node. If null wait till next frame, rinse, repeat.
	while (player == null):
		var player_group = get_tree().get_nodes_in_group("player")
		if not player_group.is_empty():
			player = player_group.pop_front()
		else:
			await get_tree().idle_frame
	
	player.health_changed.connect($Healthbar._on_health_changed)
	$Healthbar._on_health_changed(player.hitpoints)
	$BottomUi.assign_player(player)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func getSaveStats():
	return {
		'fileName': get_scene_file_path(),
		'parent': get_parent().get_path()
	}
