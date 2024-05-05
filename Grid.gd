class_name Grid extends Node

@export var size := Vector2i(11, 7)

enum _status {IDLE, PENDING, BLOCKED, ACCEPTED}

var top_left := Vector2i(0, 0)
var bottom_right: Vector2i:
	get:
		return top_left + size

var units: Array[Unit] = []
var move_statuses: Dictionary # unit -> _status

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
	get_moves()
	resolve_moves()
	dispatch_moves()

func get_moves() -> void:
	for unit: Unit in units:
		if unit.bearing == Vector2i.ZERO:
			move_statuses[unit] = _status.IDLE
		else:
			move_statuses[unit] = _status.PENDING

# resolve_moves will contain the logic to determine which moves are legal
# Units which are blocked will have their desired move returned to current pos
func resolve_moves():
	"""Order of evaluation:
		1. Find units which are obviously blocked, and mark them as such
			- Blocked by map boundaries
			- Blocked attempting to walk through other unit
			- Blocked by stationary unit
		2. Find which squares are contested by two non-blocked units
		3. Mark units trying to move to contested squares as blocked
		4. Repeat (1) in case a unit is now blocked by a unit blocked by contests
		5. Accept all moves not blocked by any of the above steps

		# TODO: There are edge cases the above logic doesn't handle, specifically chained contests
		Since there is only one pass over contests, one contest can never affect whether another contest
		will happen.

		# TODO: Refactor move_statuses into 2 lists of pending and blocked units
	"""
	while find_next_blocked_units():
		pass

	find_contests()
	
	while find_next_blocked_units():
		pass
	
	for unit: Unit in move_statuses:
		if move_statuses[unit] == _status.PENDING:
			move_statuses[unit] = _status.ACCEPTED

	# There's edge cases where the above logic will make mistakes, but it's
	# good enough for initial testing
	# TODO: Add unit tests including tricky situations

func find_next_blocked_units() -> int:
	"""Iterates through all units and checks if they are obviously blocked.
	    Marks blocked units, and returns the number of new units marked as blocked.
		Since a unit being blocked may affect another unit previously passed in the loop,
		this function should be called repeatedly until it returns 0
	"""
	var n_new: int = 0
	for unit in move_statuses:
		if move_statuses[unit] != _status.PENDING:
			continue
		# If units desired location is blocked, mark it as blocked
		var desired = unit.next_pos()
		if not Rect2(top_left, bottom_right).has_point(desired):
			move_statuses[unit] = _status.BLOCKED
			n_new += 1

		# Special case: If two units are about to walk through each other, block them both
		for unit2 in move_statuses:
			if unit != unit2 and desired == unit2.pos:
				if unit2.next_pos() == unit.pos or move_statuses[unit2] in [_status.BLOCKED, _status.IDLE]:
					move_statuses[unit] = _status.BLOCKED
					print("Unit {team}, {number} blocked by other UNIT at {desired}".format({"team": unit.team, "number": unit.number, "desired": desired}))
					n_new += 1
	return n_new

func find_contests() -> int:
	"""Uterates through all unit statuses and finds contests
		Emits new_contest signal for each new contest
		Marks any unit trying to move into a contested area as blocked
		Returns the number of new units marked as blocked"""
	var desired_moves: Array[Vector2i] = []
	for unit: Unit in move_statuses:
		if move_statuses[unit] == _status.PENDING:
			desired_moves.append(unit.next_pos())

	for move in desired_moves:
		if desired_moves.count(move) > 1 and move not in contests:
			contests.append(move)
			SignalBus.new_contest.emit(move)
	
	var n_new: int = 0
	for unit: Unit in move_statuses:
		if move_statuses[unit] == _status.PENDING and unit.next_pos() in contests:
			move_statuses[unit] = _status.BLOCKED
			print("Unit {team}, {number} blocked by CONTEST at {desired}".format({"team": unit.team, "number": unit.number, "desired": unit.next_pos()}))

	return n_new

func dispatch_moves():
	for unit in move_statuses:
		if move_statuses[unit] == _status.ACCEPTED:
			unit.execute_move()
		elif move_statuses[unit] == _status.BLOCKED:
			unit.bearing = Vector2i.ZERO
