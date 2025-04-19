extends Control

signal drag_started
signal location_changed
signal drag_ended

enum Shape {
	NONE,
	CIRCLE,
	HRECT,
	VRECT,
}

@export var shape := Shape.NONE
@export var fill_color := Color.WHITE:
	set(v):
		fill_color = v
		queue_redraw()
		
@export var width :int = 6
@export var border :int = 1
@export var offset_factor :float= 1

var _pressed := false
var _location := Vector2.ZERO # 0~1.
var _start_pos
var _start_location

#---------------------------------------------------------------------------------------------------
func _ready():
	set_anchors_preset(Control.PRESET_FULL_RECT)
	focus_mode = FOCUS_CLICK
	
#---------------------------------------------------------------------------------------------------
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		_pressed = true
		_start_pos = event.global_position
		_start_location = _location
		drag_started.emit()
		
	elif event is InputEventMouseMotion and _pressed:
		var diff = event.global_position - _start_pos
		set_location(_start_location+Vector2(diff.x/size.x,diff.y/size.y)*offset_factor)
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released():
		if _pressed:
			set_location(_location)
			drag_ended.emit()
		_pressed = false
	
#---------------------------------------------------------------------------------------------------
func set_location(value:Vector2):
	_location = value.clamp(Vector2.ZERO, Vector2.ONE)
	location_changed.emit()
	queue_redraw()
	
#---------------------------------------------------------------------------------------------------
func get_location():
	return _location

#---------------------------------------------------------------------------------------------------
func _draw():
	match shape:
		Shape.CIRCLE:
			draw_circle(_location*size, width, Color.BLACK, false, border, true)
			draw_circle(_location*size, width-border, fill_color, true, -1, true)
		Shape.HRECT:
			var rect = Rect2(_location.x*size.x-width*0.5, 0, width, size.y)
			draw_rect(rect, Color.BLACK, false, border, true)
			draw_rect(rect.grow(-border), fill_color, true, -1, true)
		Shape.VRECT:
			var rect = Rect2(0, _location.y*size.y-width*0.5, size.x, width)
			draw_rect(rect, Color.BLACK, false, border, true)
			draw_rect(rect.grow(-border), fill_color, true, -1, true)
