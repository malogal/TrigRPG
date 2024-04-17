extends Node

var player: Player 
var prev_temple_visibile: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if Globals.loadGameToggle:	
		Globals.load_game()
		Globals.showGameOverScreen = false
	Input.set_use_accumulated_input(false)
	player = Globals.get_player()
	Globals.player_class_reloaded.connect(func(): player = Globals.get_player())
	
	$level/TempleScene.visible = false
	
	
func _process( delta: float, ) -> void:
	# If player is in temple area, set it to visible and mark 'temple_area_visible' as true so we 
	# don't keep setting it 'visible' every turn while it's already visible. 
	if prev_temple_visibile:
		if player.global_position.x > -1700:
			$level/TempleScene.visible = false
			prev_temple_visibile = false
	elif player.global_position.x <= -1700:
		$level/TempleScene.visible = true
		prev_temple_visibile = true