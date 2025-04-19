class_name ValueCombineAdapter extends ViewAdapter

enum Type {VECTOR}

@export var type := Type.VECTOR
# widget 需要满足条件 ViewAdapter 相关接口
@export var widgets :Array[Node]= []  

func adapt_view():
	for i in widgets.size():
		widgets[i].value_changed.connect(func(value):
			value_changed.emit(get_value())
		)

func get_value() -> Variant:
	var value
	match type:
		Type.VECTOR:
			match widgets.size():
				2 : value = Vector2.ZERO
				3 : value = Vector3.ZERO
				4 : value = Vector4.ZERO
		_:
			return null
	for i in widgets.size():
		value[i] = widgets[i].get_value()
	return value
	
func set_value(value):
	for i in widgets.size():
		widgets[i].set_value(value[i])
