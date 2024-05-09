extends TileMap

@export var grid_size := Vector2i(13, 10)
# TODO: Make tilemap and sprites scale with tile_size
@export var tile_size := 32 # Assume square tiles

@onready var packedUnit = preload("res://Unit.tscn")
@onready var packedContest = preload("res://Contest.tscn")
@onready var packedCity = preload("res://City.tscn")
@onready var packedController = preload("res://controller.tscn")

var demo: bool = true

func _ready():
	SignalBus.half_beat.connect(_on_half_beat)
	SignalBus.new_contest.connect(_on_new_contest)
	_set_init_state()
	resize_window()

	# FIXME: Don't block main thread like this, this is only for testing
	await get_tree().create_timer(0.5).timeout
	$HalfBeat.start(1.0)

func _on_beat_timeout():
	SignalBus.beat.emit()

func _on_half_beat_timeout():
	SignalBus.half_beat.emit()

func _on_half_beat():
	if demo:
		add_unit(Vector2i(randi() % grid_size.x, grid_size.y-1), Vector2i.UP, randi() % 4, 0)
		add_unit(Vector2i(0, randi() % grid_size.y), Vector2i.RIGHT, randi() % 4, 1)

# When spacebar is pressed, load a new map
func _process(_delta):
	if Input.is_action_just_pressed("spacebar"):
		load_map("2player.json")
		demo = false

func _set_init_state():
	load_map("demo.json")

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

	var json = JSON.new()
	# I'm just going to assume it's ok, no error handling yet...
	json.parse(json_text)
	var data = json.data
	grid_size = Vector2i(data["grid_size"][0], data["grid_size"][1])

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
	$GridOutline.size = grid_size * tile_size
	$Grid.grid_size = grid_size
	var viewport_size: Vector2i = Vector2i(grid_size.x, grid_size.y+1) * tile_size
	get_viewport().size = viewport_size
	$UIRoot.size = viewport_size