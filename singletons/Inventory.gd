extends Node

"""
Minimal inventory system implementation. 
It's just a dictionary where items are identified by a string key and hold an int amount
"""

# action can be 'added' some amount of some items is added and 'removed' when some amount
# of some item is removed
signal item_changed(action, type, amount)

var inventory = {}


func get_item(type:String, default: float = 0) -> float:
	if inventory.has(type):
		return inventory[type]
	else:
		return default


func add_item(type:String, amount:float = 1) -> bool:
	match type:
		"sine":
			inventory["cosine"] = 0
		"cosine":
			inventory["sine"] = 0
	inventory[type] = amount
	emit_signal("item_changed", "added", type, amount)
	return true

# TODO !!Unused for now, leaving incase we find a use for it!!
func remove_item(type:String, amount:float = 1) -> bool:
	if inventory.has(type) and inventory[type] >= amount:
		inventory[type] -= amount
		if inventory[type] == 0:
			inventory.erase(type)
		emit_signal("item_changed", "removed", type, amount)
		return true
	else:
		return false


func list() -> Dictionary:
	return inventory.duplicate()
