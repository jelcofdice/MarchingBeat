@tool
class_name Unit
extends Sprite2D

signal unit_created

@export var number: int = 0:
	set(value):
		number = value
		redraw_arrow()

@export var team: int = 0:
	set(value):
		team = value
		redraw_decal()

@export var facing := Vector2i.RIGHT:
	set(value):
		facing = value
		redraw_sprite()

var pos: Vector2i = Vector2i.ZERO:
	set(value):
		pos = value

		redraw_position()

var bearing: Vector2i = Vector2i.ZERO:
	set(value):
		bearing = value
		print("Unit: ", team, number, ", bearing: ", bearing)
		if bearing != Vector2i.ZERO:
			facing = bearing


var tile_size: int = 16
var tile_draw_offset: Vector2i = Vector2(8, 8)

func _ready():
	SignalBus.unit_created.emit(self)
	var parent := get_parent()
	if parent is Object and "tile_size" in parent:
		tile_size = parent.tile_size
		tile_draw_offset = Vector2(tile_size/2, tile_size/2)

func set_starting(_pos: Vector2i, _facing: Vector2i, _number: int, _team: int):
	pos = _pos
	facing = _facing
	number = _number
	team = _team

func next_pos() -> Vector2i:
	return pos + bearing

func execute_move() -> void:
	pos = next_pos()

func redraw_arrow():
	$Arrow.rotation = PI * (number-1) / 2

func redraw_decal():
	$Decal.self_modulate = Constants.team_colors[team]

func redraw_sprite():
	rotation = Vector2(facing).angle()

func redraw_position():
	position = (pos * tile_size) + tile_draw_offset
