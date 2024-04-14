extends CanvasLayer

var num_reloads := 0

var player : Player = null
func _ready():
	# When a game is loaded from save, the player class is created twice. 
	# We need to assing the UI's player AFTER the second load 
	call_deferred("load_player")
	pass # Replace with function body.

func load_player():
	while (player == null):
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			num_reloads += 1
			if num_reloads < 3:
				call_deferred("load_player")
			printerr("No player found in scene")
			return
	player.health_changed.connect($Healthbar._on_health_changed)
	$Healthbar._on_health_changed(player.hitpoints)
	$BottomUi.assign_player(player)
	
func _process(_delta):
	if player == null:
		pass
		#get_tree().reload_current_scene()
