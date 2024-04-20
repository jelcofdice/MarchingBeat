class_name Grid extends Node

@export var size := Vector2i(11, 7)
@export var tile_size := 24 # Assume square tiles

var top_left := Vector2i(0, 0)
var bottom_right := size
var units: Array[Unit]
var pending_moves: Array[Unit] # unit
var confirmed_moves: Dictionary # unit -> position

enum _status {PENDING, BLOCKED, MOVED}

class _Move:
	var unit: Unit
	var next: Vector2i
	var status: _status

func _init() -> void:
	SignalBus.unit_created.connect(_on_unit_created)
	SignalBus.beat.connect(_on_beat)

func _on_unit_created(unit: Unit) -> void:
	var team := unit.team
	var number := unit.number
	for u: Unit in units:
		if u.team == team and u.number == number:
			push_warning("Duplicate unit created: {team}, {number}".format({"team": team, "number": number}))
	print("Adding unit to grid: {team}, {number}".format({"team": team, "number": number}))
	units.append(unit)

func _on_beat() -> void:
	get_moves()
	resolve_moves()
	dispatch_moves()

func get_moves() -> void:
	for unit in units:
		if unit.bearing != Vector2i.ZERO:
			pending_moves.append(unit)
			print("Unit %s wants to move from %s to %s", str(unit.number), str(unit.pos), str(unit.next_pos))

# resolve_moves will contain the logic to determine which moves are legal
# Units which are blocked will have their desired move returned to current pos
func resolve_moves():
	for unit in pending_moves:
		var new_pos: Vector2i = unit.next_pos()
		confirmed_moves[unit] = new_pos.clamp(top_left, bottom_right)

func dispatch_moves():
	for unit in confirmed_moves:
		var new_pos = pending_moves[unit]
		if new_pos == unit.pos:
			unit.bearing = Vector2i.ZERO
		else:
			unit.pos = new_pos
	confirmed_moves = {}

# "pos" means location in grid index.
# coordintaes means pixel coordinates.
func pos_to_coordinates(loc: Vector2i) -> Vector2i:
	return loc * tile_size
