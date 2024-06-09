extends Control
var grid_size: Vector2i = Vector2i(13, 10)
var tile_size: int = 32

const color_1: Color = Color(0.0, 0.0, 0.0)
const color_2: Color = Color(1.0, 1.0, 1.0)
var even: bool = true

@onready var beat_indicator_left: ColorRect = $BottomBar.get_node("VisualBeatIndicator").get_node("BeatIndicatorLeft")
@onready var beat_indicator_right: ColorRect = $BottomBar.get_node("VisualBeatIndicator").get_node("BeatIndicatorRight")
@onready var score_cards: Array[Label] = [
    $BottomBar.get_node("ScoreCard"),
    $BottomBar.get_node("ScoreCard2")
]
@onready var victory_condition_label: Label = $BottomBar.get_node("VictoryCondition")

func _ready():
    SignalBus.beat.connect(_on_beat)
    SignalBus.new_scores.connect(_on_new_scores)
    SignalBus.victory.connect(_on_victory)

func _on_victory(winner: int) -> void:
    print('Player ' + str(winner) + ' wins!')

func _on_beat():
    if even:
        beat_indicator_left.color = color_1
        beat_indicator_right.color = color_2
    else:
        beat_indicator_left.color = color_2
        beat_indicator_right.color = color_1
    even = !even

func _on_resized():
    pass

func _on_new_scores(scores: Map.GameScore) -> void:
    for i in range(2):
        score_cards[i].text = str(scores.players[i].marginal) + '(' + str(scores.players[i].total) + ')'
    victory_condition_label.text = "Victory Condition: " + str(scores.victory_condition)

func set_tile_size(value: int) -> void:
    tile_size = value
    for child in get_children():
        if child is Controller:
            child.set_tile_size(tile_size)
        elif child is ColorRect: # BeatIndicators
            child.size = tile_size
        elif child is Label: # Scorecards
            child.anchor_offsets.top = -tile_size
    score_cards[0].anchor_offsets.left = 4.5 * tile_size
    score_cards[0].anchor_offsets.right = 6.5 * tile_size
    score_cards[1].anchor_offset.right = -4.5 * tile_size
    score_cards[1].anchor_offset.left = -6.5 * tile_size
