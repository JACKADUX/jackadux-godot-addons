class_name CanvasViewerIndicator extends Control

@export var canvas_viewer:CanvasViewer

func _ready() -> void:
	if not canvas_viewer:
		canvas_viewer = get_parent()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas_viewer.view_changed.connect(func(_zoom,_offset):
		on_view_changed()
	)
	
func on_view_changed():
	queue_redraw()

func get_canvas_xform() -> Transform2D:
	return canvas_viewer.camera_component.get_xform()

func get_zoom() -> float:
	return canvas_viewer.camera_component.view_zoom

func _draw() -> void:
	draw_set_transform_matrix(get_canvas_xform())
	_draw_indicator()

func _draw_indicator():
	pass
	
