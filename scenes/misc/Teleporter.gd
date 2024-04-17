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
@export var on_contact: bool = false
@export var require_completion_status:	CompletionStatus = CompletionStatus.NONE
enum Direction {
	NONE, ## No restriction, consider all directions
	NORTH, ## Ignore enemies above
	EAST, ## Ignore enemies to the right
	SOUTH, ## Ignore enemies below
	WEST ## Ignore enemies to the left
}

enum CompletionStatus {
	NONE,
	CAMP,
	FOREST,
	TEMPLE,
}


var is_player_present = false

func _ready():
	$Area2D/CollisionShape2D.shape.radius = radius
	set_process(false)
	
# This scene only looks for input when the player is in the interact area
func _process( delta: float, ) -> void:
	# Bail if npc not active (player not inside the collider)
	if !is_player_present:
		return
	if not is_player_present || paired_teleporter == null:
		return
	# Bail if the event is not a pressed "interact" action
	if !Input.is_action_just_released("interact"):
		return
	# If teleportation is disabled until enemies are defeated, check if any are close by 
	if require_no_enemies && is_enemy_nearby():
		Globals.create_popup_window("Enemies remain", 1.5)
		return
	if require_minigame_completion && is_incomplete_minigame_nearby():
		Globals.create_popup_window("Incomplete minigame", 1.5)
		return
	if require_completion_status != CompletionStatus.NONE:
		match require_completion_status:
			CompletionStatus.CAMP:
				if Globals.get_player().hasVisitedCamp != true:
					Globals.create_popup_window("You are not ready yet", 1.5)
					return
			CompletionStatus.FOREST:
				if Globals.get_player().hasVisitedForest != true:
					Globals.create_popup_window("You are not ready yet", 1.5)
					return
			CompletionStatus.TEMPLE:
				if Globals.get_player().hasVisitedTemple != true:
					Globals.create_popup_window("You are not ready yet", 1.5)
					return

			CompletionStatus.NONE:
				pass
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
			return node_pos.y < global_position.y  # above the teleporter
		Direction.EAST:
			return node_pos.x > global_position.x  # right of the teleporter
		Direction.SOUTH:
			return node_pos.y > global_position.y  # below the teleporter
		Direction.WEST:
			return node_pos.x < global_position.x  # left of the teleporter
		_:
			return false  # No direction is ignored

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if on_contact:
			paired_teleporter.emit_teleport()
			return
		is_player_present = true
		# Start listening for key binds now that the player is in the interact area
		set_process(true)
		if provide_hint:
			Globals.create_popup_window("'E' to interact", 1)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_present = false
		# Stop listening for key binds now that the player has left the interact area
		set_process(false)
