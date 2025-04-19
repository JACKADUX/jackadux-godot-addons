class_name fnPool

static func base_tween(ease:=Tween.EASE_IN_OUT, trans:=Tween.TRANS_CUBIC) -> Tween:
	var tween = Engine.get_main_loop().root.create_tween()
	tween.set_ease(ease).set_trans(trans)
	return tween
	
static func _pivot_offset(control:Control, offset :=Vector2(0.5, 0.5)):
	control.pivot_offset = Vector2(control.size.x* offset.x, control.size.y* offset.y)

static func _copy_to_use(control:Control, args:=[], kwargs:={}):
	var tween = base_tween()
	
	
static func scale(control:Control, args:=[], kwargs:={}):
	_pivot_offset(control)
	base_tween().tween_property(control, "scale", Vector2.ONE*args[0], args[1])

static func move(control:Control, args:=[], kwargs:={}):
	_pivot_offset(control)
	base_tween().tween_property(control, "position", args[0], args[1]).as_relative()

static func visible(control:Control, args:=[], kwargs:={}):
	_pivot_offset(control)
	var tween = control.create_tween()
	base_tween().tween_property(control, "modulate:a", args[0], args[1])

static func mouse_in_out(control:Control, args:=[], kwargs:={}):
	if not kwargs.has("is_entered"):
		return
	_pivot_offset(control)
	var tween = base_tween()
	if kwargs.get("is_entered"):
		tween.tween_property(control, "scale", Vector2.ONE*args[1], args[0])
	else:
		tween.tween_property(control, "scale", Vector2.ONE*args[2], args[0])

static func mouse_pressed_released(control:Control, args:=[], kwargs:={}):
	if not kwargs.has("is_pressed"):
		return
	_pivot_offset(control)
	var tween = base_tween()
	if not kwargs.get("is_pressed"):
		tween.tween_property(control, "modulate:a", args[1], args[0])
	else:
		tween.tween_property(control, "modulate:a", args[2], args[0])
