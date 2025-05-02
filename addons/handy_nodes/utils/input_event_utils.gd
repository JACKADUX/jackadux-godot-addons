class_name InputEventUtils

static func is_mouse_support() -> bool:
	return OS.has_feature("editor") or OS.has_feature("windows")

static func is_touch_support() -> bool:
	return OS.has_feature("android")

static func is_pressed(event:InputEvent, index:int=-1) -> bool:
	if is_mouse_support():
		return event is InputEventMouseButton and event.is_pressed() and (event.button_index == index or index==-1)
	elif is_touch_support():
		return event is InputEventScreenTouch and event.is_pressed() and (event.index == index or index==-1)
	return false

static func is_released(event:InputEvent, index:int=-1) -> bool:
	if is_mouse_support():
		return event is InputEventMouseButton and event.is_released() and (event.button_index == index or index==-1)
	elif is_touch_support():
		return event is InputEventScreenTouch and event.is_released() and (event.index == index or index==-1)
	return false

static func is_dragged(event:InputEvent, index:int=-1) -> bool:
	if is_mouse_support():
		return event is InputEventMouseMotion and (event.button_mask == index or index == -1)
	elif is_touch_support():
		return event is InputEventScreenDrag and (event.index == index or index == -1)
	return false
	
static func get_event_global_position(event: InputEvent):
	if is_mouse_support():
		return event.global_position
	elif is_touch_support():
		return event.position
	return Vector2.ZERO
