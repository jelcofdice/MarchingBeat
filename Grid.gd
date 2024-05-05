class_name Grid extends Node

@export var size := Vector2i(11, 7)

enum _status {IDLE, PENDING, BLOCKED, ACCEPTED}

var top_left := Vector2i(0, 0)
var bottom_right: Vector2i:
	get:
		return top_left + size

var units: Array[Unit] = []
var move_statuses: Dictionary # unit -> _status
var desired_moves: Array[Vector2i]
var contests: Array[Vector2i] # Locations with contests. Should be drawn on map

func _init() -> void:
	SignalBus.unit_created.connect(_on_unit_created)
	SignalBus.unit_deleted.connect(_on_unit_deleted)
	SignalBus.beat.connect(_on_beat)

func _on_unit_created(unit: Unit) -> void:
	var team := unit.team
	var number := unit.number
	for u: Unit in units:
		if u.team == team and u.number == number:
			push_warning("Duplicate unit created: {team}, {number}".format({"team": team, "number": number}))
	print("Adding unit to grid: {team}, {number}".format({"team": team, "number": number}))
	units.append(unit)


func _on_unit_deleted(unit: Unit) -> void:
	if unit in units:
		units.erase(unit)
	else:
		push_warning("Failted to delete unit: Unit not found in grid: {team}, {number}".format({"team": unit.team, "number": unit.number}))

func _on_beat() -> void:
	move_statuses = {}
	contests = []
	desired_moves = []
	get_moves()
	resolve_moves()
	dispatch_moves()

func get_moves() -> void:
	for unit: Unit in units:
		if unit.bearing == Vector2i.ZERO:
			move_statuses[unit] = _status.IDLE
		else:
			move_statuses[unit] = _status.PENDING
			desired_moves.append(unit.next_pos())

# resolve_moves will contain the logic to determine which moves are legal
# Units which are blocked will have their desired move returned to current pos
func resolve_moves():
	var blocked_by_units := []

	# First, determine which moves are contested
	for move in desired_moves:
		if desired_moves.count(move) > 1 and move not in contests:
			contests.append(move)
			SignalBus.new_contest.emit(move)
	
	# Second, determine which moves are blocked by stationary objects

	for unit in move_statuses:
		var desired = unit.next_pos()
		if not Rect2(top_left, bottom_right).has_point(desired):
			# We don't change their bearing etc here, that's done in dispatch_moves
			move_statuses[unit] = _status.BLOCKED

		# TODO: Units blocked by terrain

		# Special case: If two units are about to walk through each other, block them both
		for unit2 in move_statuses:
			if unit != unit2 and desired == unit2.pos and unit2.next_pos() == unit.pos:
				move_statuses[unit] = _status.BLOCKED


	# Now we can mark all non-moving units as blocking
	for unit in move_statuses:
		if move_statuses[unit] in [_status.IDLE, _status.BLOCKED]:
			blocked_by_units.append(unit.pos)

	# And finally accept all moves not blocked by temporaries
	for unit: Unit in move_statuses:
		if move_statuses[unit] == _status.PENDING:
			var desired := unit.next_pos()
			if desired in contests:
				print("Unit {team}, {number} blocked by CONTEST at {desired}".format({"team": unit.team, "number": unit.number, "desired": desired}))
				move_statuses[unit] = _status.BLOCKED
			elif desired in blocked_by_units:
				print("Unit {team}, {number} blocked by STATIONARY UNIT at {desired}".format({"team": unit.team, "number": unit.number, "desired": desired}))
				move_statuses[unit] = _status.BLOCKED
			else:
				move_statuses[unit] = _status.ACCEPTED

	# There's edge cases where the above logic will make mistakes, but it's
	# good enough for initial testing
	# TODO: Add unit tests including tricky situations

func dispatch_moves():
	for unit in move_statuses:
		if move_statuses[unit] == _status.ACCEPTED:
			unit.execute_move()
		elif move_statuses[unit] == _status.BLOCKED:
			unit.bearing = Vector2i.ZERO
