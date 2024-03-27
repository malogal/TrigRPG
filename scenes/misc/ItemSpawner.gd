extends Marker2D

"""
Add this to any node. spawn instances an Item.tscn node with the defined values
"""


var item_scene = preload("res://scenes/items/Item.tscn")
var sine_scene = preload("res://scenes/items/Sine.tscn")
var cosine_scene = preload("res://scenes/items/Cosine.tscn")
var amplitude_scene = preload("res://scenes/items/Amplitude.tscn")
var frequency_scene = preload("res://scenes/items/Frequency.tscn")
# Defaults values, but if spawn is called with non-default parameters, that item will drop instead
@export var item_type: String = "Generic Item"
@export var amount: float = 1.0


func spawn(_item_type: String = "", _amount: float = 1.0, position = null):
	if _item_type == "":
		_item_type = item_type
		_amount = amount
	var item: Node
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
	var level = owner.get_parent()
	while level != null && !level.is_in_group("levels"):
		level = level.get_parent()
	if level == null:
		return
		
	if position:
		item.position = position
	# Must set amount before adding child or it will default to 1
	item.amount = _amount
	item.add_to_group("saved", true)
	level.add_child(item)

	item.global_position = global_position
