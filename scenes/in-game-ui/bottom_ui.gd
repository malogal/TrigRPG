extends MarginContainer

var regular_pie: Texture
var grey_pie: Texture
var player: Player = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	regular_pie = $HBoxContainer/PieSection/PieDisplay/TextureRect.texture
	grey_pie = load("res://textures/projectile/greyed-pie.png")
	
func assign_player(p: Player):
	player = p
	player.pie_changed.connect(_on_pie_changed)
	player.get_pie_available_signal().connect(_on_pie_available)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pie_changed(pie_amount: Angle):
	var rads: String = pie_amount.get_str_rad()
	if rads[0] == "1":
		rads = rads.substr(1)
	$HBoxContainer/PieSection/PieNumber.text =  rads + " : " + pie_amount.get_str_deg() + "º"

func _on_pie_available(is_available: bool):
	if is_available:
		$HBoxContainer/PieSection/PieDisplay/TextureRect.texture = regular_pie
	else:
		$HBoxContainer/PieSection/PieDisplay/TextureRect.texture = grey_pie
