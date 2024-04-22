extends TileMap

@export var size := Vector2i(13, 10)
@export var tile_size := 32 # Assume square tiles

@onready var packedUnit = preload("res://Unit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.beat.connect(_on_beat)

func _on_beat_timeout():
	SignalBus.beat.emit()

func _on_beat():
	var unit: Unit = packedUnit.instantiate()
	unit.configure(tile_size)
	unit.set_starting(Vector2i(randi() % size.x, size.y-1), Vector2i.UP, randi() % 4, 0)
	unit.bearing = unit.facing
	add_child(unit)

	unit = packedUnit.instantiate()
	unit.configure(tile_size)
	unit.set_starting(Vector2i(0, randi() % size.y), Vector2i.RIGHT, randi() % 4, 1)
	unit.bearing = unit.facing
	add_child(unit)
