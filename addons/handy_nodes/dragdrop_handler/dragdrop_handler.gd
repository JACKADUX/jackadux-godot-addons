class_name DragDropHandler extends Node

@export var dragdrop_node: Control
@export var drag_data : GDScript
@export var drop_data : GDScript

func _ready() -> void:
	if not dragdrop_node:
		dragdrop_node = get_parent()
	var drag_fn = drag_data.get_drag_data.bind(dragdrop_node, drag_data) if drag_data else Callable()
	var can_drop_fn = drop_data.can_drop_data.bind(dragdrop_node) if drop_data else Callable()
	var drop_fn = drop_data.drop_data.bind(dragdrop_node) if drop_data else Callable()
	dragdrop_node.set_drag_forwarding(drag_fn, can_drop_fn, drop_fn)

#func _notification(what: int) -> void:
	#if what == NOTIFICATION_DRAG_BEGIN:
		##var data = get_viewport().gui_get_drag_data()
		#pass
	#elif what == NOTIFICATION_DRAG_END:
		#pass

static func get_drop_index(control:Control) -> int:
	var pos = control.get_local_mouse_position()
	var index = 0
	if control is HBoxContainer:
		for child :Control in control.get_children():
			var center = child.position + child.size*0.5
			if center.x >= pos.x:
				return index
			index += 1
	return index
