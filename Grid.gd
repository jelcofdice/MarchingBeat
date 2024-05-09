class_name Grid extends Node

@export var size := Vector2i(11, 7)

enum _status {IDLE, PENDING, BLOCKED, ACCEPTED}

var top_left := Vector2i(0, 0)
var bottom_right: Vector2i:
	get:
		return top_left + size

var units: Array[Unit] = []

var pending: Array[Unit]
var blocked: Array[Unit]
var pos_unit_map: Dictionary # [Vector2i -> Unit]

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
	units.append(unit)

func _on_unit_deleted(unit: Unit) -> void:
	if unit in units:
		units.erase(unit)
	else:
		push_warning("Failted to delete unit: Unit not found in grid: {team}, {number}".format({"team": unit.team, "number": unit.number}))

func _on_beat() -> void:
	contests = []
	pending = []
	blocked = []
	pos_unit_map = {}
	get_moves()
	resolve_moves()
	dispatch_moves()

func get_moves() -> void:
	for unit: Unit in units:
		pos_unit_map[unit.pos] = unit
		if unit.bearing != Vector2i.ZERO:
			pending.append(unit)

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

		# BUG: There are edge cases the above logic doesn't handle, specifically chained contests
		Since there is only one pass over contests, one contest can never affect whether another contest
		will happen.
	"""
	while find_next_blocked_units():
		pass

	find_contests()
	
	while find_next_blocked_units():
		pass

func find_next_blocked_units() -> int:
	"""Iterates through all units and checks if they are obviously blocked.
	    Marks blocked units, and returns the number of new units marked as blocked.
		Since a unit being blocked may affect another unit previously passed in the loop,
		this function should be called repeatedly until it returns 0
	"""
	var new_blocked: Array[Unit] = []

	for unit: Unit in pending:
		var desired = unit.next_pos()
		if not Rect2(top_left, bottom_right).has_point(desired):
			new_blocked.append(unit)
		elif desired in pos_unit_map:
			var other = pos_unit_map[desired]
			# If other.next_pos==unit.pos, they're trying to go through each other
			if other not in pending or other.next_pos() == unit.pos:
				new_blocked.append(unit)

	for unit: Unit in new_blocked:
		pending.erase(unit)
		blocked.append(unit)

	return len(new_blocked)

func find_contests() -> int:
	"""Uterates through all unit statuses and finds contests
		Emits new_contest signal for each new contest
		Marks any unit trying to move into a contested area as blocked
		Returns the number of new units marked as blocked"""
	var desired_moves: Array[Vector2i] = []
	for unit: Unit in pending:
		desired_moves.append(unit.next_pos())

	for move in desired_moves:
		if desired_moves.count(move) > 1 and move not in contests:
			contests.append(move)
			SignalBus.new_contest.emit(move)

	var new_blocked: Array[Unit] = []
	for unit: Unit in pending:
		if unit.next_pos() in contests:
			new_blocked.append(unit)
			print("Unit {team}, {number} blocked by CONTEST at {desired}".format(
				{"team": unit.team, "number": unit.number, "desired": unit.next_pos()})
			)
	
	for unit: Unit in new_blocked:
		pending.erase(unit)
		blocked.append(unit)

	return len(new_blocked)

func dispatch_moves():
	for unit in pending:
		unit.execute_move()
	for unit in blocked:
		if unit.bearing != Vector2i.ZERO:
			unit.bearing = Vector2i.ZERO
