extends GridContainer

var amplitude = preload("res://textures/power-ups/power_amp.png")
var frequency = preload("res://textures/power-ups/power_freq.png")
var sine = preload("res://textures/power-ups/power_sin.png")
var cosine = preload("res://textures/power-ups/power_cos.png")

func _ready() -> void:
	Inventory.item_changed.connect(_on_item_changed)
	var inv = Inventory.list()
	for type in inv:
		_on_item_changed("added", type, inv[type])

func _on_item_changed(action: String, type: String, amount: float): 
	if action == "missing":
		# Gray out amplitude
		if type == "amplitude":
			$Amplitude.modulate = Color8(92,92,92)
			$AmplitudeLabel.text = "Amp:N/A"
		if type == "frequency":
			$Frequency.modulate = Color8(92,92,92)
			$FrequencyLabel.text = "Freq:N/A" #TODO figure out sine/cosine starting text 
		return
	# Ignore 'removed' messages. We will wait for 'added' actions. 
	if action != "added":
		return
	match type:
		"amplitude":
			$Amplitude.modulate = Color8(255,255,255)
			$AmplitudeLabel.text = "Amp:" + str(amount)
			#$Amplitude.texture = amplitude
		"sine":
			$ModifierLabel.text = "Sin"
			$Modifier.texture = sine
		"cosine":
			$ModifierLabel.text = "Cos"
			$Modifier.texture = cosine		
		"frequency":
			$Frequency.modulate = Color8(255,255,255)
			$FrequencyLabel.text = "Freq:" + str(amount)
			#$Frequency.texture = frequency
