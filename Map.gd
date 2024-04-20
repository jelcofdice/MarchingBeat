extends TileMap

@export var size := Vector2i(11, 7)
@export var tile_size := 24 # Assume square tiles

@onready var packedUnit = preload("res://Unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.beat.connect(_on_beat)

func _on_beat_timeout():
	SignalBus.beat.emit()

func _on_beat():
	#var unit: Unit = Unit.new()
	var unit: Unit = packedUnit.instantiate()
	unit.set_starting(Vector2i(0, randi() % 7), Vector2i.RIGHT, randi() % 4, randi() % 2)
	unit.bearing = Vector2i.RIGHT
	add_child(unit)
