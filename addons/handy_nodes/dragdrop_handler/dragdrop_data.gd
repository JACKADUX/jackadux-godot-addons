class_name DragDropData

func _to_string() -> String:
	return "DragDropData"

func get_drag_group_name() -> String:
	# NOTE: 覆写方法，DragDropCatcher 对象可以根据该名字判定是否捕获拖拽
	return ""

func init_with(drag_control:Control) -> bool:
	make_preview(drag_control)
	return true

func can_drop(position:Vector2, drop_control:Control) -> bool:
	return false

func drop(position:Vector2, drop_control:Control):
	pass

func make_preview(drag_control:Control):
	var copy :Control= drag_control.duplicate(Node.DUPLICATE_USE_INSTANTIATION)
	#copy.modulate.a = 0.5
	copy.scale *= 0.5
	drag_control.set_drag_preview(copy)

static func get_drag_data(position:Vector2, drag_control:Control, dragdropdata_script:Script) -> DragDropData :
	var dragdata = dragdropdata_script.new()
	if not dragdata.init_with(drag_control):
		return 
	return dragdata

static func can_drop_data(position:Vector2, data:Variant , drop_control:Control) -> bool:
	if data is not DragDropData:
		return false
	return data.can_drop(position, drop_control)

static func drop_data(position:Vector2, data:Variant, drop_control:Control):
	if data is not DragDropData:
		return 
	data.drop(position, drop_control)
