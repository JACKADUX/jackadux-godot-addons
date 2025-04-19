class_name OptionButtonViewAdapter extends ViewAdapter

func adapt_view():
	view.item_selected.connect(func():
		value_changed.emit(get_value())
	)

func get_value() -> Variant:
	return view.selected
	
func set_value(value:Variant):
	if not view: 
		return 
	view.select(value)
