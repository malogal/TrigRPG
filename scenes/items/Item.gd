extends Area2D

@export var item_type: String = "Generic Item"
var amount: float = 1
var pickup_able: bool = false

const images: Dictionary = {
   "amplitude": {
		"image":preload("res://textures/power-ups/power_amp.png"), 
		"label":preload("res://fonts/amplitude_label_settings.tres"),
		"text":"Amp: ",
		"has_amount":true,
		},
   "frequency": {
		"image":preload("res://textures/power-ups/power_freq.png"),
		"label":preload("res://fonts/frequency_label_settings.tres"),
		"text":"Freq: ",		
		"has_amount":true,
		},
   "cosine": {
		"image":preload("res://textures/power-ups/power_cos.png"),
		"label":preload("res://fonts/modifier_label_settings.tres"),
		"text":"Cosine",
		"has_amount":false,
		},
   "sine": {
		"image":preload("res://textures/power-ups/power_sin.png"),
		"label":preload("res://fonts/modifier_label_settings.tres"),
		"text":"Sine",
		"has_amount":false,
		}
}

func pickup() -> void:
	body_entered.disconnect(_on_Item_body_entered)
	Inventory.add_item(item_type, amount)
	$anims.play("collected")


func _ready():
	body_entered.connect(_on_Item_body_entered)
	body_exited.connect(_on_Item_body_exited)
	if get_parent().is_in_group("power_up"):
		var name: StringName = get_parent().get_item_type()
		amount = get_parent().get_amount()
		# Set item's image and label based on name of parent
		$sprite.texture = images[name]["image"]
		$Label.label_settings = images[name]["label"]
		$Label.text = images[name]["text"]
		if images[name]["has_amount"]:
			$Label.text += str(amount) 
		item_type = name
		
func _process( delta: float, ) -> void:
	if pickup_able and Input.is_action_just_pressed("interact"):
		pickup_able = false
		pickup()
		
func _on_Item_body_entered(body):
	if body is Player:
		$anims.queue("flashing")
		pickup_able = true
		
func _on_Item_body_exited(body):
	if body is Player:
		pickup_able = false
		$anims.stop()
