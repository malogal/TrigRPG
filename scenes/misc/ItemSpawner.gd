extends Marker2D

"""
Add this to any node. spawn instances an Item.tscn node with the defined values
"""


var item_scene = preload("res://scenes/items/Item.tscn")
var sine_scene = preload("res://scenes/items/Sine.tscn")
var cosine_scene = preload("res://scenes/items/Cosine.tscn")
var amplitude_scene = preload("res://scenes/items/Amplitude.tscn")
var frequency_scene = preload("res://scenes/items/Frequency.tscn")

const default_disabled_radius: float = 0.1

# Defaults values, but if spawn is called with non-default parameters, that item will drop instead
@export var item_type: String = "frequency"
@export var amount: float = 1.0
## Offset from item_spawn on where to spawn the item
@export var spawn_location: Vector2 = Vector2.ZERO
## Size of the area-2d to look for player interactions
@export var radius: float = default_disabled_radius

var is_player_present: bool = false

func _ready() -> void:
	set_process_input(false)
	# We only need to handle the Area2D collision if this spawner looks for user input
	if radius == default_disabled_radius:
		$Area2D/CollisionShape2D.disabled = true
		return
	$Area2D/CollisionShape2D.shape.radius = radius

func spawn(_item_type: String = "", _amount: float = 1.0):
	if _item_type == "":
		_item_type = item_type
		_amount = amount
	var item: Node2D
	match _item_type:
		"amplitude":
			item = amplitude_scene.instantiate()
		"sine":
			item = sine_scene.instantiate()
		"cosine":
			item = cosine_scene.instantiate()
		"frequency":
			item = frequency_scene.instantiate()
		_:
			return
	var level = get_parent()
	while level != null && !level.is_in_group("levels"):
		level = level.get_parent()
	if level == null:
		return

	# Must set amount before adding child or it will default to 1
	item.amount = _amount
	item.add_to_group("saved", true)
	level.add_child(item)
	
	item.global_position = global_position + spawn_location
	item.z_index = z_index
	
# This scene only looks for input when the player is in the interact area
func _input(event): #Handles quests and other events
	# Bail if npc not active (player not inside the collider)
	if not is_player_present:
		return
	# Bail if the event is not a pressed "interact" action
	if not event.is_action_pressed("interact"):
		return
	spawn()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_present = true
		# Start listening for key binds now that the player is in the interact area
		set_process_input(true)
		Globals.create_popup_window("'E' to interact", 1)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_present = false
		# Stop listening for key binds now that the player has left the interact area
		set_process_input(false)
