class_name ColorPickerAdapter extends ViewAdapter

func adapt_view():
	view = view as ColorPickerButton
	view.color_changed.connect(func(v):
		value_changed.emit(v)
	)

func get_value() -> Variant:
	return view.color
	
func set_value(value):
	view.color = value
