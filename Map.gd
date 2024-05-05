extends TileMap

@export var size := Vector2i(13, 10)
# TODO: Make tilemap and sprites scale with tile_size
@export var tile_size := 32 # Assume square tiles

@onready var packedUnit = preload("res://Unit.tscn")
@onready var packedContest = preload("res://Contest.tscn")
@onready var packedCity = preload("res://City.tscn")

var demo: bool = true

func _ready():
	SignalBus.beat.connect(_on_beat)
	SignalBus.new_contest.connect(_on_new_contest)
	_set_init_state()
	resize_window()

func _on_beat_timeout():
	SignalBus.beat.emit()

func _on_beat():
	if demo:
		add_unit(Vector2i(randi() % size.x, size.y-1), Vector2i.UP, randi() % 4, 0)
		add_unit(Vector2i(0, randi() % size.y), Vector2i.RIGHT, randi() % 4, 1)

# When spacebar is pressed, load a new map
func _process(_delta):
	if Input.is_action_just_pressed("spacebar"):
		load_map("2player.json")
		demo = false


func _set_init_state():
	load_map("demo.json")
	# # Test case: Units trying to pass through each other
	# add_unit(Vector2i(2, 0), Vector2i.RIGHT, randi() % 4, 0)
	# add_unit(Vector2i(9, 0), Vector2i.LEFT, randi() % 4, 1)

	# # Test case: Units creating a conflict
	# add_unit(Vector2i(4, 1), Vector2i.RIGHT, randi() % 4, 0)
	# add_unit(Vector2i(8, 1), Vector2i.LEFT, randi() % 4, 1)

	# # Bug showcase: A unit can pass through a unit which got blocked by contest this turn
	# add_unit(Vector2i(6, 4), Vector2i.RIGHT, 0, 0)
	# add_unit(Vector2i(8, 6), Vector2i.UP, 0, 1)
	# add_unit(Vector2i(5, 4), Vector2i.RIGHT, 1, 0)
	# add_unit(Vector2i(4, 4), Vector2i.RIGHT, 2, 0)

	# # Test: Add some cities that can be captured
	# add_city(Vector2i(7,0))
	# add_city(Vector2i(6,3))
	# add_city(Vector2i(2,3))
	# add_city(Vector2i(3,1))

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

func clear_map():
	for child in get_children():
		if child is Unit:
			SignalBus.unit_deleted.emit(child)
			child.queue_free()
		elif child is Contest or child is City:
			child.queue_free()

func load_map(level_name: String):
	var path: String = "res://maps/levels/" + level_name
	clear_map()

	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	# Parse the JSON data
	var json = JSON.new()
	# I'm just going to assume it's ok, no error handling yet...
	json.parse(json_text) # var error = json.parse(json_text)
	var data = json.data
	size = Vector2i(data["size"][0], data["size"][1])

	# Process the loaded data
	var i_player: int = 0
	for player in data["units"]:
		var i_unit: int = 0
		for unit in player:
			var bearing := Vector2i(0, 0)
			if len(unit) > 2:
				bearing = Vector2i(unit[2], unit[3])
			add_unit(Vector2i(unit[0], unit[1]), bearing, i_unit, i_player)
			i_unit += 1
		i_player += 1

	for city in data["nodes"]:
		add_city(Vector2i(city[0], city[1]))
	
	resize_window()

func resize_window():
	$GridOutline.size = size * tile_size
	$Grid.size = size
	get_viewport().size = size * tile_size