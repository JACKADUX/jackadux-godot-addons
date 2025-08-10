class_name DragDropCatcher extends Control

@export var drop_control :Control
@export var token := ""

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not drop_control:
		drop_control = get_parent()
	var can_drop_fn = can_drop_data.bind(drop_control)
	var drop_fn = drop_data.bind(drop_control)
	set_drag_forwarding(Callable(), can_drop_fn, drop_fn)
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN:
		var data = get_viewport().gui_get_drag_data()
		if data is not DragDropData:
			return 
		if data.get_token() != token:
			return 
		mouse_filter = Control.MOUSE_FILTER_PASS
	elif what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

static func can_drop_data(at_position:Vector2, dragdrop_data:Variant , p_drop_control:Control) -> bool:
	if dragdrop_data is not DragDropData:
		return false
	return dragdrop_data.can_drop(at_position, p_drop_control)

static func drop_data(at_position:Vector2, dragdrop_data:Variant, p_drop_control:Control):
	if dragdrop_data is not DragDropData:
		return 
	dragdrop_data.drop(at_position, p_drop_control)
	
	
