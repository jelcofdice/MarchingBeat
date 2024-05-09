extends AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.beat.connect(_on_beat)

func _on_beat():
	play()