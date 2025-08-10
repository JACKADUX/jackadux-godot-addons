# class_name CanvasIndicator 
extends Control

const CanvasViewer = preload("canvas_viewer.gd")
@export var canvas_viewer:CanvasViewer

func _ready() -> void:
	if not canvas_viewer:
		canvas_viewer = get_parent()
	canvas_viewer.view_changed.connect(func(zo,of):
		queue_redraw()
	)

func _draw() -> void:
	var xform = canvas_viewer.camera_component.get_xform()
	var zoom = canvas_viewer.camera_component.view_zoom
	draw_set_transform_matrix(xform)
	_draw_indicator(zoom)

func _draw_indicator(zoom:float):
	pass
	
