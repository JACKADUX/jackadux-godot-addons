class_name MouseInputData

var _dt = 0
var _dpos = Vector2.ZERO
var _drag_duration = 0.2
var _drag_length = 5
var _viewport : Viewport

var start_position: Vector2
var end_position: Vector2
var relative : Vector2
var pressed:=false
var dragging:= false
var draged:= false
var real_dragging := false # 附带条件的拖拽，比如拖拽长度或者时长限制
var real_draged:= false
var double_clicked := false
var button_index:= MOUSE_BUTTON_NONE
var event:InputEvent
var alt_pressed := false
var command_or_control_autoremap := false
var ctrl_pressed := false
var meta_pressed := false
var shift_pressed := false
var zoom:float = 1

func _to_string() -> String:
	return JSON.stringify({
		"start_position":start_position,
		"end_position":end_position,
		"relative":relative,
		"pressed":pressed,
		"draged":draged,
		"real_draged":real_draged,
		"double_clicked":double_clicked,
		"button_index":button_index,
	})

func set_input_as_handled():
	clear()
	_viewport.set_input_as_handled()

func get_offset() -> Vector2:
	return end_position-start_position

## MOUSE
func is_mouse_hover() -> bool:
	return button_index == MOUSE_BUTTON_NONE
	
func is_mouse_left() -> bool:
	return button_index == MOUSE_BUTTON_LEFT

func is_mouse_right() -> bool:
	return button_index == MOUSE_BUTTON_RIGHT

func is_mouse_middle() -> bool:
	return button_index == MOUSE_BUTTON_MIDDLE

func is_mouse_wheel_up() -> bool:
	return button_index == MOUSE_BUTTON_WHEEL_UP

func is_mouse_wheel_down() -> bool:
	return button_index == MOUSE_BUTTON_WHEEL_DOWN

## Press
func is_just_pressed() -> bool:
	return pressed and not dragging

func is_released() -> bool:
	return not pressed

func is_dragging() -> bool:
	return dragging
	
func is_real_dragging() -> bool:
	return real_dragging

func was_draged() -> bool:
	# NOTE: 在released 之前发生过拖拽
	return draged

func was_real_draged() -> bool:
	# NOTE: 在released 之前发生过真实拖拽
	return real_draged

## Utils
func clear():
	start_position= Vector2.ZERO
	end_position =  Vector2.ZERO
	relative = Vector2.ZERO
	pressed = false
	dragging = false
	draged = false
	real_dragging = false
	real_draged = false
	double_clicked = false
	event = null
	alt_pressed = false
	command_or_control_autoremap = false
	ctrl_pressed = false
	meta_pressed = false
	shift_pressed = false

func duplicate() -> MouseInputData:
	var fd = MouseInputData.new()
	fd.start_position = start_position
	fd.end_position = end_position
	fd.relative = relative
	fd.pressed = pressed
	fd.draged = draged
	fd.real_draged = real_draged
	fd.double_clicked = double_clicked
	fd.alt_pressed = alt_pressed
	fd.command_or_control_autoremap = command_or_control_autoremap
	fd.ctrl_pressed = ctrl_pressed
	fd.meta_pressed = meta_pressed
	fd.shift_pressed = shift_pressed
	return fd

static func update_mouse_input_data(inputdata:MouseInputData, p_event:InputEvent, p_end_position:Vector2, p_zoom:float=1):
	inputdata.event = p_event
	inputdata.zoom = p_zoom
	if p_event is InputEventMouseButton:
		if p_event.pressed:
			# 记录触摸点
			inputdata.clear()
			inputdata.start_position = p_end_position
			inputdata.end_position = inputdata.start_position
			inputdata.pressed = true
			inputdata._dt = Time.get_ticks_msec()
			inputdata._dpos = p_event.global_position
		else:
			# 移除离开的触摸点
			inputdata.pressed = false
			if inputdata.dragging:
				inputdata.draged = true
				inputdata.dragging = false
			if inputdata.real_dragging:
				inputdata.real_draged = true
				inputdata.real_dragging = false
		inputdata.alt_pressed = p_event.alt_pressed
		inputdata.command_or_control_autoremap = p_event.command_or_control_autoremap
		inputdata.ctrl_pressed = p_event.ctrl_pressed
		inputdata.meta_pressed = p_event.meta_pressed
		inputdata.shift_pressed = p_event.shift_pressed
		inputdata.double_clicked = p_event.double_click

	elif p_event is InputEventMouseMotion :
		if not inputdata.pressed:
			inputdata.clear()
		inputdata.end_position = p_end_position
		inputdata.relative = p_event.relative / p_zoom 
		inputdata.alt_pressed = p_event.alt_pressed
		inputdata.command_or_control_autoremap = p_event.command_or_control_autoremap
		inputdata.ctrl_pressed = p_event.ctrl_pressed
		inputdata.meta_pressed = p_event.meta_pressed
		inputdata.shift_pressed = p_event.shift_pressed
		if not inputdata.pressed:
			return
		if not inputdata.real_dragging:
			var dt = (Time.get_ticks_msec() -inputdata._dt)/1000.0
			var dpos = p_event.global_position -inputdata._dpos
			if dpos.length() > inputdata._drag_length or dt > inputdata._drag_duration:
				inputdata.real_dragging = true
		inputdata.dragging = true
		
