extends Node

"""
Minimal inventory system implementation. 
It's just a dictionary where items are identified by a string key and hold an int amount
"""

# action can be 'added' some amount of some items is added and 'removed' when some amount
# of some item is removed
signal item_changed(action, type, amount)

var inventory = {}

func reset():
	inventory = {}
	
func init_inventory(inv: Dictionary):
	inventory = inv
	emit_current()

func emit_current():
	for type in inventory:
		if inventory[type] != 0:
			item_changed.emit("added", type, inventory[type])

# Only relevant for amplitude and freq
func emit_missing():
	if !inventory.has("amplitude") || inventory["amplitude"] == 0:
		item_changed.emit("missing", "amplitude", 0)
	if !inventory.has("frequency") || inventory["frequency"] == 0:
		item_changed.emit("missing", "frequency", 0)
		
func get_item(type:String, default: float = 0) -> float:
	if inventory.has(type):
		return inventory[type]
	else:
		return default


func add_item(type:String, amount:float = 1) -> bool: 
	if inventory.has(type) and inventory[type] != 0:
		item_changed.emit("removed", type, inventory[type])
	# Special cases for sine and cosine as they are opposite items, but occupy the same spot
	# If inventory has 'sine' already, 'cosine' should be amount == 0, and vise versa
	match type:
		"sine":
			if inventory.has("cosine") and inventory["cosine"] != 0:
				item_changed.emit("removed", "cosine", inventory["cosine"])
				inventory["cosine"] = 0
		"cosine":
			if inventory.has("sine") and inventory["sine"] != 0:
				item_changed.emit("removed", "sine", inventory["sine"])
				inventory["sine"] = 0
	inventory[type] = amount
	item_changed.emit("added", type, amount)
	return true

# TODO !!Unused for now, leaving incase we find a use for it!!
func remove_item(type:String, amount:float = 1) -> bool:
	if inventory.has(type) and inventory[type] >= amount:
		inventory[type] -= amount
		if inventory[type] == 0:
			inventory.erase(type)
		item_changed.emit("removed", type, amount)
		return true
	else:
		return false


func list() -> Dictionary:
	return inventory.duplicate()
