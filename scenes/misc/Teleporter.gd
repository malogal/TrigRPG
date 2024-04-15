extends Node2D

class_name Teleporter
@export var radius: int = 20
@export var paired_teleporter: Teleporter
@export var exit_location: Vector2 = Vector2(0, -20)
@export var require_no_enemies: bool = false
@export var require_minigame_completion: bool = false
@export var requirement_distance: float = 250.0
## If enemies (or minigames) are in this direction relative to the teleporter, do not consider them for 'require_*'
@export var ignore_direction: Direction = Direction.NONE 
@export var provide_hint: bool = false

enum Direction {
	NONE, ## No restriction, consider all directions
	NORTH, ## Ignore enemies above
	EAST, ## Ignore enemies to the right
	SOUTH, ## Ignore enemies below
	WEST ## Ignore enemies to the left
}



var is_player_present = false

func _ready():
	$Area2D/CollisionShape2D.shape.radius = radius
	set_process_input(false)

# This scene only looks for input when the player is in the interact area
func _input(event): #Handles quests and other events
	# Bail if npc not active (player not inside the collider)
	if not is_player_present || paired_teleporter == null:
		return
	# Bail if the event is not a pressed "interact" action
	if not event.is_action_pressed("interact"):
		return
	# If teleportation is disabled until enemies are defeated, check if any are close by 
	if require_no_enemies && is_enemy_nearby():
		Globals.create_popup_window("Enemies remain", 1.5)
		return
	if require_minigame_completion && is_incomplete_minigame_nearby():
		Globals.create_popup_window("Incomplete minigame", 1.5)
		return
	paired_teleporter.emit_teleport()
	
func emit_teleport():
	get_tree().call_group("player", "teleport", to_global(exit_location))

func is_enemy_nearby() -> bool:
	var min_distance = INF  # Initialize with infinity

	# Get all nodes in the group
	var nodes_in_group = get_tree().get_nodes_in_group("enemies")
	
	for node in nodes_in_group:
		if _is_direction_ignored(node.global_position):
			continue  # Skip node based on ignore_direction 
		var distance = global_position.distance_to(node.global_position)  # Calculate the distance to each node
		if distance < min_distance:
			min_distance = distance
	
	return min_distance < requirement_distance

func is_incomplete_minigame_nearby() -> bool:
	var min_distance = INF  # Initialize with infinity
	var game_complete: bool = true
	# Get all nodes in the group
	var nodes_in_group = get_tree().get_nodes_in_group("minigame")
	
	for node in nodes_in_group:
		if _is_direction_ignored(node.global_position):
			continue  # Skip node based on ignore_direction 
		var distance = global_position.distance_to(node.global_position)  # Calculate the distance to each node
		if distance < min_distance:
			min_distance = distance
			game_complete = node.success
	
	return min_distance < requirement_distance && !game_complete

func _is_direction_ignored(node_pos: Vector2) -> bool:
	match ignore_direction:
		Direction.NORTH:
			return node_pos.y < position.y  # above the teleporter
		Direction.EAST:
			return node_pos.x > position.x  # right of the teleporter
		Direction.SOUTH:
			return node_pos.y > position.y  # below the teleporter
		Direction.WEST:
			return node_pos.x < position.x  # left of the teleporter
		_:
			return false  # No direction is ignored

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_present = true
		# Start listening for key binds now that the player is in the interact area
		set_process_input(true)
		if provide_hint:
			Globals.create_popup_window("'E' to interact", 1)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_present = false
		# Stop listening for key binds now that the player has left the interact area
		set_process_input(false)
