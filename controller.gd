class_name Controller extends ColorRect

@export var team: int:
    set(value):
        team = value
        inputs = Constants.team_control_inputs[team]
        color_base = Constants.team_colors[team]
        color_highlight = Constants.team_colors[-1]

# "_word" is a sequence of inputs ("letters")
# The sequence should not clear immediately when emitted, but
# on the next beat, or as soon as another input is given
@export var _word: Array[int] = []

@export var tile_size: int = 32

var inputs: Dictionary
var is_listening: bool = true
var sent_word: bool = false

var _arrows: Array[TextureRect]

var color_base: Color
var color_highlight: Color

func _ready():
    SignalBus.half_beat.connect(_on_half_beat)
    SignalBus.beat.connect(_on_beat)
    team = 0
    for arrow in [$Arrow1, $Arrow2, $Arrow3, $Arrow4]:
        _arrows.append(arrow)

func _process(_delta):
    if is_listening:
        for input in inputs:
            if Input.is_action_just_pressed(input):
                register_input(inputs[input])
                break

func register_input(letter: int):
    is_listening = false
    if len(_word) == 2:
        _word = []
    _word.append(letter)
    if len(_word) == 2:
        color = color_highlight
    print("Word: ", _word)
    _redraw_arrows()

func _redraw_arrows():
    for i in range(len(_arrows)):
        if len(_word) > i:
            _arrows[i].modulate.a = 1
            _arrows[i].rotation = _word[i] * PI/2
        else:
            _arrows[i].modulate.a = 0

func _on_half_beat():
    is_listening = true
    if len(_word) == 2:
        if not sent_word:
            _send_word()
            sent_word = true
    else:
        sent_word = false

func _on_beat():
    color = color_base

func _send_word():
    print("Controller ", team, " sending word: ", _word)
    SignalBus.send_order.emit(team, _word[0], Constants.number_direction_map[_word[1]])
    _redraw_arrows()

func set_tile_size(new_tile_size: int):
    # Update size of display area and all children by setting new pixel size of tiles
    # Cannot be a setter because children aren't available when default value is set
    tile_size = new_tile_size
    var i = 0
    custom_minimum_size = Vector2(new_tile_size * 4, new_tile_size)
    for arrow in _arrows:
        arrow.size = Vector2(new_tile_size, new_tile_size)
        arrow.position = Vector2(i * new_tile_size + new_tile_size/2, new_tile_size/2)
        i += 1