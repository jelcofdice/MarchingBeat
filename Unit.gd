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
		if bearing != Vector2i.ZERO:
			facing = bearing


var grid_size: int = 16

func _ready():
	SignalBus.unit_created.emit(self)

func set_starting(_pos: Vector2i, _facing: Vector2i, _number: int, _team: int):
	pos = _pos
	facing = _facing
	number = _number
	team = _team

# next_move returns where 
func next_pos() -> Vector2i:
	return pos + bearing

func redraw_arrow():
	$Arrow.rotation = PI * (number-1) / 2

func redraw_decal():
	$Decal.self_modulate = Constants.team_colors[team]

func redraw_sprite():
	rotation = Vector2(facing).angle()

func redraw_position():
	position = pos * grid_size