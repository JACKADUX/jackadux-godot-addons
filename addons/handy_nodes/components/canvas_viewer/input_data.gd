class_name InputData

var _dt = 0
var _dpos = Vector2.ZERO
var _drag_duration = 0.2
var _drag_length = 5
var _viewport : Viewport

var event:InputEvent
var start_position: Vector2
var end_position: Vector2
var relative : Vector2
var pressed:=false
var draged:= false
var real_draged := false # 附带条件的拖拽，比如拖拽长度或者时长限制
var double_clicked := false

func _to_string() -> String:
	return JSON.stringify({
		"event":event,
		"start_position":start_position,
		"end_position":end_position,
		"relative":relative,
		"pressed":pressed,
		"draged":draged,
		"real_draged":real_draged,
		"double_clicked":double_clicked,
	})

func set_input_as_handled():
	clear()
	_viewport.set_input_as_handled()

func is_pressed() -> bool:
	return pressed

func is_draged() -> bool:
	return draged
	
func is_real_draged() -> bool:
	return real_draged

func is_just_pressed() -> bool:
	return pressed and not draged

func clear():
	start_position= Vector2.ZERO
	end_position =  Vector2.ZERO
	relative = Vector2.ZERO
	pressed = false
	draged = false
	real_draged = false
	double_clicked = false

func duplicate() -> InputData:
	var fd = InputData.new()
	fd.start_position = start_position
	fd.end_position = end_position
	fd.relative = relative
	fd.pressed = pressed
	fd.draged = draged
	fd.real_draged = real_draged
	fd.double_clicked = double_clicked
	return fd

static func update_in_mouse(inputdata:InputData, event:InputEvent, end_position:Vector2, zoom:float=1):
	inputdata.event = event
	if event is InputEventMouseButton:
		if event.pressed:
			# 记录触摸点
			inputdata.clear()
			inputdata.start_position = end_position
			inputdata.end_position = inputdata.start_position
			inputdata.pressed = true
			inputdata._dt = Time.get_ticks_msec()
			inputdata._dpos = event.global_position
		else:
			# 移除离开的触摸点
			inputdata.pressed = false
		inputdata.double_clicked = event.double_click

	elif event is InputEventMouseMotion :
		if not inputdata.pressed:
			inputdata.clear()
		inputdata.end_position = end_position
		inputdata.relative = event.relative / zoom 
		if not inputdata.pressed:
			return
		if not inputdata.real_draged:
			var _dt = (Time.get_ticks_msec() -inputdata._dt)/1000.0
			var _dpos = event.global_position -inputdata._dpos
			if _dpos.length() > inputdata._drag_length or _dt > inputdata._drag_duration:
				inputdata.real_draged = true
		inputdata.draged = true
		
