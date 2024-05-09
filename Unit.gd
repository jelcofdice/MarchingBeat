class_name Unit extends GridSprite

signal unit_created

@export var number: int = 0:
	set(value):
		number = value
		redraw_sprite()

@export var team: int = 0:
	set(value):
		team = value
		redraw_decal()

@export var facing := Vector2i.RIGHT:
	set(value):
		facing = value
		redraw_sprite()

var bearing: Vector2i = Vector2i.ZERO:
	set(value):
		bearing = value
		if bearing != Vector2i.ZERO:
			facing = bearing

func _ready():
	SignalBus.unit_created.emit(self)
	SignalBus.word_sent.connect(_on_word_sent)

func _on_word_sent(_team: int, _number: int, _bearing: Vector2i):
	if _team == team and _number == number:
		bearing = _bearing

func set_starting(_pos: Vector2i, _facing: Vector2i, _number: int, _team: int):
	pos = _pos
	facing = _facing
	number = _number 
	team = _team

func configure(_tile_size: int):
	tile_size = _tile_size
	# floor(2) removes int-division warning. Seems like a hack
	tile_draw_offset = Vector2(tile_size/floor(2), tile_size/floor(2))

func next_pos() -> Vector2i:
	return pos + bearing

func redraw_arrow():
	# The arrow rotation must be unaffected by unit rotation
	$Arrow.rotation = (number) * (PI / 2) - rotation

func redraw_decal():
	$Decal.self_modulate = Constants.team_colors[team]

func redraw_sprite():
	rotation = Vector2(facing).angle()
	redraw_arrow()
