class_name MenuButtonViewAdapter extends ViewAdapter

var _index: int = -1

func adapt_view():
	if view is not MenuButton:
		return
	var popup = view.get_popup()
	popup.index_pressed.connect(func(index:int):
		_index = index
		value_changed.emit(get_value())
	)

func get_value() -> Variant:
	return _index
	
func set_value(value:Variant):
	if not view: 
		return 
	_index = value
