extends Node

func run() -> bool:
	print("Starting Contest Logic Test...")
	
	# Setup Grid
	# Grid connects to signals in _init, so it should be ready to listen.
	var grid = load("res://Grid.gd").new()
	add_child(grid)
	
	# Setup Units
	var unit_scene = load("res://Unit.tscn")
	
	# Unit 1: (0,0) moving Right (1,0) -> Target (1,0)
	var unit1 = unit_scene.instantiate()
	unit1.pos = Vector2i(0, 0)
	unit1.facing = Vector2i(1, 0)
	unit1.bearing = Vector2i(1, 0)
	unit1.team = 0
	unit1.number = 0
	
	# Unit 2: (2,0) moving Left (-1,0) -> Target (1,0)
	var unit2 = unit_scene.instantiate()
	unit2.pos = Vector2i(2, 0)
	unit2.facing = Vector2i(-1, 0)
	unit2.bearing = Vector2i(-1, 0)
	unit2.team = 1
	unit2.number = 0
	
	# Add units to tree so they emit 'unit_created' and Grid sees them
	add_child(unit1)
	add_child(unit2)
	
	# Wait for signals to propagate
	await get_tree().process_frame
	
	# Trigger Beat
	SignalBus.beat.emit()
	
	# Wait for signal processing
	await get_tree().process_frame
	
	# Verify
	var passed = true
	
	# 1. Units should not have moved
	if unit1.pos != Vector2i(0, 0):
		print("FAIL: Unit 1 moved to ", unit1.pos)
		passed = false
	
	if unit2.pos != Vector2i(2, 0):
		print("FAIL: Unit 2 moved to ", unit2.pos)
		passed = false
		
	# 2. Contest should be detected
	if grid.contests.size() != 1:
		print("FAIL: Expected 1 contest, found ", grid.contests.size())
		passed = false
	elif grid.contests[0] != Vector2i(1, 0):
		print("FAIL: Contest at wrong position ", grid.contests[0])
		passed = false
		
	if passed:
		print("PASS: Contest logic verified")
		return true
	else:
		return false
