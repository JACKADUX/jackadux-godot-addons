extends Button

## 触发pressed 信号需要拖拽长度小于这个数值
@export var drag_length :float= 40  
## 触发pressed 信号需要拖拽时长小于这个数值
@export var drag_duration :float= 1

var _hold := false
var _dt :float= 0
var _dpos := Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if not InputEventUtils.is_touch_support():
		return 
	if InputEventUtils.is_pressed(event) :
		_hold = true
		_dt = Time.get_ticks_msec()
		_dpos = InputEventUtils.get_event_global_position(event)  # NOTE: 触屏上不能使用get_global_mouse_position() 会有误差
		
	if InputEventUtils.is_released(event):
		_hold = false
		_dt = (Time.get_ticks_msec()- _dt)/1000.0
		_dpos = InputEventUtils.get_event_global_position(event)-_dpos
		if _dpos.length() > drag_length or _dt > drag_duration:
			return 
		pressed.emit()
