class_name ButtonViewAdapter extends ViewAdapter

enum Type {VALUE_EMIT, TOGGLE_BOOL, TOGGLE_VALUE}

@export var type := Type.VALUE_EMIT

func adapt_view():
	match type:
		Type.VALUE_EMIT:
			view.pressed.connect(func():
				var value = true if not has_meta("value") else get_meta("value")
				value_changed.emit(get_value())
			)
		Type.TOGGLE_BOOL:
			if not view.toggle_mode:
				printerr(" '%s' 对象并没有开启 toggle_mode "%[str(view)])
				return
			view.toggled.connect(func(toggled_on: bool):
				value_changed.emit(get_value())
			)
		Type.TOGGLE_VALUE:
			if not view.toggle_mode:
				printerr(" '%s' 对象并没有开启 toggle_mode "%[str(view)])
				return
			view.toggled.connect(func(toggled_on: bool):
				var value = get_meta("value_on") if toggled_on else get_meta("value_off")
				value_changed.emit(get_value())
			)

func get_value() -> Variant:
	match type:
		Type.VALUE_EMIT:
			return true if not has_meta("value") else get_meta("value")
		Type.TOGGLE_BOOL:
			return view.button_pressed
		Type.TOGGLE_VALUE:
			return get_meta("value_on") if view.button_pressed else get_meta("value_off")
	return
	
func set_value(value:Variant):
	if not view: 
		return 
	match type:
		Type.VALUE_EMIT:
			pass
		Type.TOGGLE_BOOL:
			view.set_pressed_no_signal(value)
		Type.TOGGLE_VALUE:
			if value == get_meta("value_on"):
				view.set_pressed_no_signal(true)
			elif value == get_meta("value_off"):
				view.set_pressed_no_signal(false)
			
