extends HFlowContainer

var regular_pie: Texture
var grey_pie: Texture
var player: Player = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# After children have been built, emit inventory. Player does the same, but UI might be built afterwards
	Inventory.emit_current()
	Inventory.emit_missing()


	
func assign_player(p: Player):
	player = p
	player.pie_changed.connect(_on_pie_changed)
	player.get_pie_available_signal().connect(_on_pie_available)
	player.get_wave_available_signal().connect(_on_wave_available)
	player.get_teleport_available_signal().connect(_on_teleport_available)
	player.emit_pie_changed()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_pie_changed(pie_amount: Angle):
	var rads: String = pie_amount.get_rich_str_rad()
	var deg: String = pie_amount.get_str_deg()
	$HBoxContainer/PieSection/HBoxContainer/PieNumberRad.text = "[center][color=Crimson]" + rads + "[/color][/center]"
	$HBoxContainer/PieSection/HBoxContainer/PieNumberDeg.text = "[center][color=Crimson]" + deg + "º[/color][/center]"
	var num_frames: int = $HBoxContainer/PieSection/HBoxContainer2/PieSprite.texture.frames
	$HBoxContainer/PieSection/HBoxContainer2/CircleSegment.shade_fraction = pie_amount.rads
	
	var increment: float = 2 * PI / ( num_frames)
	# Set amount of pie to show based on current throw amount  (frame 0 is lowest)
	for i in range(0, num_frames):
		if pie_amount.rads <= (i+1) * increment:
			$HBoxContainer/PieSection/HBoxContainer2/PieSprite.texture.current_frame = i
			return
	# If frame was not set above, set it to max
	$HBoxContainer/PieSection/PieSprite.texture.current_frame = num_frames - 1

func _on_pie_available(is_available: bool):
	if is_available:
		$HBoxContainer/PieSection/HBoxContainer2/PieSprite.modulate = Color8(255,255,255)
		$HBoxContainer/Cooldowns/Buttons/ClickButton.button_pressed = false
	else:
		$HBoxContainer/PieSection/HBoxContainer2/PieSprite.modulate = Color8(92,92,92)
		$HBoxContainer/Cooldowns/Buttons/ClickButton.button_pressed = true

func _on_wave_available(is_available: bool):
	if is_available:
		$HBoxContainer/Cooldowns/Buttons/FBtutton.button_pressed = false
	else:
		$HBoxContainer/Cooldowns/Buttons/FBtutton.button_pressed = true

func _on_teleport_available(is_available: bool):
	if is_available:
		$HBoxContainer/Cooldowns/Buttons/TabButton.button_pressed = false
	else:
		$HBoxContainer/Cooldowns/Buttons/TabButton.button_pressed = true

