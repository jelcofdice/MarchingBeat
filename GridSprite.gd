class_name GridSprite extends Sprite2D

@export var pos: Vector2i = Vector2i.ZERO:
	set(value):
		pos = value
		redraw_position()

var tile_size: int = 32
var tile_draw_offset: Vector2i = Vector2(16, 16)

func redraw_position():
	position = (pos * tile_size) + tile_draw_offset

func configure(_tile_size: int):
	tile_size = _tile_size
	tile_draw_offset = Vector2(tile_size/2, tile_size/2)
