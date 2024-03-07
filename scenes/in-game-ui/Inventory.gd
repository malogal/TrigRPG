extends GridContainer

var amplitude = preload("res://textures/power-ups/blue-box.png")
var frequency = preload("res://textures/power-ups/green-box.png")
var sine = preload("res://textures/power-ups/purple-box.png")
var cosine = preload("res://textures/power-ups/red-box.png")

func _ready() -> void:
	Inventory.item_changed.connect(_on_item_changed)
	var inv = Inventory.list()
	for type in inv:
		_on_item_changed("added", type, inv[type])

func _on_item_changed(action: String, type: String, amount: float): 
	if action != "added":
		return
	match type:
		"amplitude":
			$Amplitude.visible = true
			if amount == 0:
				amount = 1
				$Amplitude.visible = false
			$AmplitudeLabel.text = "Amp: " + str(amount)
			$Amplitude.texture = amplitude
		"sine":
			$ModifierLabel.text = "Sine"
			$Modifier.texture = sine
		"cosine":
			$ModifierLabel.text = "Cosine"
			$Modifier.texture = cosine			
		"frequency":
			$Frequency.visible = true
			if amount == 0:
				amount = 1
				$Frequency.visible = false
			$FrequencyLabel.text = "Freq: " + str(amount)
			$Frequency.texture = frequency
