class_name ColorCombineAdapter extends ViewAdapter

# NOTE: 8 -> 0~255 否则就是 0~1
enum Type {R_G_B_A, R8_G8_B8_A, R8_G8_B8_A8, H_S_V_A, H_S_L_A}

@export var type := Type.R8_G8_B8_A
@export var r :Node
@export var g :Node 
@export var b :Node 
@export var a :Node 
@export var default_color := Color.WHITE

func adapt_view():
	var widgets = [r, g, b, a]
	for i in widgets.size():
		var widget = widgets[i]
		if not widget:
			continue
		widget.value_changed.connect(func(value):
			value_changed.emit(get_value())
		)

func get_value() -> Variant:
	var color = Color.WHITE
	match type:
		Type.R_G_B_A:
			color.r = _get_value_or_default(r, default_color.r)
			color.g = _get_value_or_default(g, default_color.g)
			color.b = _get_value_or_default(b, default_color.b)
			color.a = _get_value_or_default(a, default_color.a)
		Type.R8_G8_B8_A:
			color.r8 = _get_value_or_default(r, default_color.r8)
			color.g8 = _get_value_or_default(g, default_color.g8)
			color.b8 = _get_value_or_default(b, default_color.b8)
			color.a  = _get_value_or_default(a, default_color.a)
		Type.R8_G8_B8_A8:
			color.r8 = _get_value_or_default(r, default_color.r8)
			color.g8 = _get_value_or_default(g, default_color.g8)
			color.b8 = _get_value_or_default(b, default_color.b8)
			color.a8 = _get_value_or_default(a, default_color.a8)
		Type.H_S_V_A:
			color.h = _get_value_or_default(r, default_color.h)
			color.s = _get_value_or_default(g, default_color.s)
			color.v = _get_value_or_default(b, default_color.s)
			color.a = _get_value_or_default(a, default_color.a)
		Type.H_S_L_A:
			color.ok_hsl_h = _get_value_or_default(r, default_color.ok_hsl_h)
			color.ok_hsl_s = _get_value_or_default(g, default_color.ok_hsl_s)
			color.ok_hsl_l = _get_value_or_default(b, default_color.ok_hsl_l)
			color.a = _get_value_or_default(a, default_color.a)
	return color
	
func set_value(value):
	match type:
		Type.R_G_B_A:
			_set_value_or_skip(r, value.r)
			_set_value_or_skip(g, value.g)
			_set_value_or_skip(b, value.b)
			_set_value_or_skip(a, value.a)
		Type.R8_G8_B8_A:
			_set_value_or_skip(r, value.r8)
			_set_value_or_skip(g, value.g8)
			_set_value_or_skip(b, value.b8)
			_set_value_or_skip(a, value.a)
		Type.R8_G8_B8_A8:
			_set_value_or_skip(r, value.r8)
			_set_value_or_skip(g, value.g8)
			_set_value_or_skip(b, value.b8)
			_set_value_or_skip(a, value.a8)
		Type.H_S_V_A:
			_set_value_or_skip(r, value.h)
			_set_value_or_skip(g, value.s)
			_set_value_or_skip(b, value.v)
			_set_value_or_skip(a, value.a)
		Type.H_S_L_A:
			_set_value_or_skip(r, value.ok_hsl_h)
			_set_value_or_skip(g, value.ok_hsl_s)
			_set_value_or_skip(b, value.ok_hsl_l)
			_set_value_or_skip(a, value.a)

func _get_value_or_default(widget:Node, default:float=1):
	if widget:
		return widget.get_value()
	return default

func _set_value_or_skip(widget:Node, value:float):
	if widget:
		widget.set_value(value)
