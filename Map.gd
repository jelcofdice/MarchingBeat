extends TileMap
class_name Map

@export var grid_size := Vector2i(13, 10)
# TODO: Make tilemap and sprites scale with tile_size
@export var tile_size := 32 # Assume square tiles

@onready var packedUnit = preload("res://Unit.tscn")
@onready var packedContest = preload("res://Contest.tscn")
@onready var packedCity = preload("res://City.tscn")
@onready var packedController = preload("res://controller.tscn")

var demo: bool = true
var n_players: int
var scores: GameScore

class PlayerScore_:
    var marginal: int = 0
    var total: int = 0

class GameScore:
    var players: Array[PlayerScore_]
    var victory_condition: int

    func reset(n_players_: int) -> void:
        for i in range(n_players_):
            players.append(PlayerScore_.new())
        victory_condition = Constants.minimum_victory_condition

    func update_victory_condition():
        var sorted_scores: Array[int] = []
        for i in range(len(players)):
            sorted_scores.append(players[i].marginal)
        sorted_scores.sort()
        var marginal_condition := sorted_scores[-2] + Constants.victory_margin
        victory_condition = max(Constants.minimum_victory_condition, marginal_condition)

    func check_victory():
        for i in range(len(players)):
            if players[i].marginal >= victory_condition:
                SignalBus.victory.emit(i)

func _ready():
    SignalBus.half_beat.connect(_on_half_beat)
    SignalBus.new_contest.connect(_on_new_contest)
    SignalBus.post_beat.connect(_on_post_beat)
    _set_init_state()
    resize_window()

    # FIXME: Don't block main thread like this, this is only for testing
    await get_tree().create_timer(0.5).timeout
    $HalfBeat.start(1.0)

func _on_beat_timeout():
    SignalBus.beat.emit()
    SignalBus.post_beat.emit()

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

func _on_post_beat():
    calculate_scores()
    SignalBus.new_scores.emit(scores)

func calculate_scores():
    # Scoring logic is as follows:
    # 1. The player with most cities gets 1 point for each city they have more than
    # the second player
    # 2. We also track how many "points" are collected if everyone just gets on point
    # for every city they have
    var round_scores: Array[int] = []
    for i in range(n_players):
        round_scores.append(0)

    for child in get_children():
        if child is City:
            var team: int = child.team
            if team != -1:
                round_scores[team] += 1

    var sorted_scores: Array[int] = round_scores.duplicate()
    sorted_scores.sort()
    var threshold: int = sorted_scores[-2]

    for i in range(n_players):
        var marginal: int = max(0, round_scores[i] - threshold)
        scores.players[i].marginal += marginal
        scores.players[i].total += round_scores[i]

    scores.update_victory_condition()
    scores.check_victory()


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
    
    n_players = i_player

    for city in data["nodes"]:
        add_city(Vector2i(city[0], city[1]))

    reset_scores()

    resize_window()

func resize_window():
    $GridOutline.size = grid_size * tile_size
    $Grid.grid_size = grid_size
    var viewport_size: Vector2i = Vector2i(grid_size.x, grid_size.y+2) * tile_size
    get_viewport().size = viewport_size
    $HUD.size = viewport_size

func reset_scores():
    scores = GameScore.new()
    scores.reset(n_players)