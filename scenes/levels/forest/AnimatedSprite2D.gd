extends AnimatedSprite2D

var dialogue = preload("res://dialogue/receive_teleport.dialogue")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("subscribe_to_signal")
	pass

var retry_count_remaining = 3
func subscribe_to_signal():
	var cutscene = get_parent()
	var player: Player = Globals.player
	if cutscene == null || player == null:
		if retry_count_remaining < 0:
			printerr("failed to get parent or player")
			return
		call_deferred("subscribe_to_signal")
		retry_count_remaining =- 1
		return
	cutscene.bestow_teleport.connect(func(): 
		global_position = player.global_position
		play("pi-symbol")
		player.allow_teleport()

		await get_tree().create_timer(5).timeout
		stop()
		visible = false
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
