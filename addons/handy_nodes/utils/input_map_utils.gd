class_name InputMapUtils

static func erase_action(action_name:String):
	if InputMap.has_action(action_name):
		InputMap.erase_action(action_name)

static func action_add_event(action_name:String, event:InputEvent):
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_add_event(action_name, event)

static func action_add_event_key(action_name:String, key:Key):
	action_add_event(action_name, new_event_key(key))

static func action_add_event_keys(action_name:String, keys:Array):
	for key in keys:
		action_add_event(action_name, new_event_key(key))

static func new_event_key(key:Key) -> InputEventKey:
	var event_key = InputEventKey.new()
	event_key.physical_keycode = key
	return event_key
	
static func action_add_event_mouse_button(action_name:String, button_index:MouseButton):
	action_add_event(action_name, new_event_mouse_button(button_index))

static func new_event_mouse_button(button_index:MouseButton) -> InputEventMouseButton:
	var event = InputEventMouseButton.new()
	event.button_index = button_index
	return event
