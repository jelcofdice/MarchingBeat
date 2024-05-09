extends Control
var grid_size: Vector2i = Vector2i(13, 10)
var tile_size: int = 32

const color_1: Color = Color(0.0, 0.0, 0.0)
const color_2: Color = Color(1.0, 1.0, 1.0)
var even: bool = true

func _ready():
    SignalBus.beat.connect(_on_beat)

func _on_beat():
    if even:
        $BeatIndicatorLeft.color = color_1
        $BeatIndicatorRight.color = color_2
    else:
        $BeatIndicatorLeft.color = color_2
        $BeatIndicatorRight.color = color_1
    even = !even

func set_tile_size(value: int) -> void:
    tile_size = value
    for child in get_children():
        if child is Controller:
            child.set_tile_size(tile_size)
        else: # BeatIndicators
            child.size = tile_size

func _on_resized():
    pass