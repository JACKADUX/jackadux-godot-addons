class_name InputMapUtils


static func action_add_event(action_name:String, event:InputEvent):
	InputMap.add_action(action_name)
	InputMap.action_add_event(action_name, event)

static func action_add_event_key(action_name:String, key:Key):
	action_add_event(action_name, new_event_key(key))

static func new_event_key(key:Key) -> InputEventKey:
	var event_key = InputEventKey.new()
	event_key.physical_keycode = key
	return event_key
