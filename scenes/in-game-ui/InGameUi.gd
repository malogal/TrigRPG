extends CanvasLayer

var player : Player = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Try to get the player node. If null wait till next frame, rinse, repeat.
	while (player == null):
		var player_group = get_tree().get_nodes_in_group("player")
		if not player_group.is_empty():
			player = player_group.pop_front()
		else:
			await get_tree().idle_frame

	player.pie_changed.connect(_on_pie_changed)
	
#	player.health_changed.connect(_on_health_changed)
#	_on_health_changed(player.hitpoints)
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
