extends TileMap

@export var size := Vector2i(13, 10)
@export var tile_size := 32 # Assume square tiles

@onready var packedUnit = preload("res://Unit.tscn")

func _ready():
	SignalBus.beat.connect(_on_beat)
	get_viewport().size = size * tile_size
	_set_init_state()

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

func _set_init_state():
	var unit: Unit = packedUnit.instantiate()
	unit.configure(tile_size)
	unit.set_starting(Vector2i(2, 0), Vector2i.RIGHT, randi() % 4, 0)
	unit.bearing = unit.facing
	add_child(unit)

	unit = packedUnit.instantiate()
	unit.configure(tile_size)
	unit.set_starting(Vector2i(9, 0), Vector2i.LEFT, randi() % 4, 1)
	unit.bearing = unit.facing
	add_child(unit)