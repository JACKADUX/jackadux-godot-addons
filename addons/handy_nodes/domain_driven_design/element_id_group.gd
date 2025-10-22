#class ElementIdGroup

signal value_changed

var _ids :Array[String]= []

func size() -> int:
	return _ids.size()

func get_ids() -> Array[String]:
	return _ids.duplicate()

func has(value:String) -> bool:
	return _ids.has(value)

func append(value:String):
	if value not in _ids:
		_ids.append(value)
		value_changed.emit()

func erase(value:String):
	var index = _ids.find(value)
	if index == -1:
		return 
	_ids.remove_at(index)
	value_changed.emit()

func clear():
	if not _ids:
		return 
	_ids.clear()
	value_changed.emit()

func set_all(p_ids:Array):
	if p_ids == _ids:
		return
	_ids.assign(p_ids)
	value_changed.emit()
