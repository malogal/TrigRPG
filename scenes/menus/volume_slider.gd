extends HSlider

@export
var busName: String

@export
var defaultValue: float

var busIndex

@onready
var sliderElement = $"."

# Called when the node enters the scene tree for the first time.
func _ready():
	#print(defaultValue)
	busIndex = AudioServer.get_bus_index(busName)

	sliderElement.value = defaultValue
	value = db_to_linear(AudioServer.get_bus_volume_db(busIndex))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_value_changed(value):
	#print(value)
	AudioServer.set_bus_volume_db(busIndex, linear_to_db(value))
