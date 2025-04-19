extends GridContainer

signal value_changed(value:Color)
signal drag_started
signal drag_ended

@onready var sv_rect = %SVRect
@onready var alpha_rect = %AlphaRect
@onready var final_color = %FinalColor

@onready var sv_tracer = %SVTracer
@onready var hue_tracer = %HueTracer
@onready var alpha_tracer = %AlphaTracer

var h :float = 0
var s :float = 0
var v :float = 0
var a :float = 1

#---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------
func _ready():
	sv_tracer.location_changed.connect(func():
		var location = sv_tracer.get_location()
		s = location.x
		v = 1-location.y
		update_color()
	)
	hue_tracer.location_changed.connect(func():
		var location = hue_tracer.get_location()
		h = location.y
		update_color()
	)
	alpha_tracer.location_changed.connect(func():
		var location = alpha_tracer.get_location()
		a = location.x
		update_color()
	)
	
	for tracer in [sv_tracer, hue_tracer, alpha_tracer]:
		tracer.drag_started.connect(func():
			drag_started.emit()
		)
		tracer.drag_ended.connect(func():
			value_changed.emit(final_color.color)
			drag_ended.emit()
		)
	
	set_value(Color.WHITE)
	
#---------------------------------------------------------------------------------------------------
func hsva_color(_h:float, _s:float, _v:float, _a:float) -> Color:
	var color := Color.RED
	color.h = _h
	color.s = _s
	color.v = _v
	color.a = _a
	return color

#---------------------------------------------------------------------------------------------------
func update_color():
	var color := hsva_color(h,s,v,a)
	final_color.color = color
	alpha_tracer.fill_color = color
	alpha_rect.color = color 
	sv_rect.material.set_shader_parameter("h", h)
	sv_tracer.fill_color = hsva_color(h, s, v, 1)
	hue_tracer.fill_color = hsva_color(h, 1, 1, 1)
	

#---------------------------------------------------------------------------------------------------
func set_value(value:Color):
	h = value.h
	s = value.s
	v = value.v
	a = value.a
	hue_tracer.set_location(Vector2(0,h))
	sv_tracer.set_location(Vector2(s,1-v))
	alpha_tracer.set_location(Vector2(a,0))
	update_color()
