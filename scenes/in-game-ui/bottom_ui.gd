extends MarginContainer

var player: Player = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func assign_player(p: Player):
	player = p
	player.pie_changed.connect(_on_pie_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_pie_changed(pie_amount: Angle):
	$HBoxContainer/VBoxContainer/PieNumber.set_pie_text(pie_amount.get_str_rad() + " : " + pie_amount.get_str_deg() + "º")

