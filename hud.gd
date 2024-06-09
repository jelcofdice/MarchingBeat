extends Control
var grid_size: Vector2i = Vector2i(13, 10)
var tile_size: int = 32

const color_1: Color = Color(0.0, 0.0, 0.0)
const color_2: Color = Color(1.0, 1.0, 1.0)
var even: bool = true


func _ready():
    SignalBus.beat.connect(_on_beat)
    SignalBus.new_scores.connect(_on_new_scores)
    SignalBus.victory.connect(_on_victory)

func _on_victory(winner: int) -> void:
    print('Player ' + str(winner) + ' wins!')

func _on_beat():
    if even:
        $BeatIndicatorLeft.color = color_1
        $BeatIndicatorRight.color = color_2
    else:
        $BeatIndicatorLeft.color = color_2
        $BeatIndicatorRight.color = color_1
    even = !even

func _on_resized():
    pass

func _on_new_scores(scores: Array[Map.PlayerScore_]) -> void:
    $ScoreCard.text = str(scores[0].marginal) + '(' + str(scores[0].total) + ')'
    $ScoreCard2.text = str(scores[1].marginal) + '(' + str(scores[1].total) + ')'

func set_tile_size(value: int) -> void:
    tile_size = value
    for child in get_children():
        if child is Controller:
            child.set_tile_size(tile_size)
        elif child is ColorRect: # BeatIndicators
            child.size = tile_size
        elif child is Label: # Scorecards
            child.anchor_offsets.top = -tile_size
    $ScoreCard.anchor_offsets.left = 4.5 * tile_size
    $ScoreCard.anchor_offsets.right = 6.5 * tile_size
    $ScoreCard2.anchor_offset.right = -4.5 * tile_size
    $ScoreCard2.anchor_offset.left = -6.5 * tile_size
