@tool
extends EditorScript

func _run() -> void:
	# press Shift + Cmd + X
	setup_action_button("up",    [KEY_UP, KEY_W], [JOY_BUTTON_DPAD_UP], [JOY_AXIS_LEFT_Y], [-1])
	setup_action_button("left",  [KEY_LEFT, KEY_A], [JOY_BUTTON_DPAD_LEFT], [JOY_AXIS_LEFT_X], [-1])
	setup_action_button("down",  [KEY_DOWN, KEY_S], [JOY_BUTTON_DPAD_DOWN], [JOY_AXIS_LEFT_Y], [1])
	setup_action_button("right", [KEY_RIGHT, KEY_D], [JOY_BUTTON_DPAD_RIGHT], [JOY_AXIS_LEFT_X], [1])
	
	setup_action_button("jump", [KEY_UP, KEY_W, KEY_Z, KEY_SPACE, KEY_ENTER],
		[JOY_BUTTON_A], [JOY_AXIS_LEFT_Y], [-1])
	setup_action_button("plant", [KEY_DOWN, KEY_S, KEY_X],
		[JOY_BUTTON_B], [JOY_AXIS_LEFT_Y], [1])
	setup_action_button("action", [KEY_Z, KEY_X, KEY_SPACE, KEY_ENTER], [JOY_BUTTON_A, JOY_BUTTON_B])
	setup_action_button("cancel", [KEY_ESCAPE, KEY_BACKSPACE], [JOY_BUTTON_BACK, JOY_BUTTON_START])
	
func setup_action_button(action_name : String, keycodes : Array[Key], joybuttonz : Array[JoyButton], joyaxez : Array[JoyAxis] = [], joyaxisdirections : Array[int] = []):
	if InputMap.has_action(action_name):
		push_error("Action already exists: "+action_name+". Please delete it first.")
	else:
		InputMap.add_action(action_name)
		for kc in keycodes:
			var event = InputEventKey.new()
			event.physical_keycode = kc
			InputMap.action_add_event(action_name, event)
		
		for jb in joybuttonz:
			var event = InputEventJoypadButton.new()
			event.button_index = jb
			InputMap.action_add_event(action_name, event)
		
		for i in len(joyaxez):
			var ja = joyaxez [i]
			var dir = joyaxisdirections [i]
			var event = InputEventJoypadMotion.new()
			event.axis = ja
			event.axis_value = dir
			InputMap.action_add_event(action_name, event)
		print("Added action: "+action_name+".")
