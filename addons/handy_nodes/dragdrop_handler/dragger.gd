class_name Dragger extends Node

@export var drag_control: Control
@export var token:String
@export var dragdrop_data_gds : GDScript
	
func _ready() -> void:
	if not dragdrop_data_gds:
		printerr(self, ",dragdrop_data_gds不能为空")
		return 
	if not drag_control:
		drag_control = get_parent()
	var drag_fn = get_drag_data.bind(drag_control, self)
	drag_control.set_drag_forwarding(drag_fn, Callable(), Callable())

static func get_drag_data(at_position:Vector2, p_drag_control:Control, dragger:Dragger) -> DragDropData :
	var dragdata := dragger.dragdrop_data_gds.new() as DragDropData
	dragdata._token = dragger.token
	dragdata._drag_control = p_drag_control
	dragdata.make_preview(p_drag_control)
	if not dragdata.get_drag(at_position, p_drag_control):
		return 
	return dragdata
