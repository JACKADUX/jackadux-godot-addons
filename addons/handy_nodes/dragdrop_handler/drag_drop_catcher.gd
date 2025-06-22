class_name DragDropCatcher extends Control

@export var agent :Control
@export var drag_group_name := ""


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not agent:
		agent = get_parent()
	
func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN:
		var data = get_viewport().gui_get_drag_data()
		if data is not DragDropData:
			return 
		if drag_group_name and data.get_drag_group_name() != drag_group_name:
			return 
		mouse_filter = Control.MOUSE_FILTER_PASS
	elif what == NOTIFICATION_DRAG_END:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
