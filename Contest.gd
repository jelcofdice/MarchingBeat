class_name Contest
extends GridSprite

var lifetime: float = 2.0
var age: float = 0.0

func _ready():
	SignalBus.beat.connect(_on_beat)

func _on_beat():
	age += 1
	if age >= lifetime:
		queue_free()
	modulate.a = 1 - age / lifetime # Fade out over 4 beats
