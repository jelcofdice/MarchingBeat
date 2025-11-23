extends Node

func _ready():
	var dir = DirAccess.open("res://")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var exit_code = 0
		var tests_run = 0
		var tests_passed = 0
		
		print("---------------------------------------------------")
		print("Running Tests...")
		print("---------------------------------------------------")
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.begins_with("test_") and file_name.ends_with(".gd") and file_name != "TestRunner.gd":
				print("\n[TEST] Found test: " + file_name)
				var script = load("res://" + file_name)
				var test_instance = script.new()
				add_child(test_instance)
				
				# Wait a frame to ensure _ready is called and tree is stable if needed
				await get_tree().process_frame
				
				var result = await test_instance.run()
				tests_run += 1
				
				if result:
					tests_passed += 1
					print("[PASS] " + file_name)
				else:
					exit_code = 1
					print("[FAIL] " + file_name)
				
				test_instance.queue_free()
				
			file_name = dir.get_next()
			
		print("\n---------------------------------------------------")
		print("Summary: " + str(tests_passed) + "/" + str(tests_run) + " tests passed.")
		print("---------------------------------------------------")
		
		get_tree().quit(exit_code)
	else:
		print("An error occurred when trying to access the path.")
		get_tree().quit(1)
