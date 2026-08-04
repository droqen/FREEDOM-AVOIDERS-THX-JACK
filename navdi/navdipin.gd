extends Node

const DIR_R = &"right"
const DIR_L = &"left"
const DIR_D = &"down"
const DIR_U = &"up"

func _ready() -> void:
	setup_defaults()

func get_dpad() -> Vector2i:
	return Vector2i(
		(1 if Input.is_action_pressed(DIR_R) else 0)-
		(1 if Input.is_action_pressed(DIR_L) else 0),
		(1 if Input.is_action_pressed(DIR_D) else 0)-
		(1 if Input.is_action_pressed(DIR_U) else 0)
	)

func get_dpad_tap() -> Vector2i:
	return Vector2i(
		(1 if Input.is_action_just_pressed(DIR_R) else 0)-
		(1 if Input.is_action_just_pressed(DIR_L) else 0),
		(1 if Input.is_action_just_pressed(DIR_D) else 0)-
		(1 if Input.is_action_just_pressed(DIR_U) else 0)
	)

func get_action_hit() -> bool: return Input.is_action_just_pressed("action")
func get_action_held() -> bool: return Input.is_action_pressed("action")
func get_jump_hit() -> bool: return Input.is_action_just_pressed("jump")
func get_jump_held() -> bool: return Input.is_action_pressed("jump")
func get_offhand_hit() -> bool: return Input.is_action_just_pressed("offhand")
func get_offhand_held() -> bool: return Input.is_action_pressed("offhand")
func get_plant_hit() -> bool: return Input.is_action_just_pressed("plant")
func get_plant_held() -> bool: return Input.is_action_pressed("plant")
func get_cancel_hit() -> bool: return Input.is_action_just_pressed("cancel")
func get_cancel_held() -> bool: return Input.is_action_pressed("cancel")



func setup_defaults():
	setup_action_button(DIR_U,    [KEY_UP, KEY_W], [JOY_BUTTON_DPAD_UP], [JOY_AXIS_LEFT_Y], [-1])
	setup_action_button(DIR_L,  [KEY_LEFT, KEY_A], [JOY_BUTTON_DPAD_LEFT], [JOY_AXIS_LEFT_X], [-1])
	setup_action_button(DIR_D,  [KEY_DOWN, KEY_S], [JOY_BUTTON_DPAD_DOWN], [JOY_AXIS_LEFT_Y], [1])
	setup_action_button(DIR_R, [KEY_RIGHT, KEY_D], [JOY_BUTTON_DPAD_RIGHT], [JOY_AXIS_LEFT_X], [1])
	
	setup_action_button("jump",
		[	KEY_Z, KEY_C, KEY_SPACE, KEY_ENTER,
			KEY_UP, KEY_W, ], # jump incl UP
		[JOY_BUTTON_A], [JOY_AXIS_LEFT_Y], [-1])
	setup_action_button("action",
		[	KEY_Z, KEY_C, KEY_SPACE, KEY_ENTER, ],
		[JOY_BUTTON_A])
	setup_action_button("plant",
		[	KEY_X, KEY_V, KEY_SHIFT, KEY_TAB,
			KEY_DOWN, KEY_S, ], # plant incl DOWN
		[JOY_BUTTON_B], [JOY_AXIS_LEFT_Y], [1])
	setup_action_button("offhand",
		[	KEY_X, KEY_V, KEY_SHIFT, KEY_TAB, ],
		[JOY_BUTTON_B])
	
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
