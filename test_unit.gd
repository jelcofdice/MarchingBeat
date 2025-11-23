extends Node

func run() -> bool:
	print("Starting Unit test...")
	
	# Load the scene to ensure child nodes like $Arrow exist
	var unit_scene = load("res://Unit.tscn")
	var unit = unit_scene.instantiate()
	
	add_child(unit)
	
	# Test setup
	unit.pos = Vector2i(1, 1)
	unit.bearing = Vector2i(1, 0)
	
	# Execution
	var next = unit.next_pos()
	
	# Assertion
	if next == Vector2i(2, 1):
		print("PASS: next_pos calculation correct. Expected (2, 1), got ", next)
		return true
	else:
		print("FAIL: next_pos expected (2, 1) but got ", next)
		return false
