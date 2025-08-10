class_name DragDropData
@warning_ignore_start("unused_parameter")
var _drag_control:Control
var _token:String

func _to_string() -> String:
	return "DragDropData::%s"%get_token()

func get_token()->String:
	return _token
	
func get_drag_control() -> Control:
	return _drag_control

## OVERRID
func get_drag(position:Vector2, drag_control:Control) -> bool:
	# NOTE: 返回false取消拖拽 
	return true
## OVERRID
func can_drop(position:Vector2, drop_control:Control) -> bool:
	return false
## OVERRID
func drop(position:Vector2, drop_control:Control):
	pass
## OVERRID
func make_preview(drag_control:Control):
	var copy :Control= drag_control.duplicate(Node.DUPLICATE_USE_INSTANTIATION)
	#copy.modulate.a = 0.5
	copy.scale *= 0.5
	drag_control.set_drag_preview(copy)


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
