extends TileMap

@export var size := Vector2i(13, 10)
# TODO: Make tilemap and sprites scale with tile_size
@export var tile_size := 32 # Assume square tiles

@onready var packedUnit = preload("res://Unit.tscn")
@onready var packedContest = preload("res://Contest.tscn")
@onready var packedCity = preload("res://City.tscn")

func _ready():
	SignalBus.beat.connect(_on_beat)
	SignalBus.new_contest.connect(_on_new_contest)
	get_viewport().size = size * tile_size
	_set_init_state()

func _on_beat_timeout():
	SignalBus.beat.emit()

func _on_beat():
	add_unit(Vector2i(randi() % size.x, size.y-1), Vector2i.UP, randi() % 4, 0)
	add_unit(Vector2i(0, randi() % size.y), Vector2i.RIGHT, randi() % 4, 1)


func _set_init_state():
	# Test case: Units trying to pass through each other
	add_unit(Vector2i(2, 0), Vector2i.RIGHT, randi() % 4, 0)
	add_unit(Vector2i(9, 0), Vector2i.LEFT, randi() % 4, 1)

	# Test case: Units creating a conflict
	add_unit(Vector2i(4, 1), Vector2i.RIGHT, randi() % 4, 0)
	add_unit(Vector2i(8, 1), Vector2i.LEFT, randi() % 4, 1)

	# Bug showcase: A unit can pass through a unit which got blocked by contest this turn
	add_unit(Vector2i(6, 4), Vector2i.RIGHT, 0, 0)
	add_unit(Vector2i(8, 6), Vector2i.UP, 0, 1)
	add_unit(Vector2i(5, 4), Vector2i.RIGHT, 1, 0)
	add_unit(Vector2i(4, 4), Vector2i.RIGHT, 2, 0)

	# Test: Add some cities that can be captured
	add_city(Vector2i(7,0))
	add_city(Vector2i(6,3))
	add_city(Vector2i(2,3))
	add_city(Vector2i(3,1))

func _on_new_contest(pos: Vector2i):
	var contest: Contest = packedContest.instantiate()
	contest.configure(tile_size)
	contest.pos = pos
	add_child(contest)

func add_unit(pos: Vector2i, facing: Vector2i, number: int, team: int):
	var unit: Unit = packedUnit.instantiate()
	unit.configure(tile_size)
	unit.set_starting(pos, facing, number, team)
	unit.bearing = unit.facing
	add_child(unit)

func add_city(pos: Vector2i):
	var city: City = packedCity.instantiate()
	city.configure(tile_size)
	city.pos = pos
	add_child(city)