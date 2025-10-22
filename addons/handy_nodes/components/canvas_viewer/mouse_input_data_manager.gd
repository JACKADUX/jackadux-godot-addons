class_name MouseInputDataManager

var input_datas := {}

func init_datas(viewport:Viewport):
	for mb in 10:
		var button_index = mb as MouseButton
		var input_data = MouseInputData.new()
		input_data._viewport = viewport
		input_data.button_index = button_index
		input_datas[mb] = input_data
	
func update_datas(event:InputEvent, mouse_position:Vector2, zoom:float=1):
	for input_data in get_datas(event):
		MouseInputData.update_mouse_input_data(input_data, event, mouse_position, zoom)

func get_datas(event:InputEvent) -> Array[MouseInputData]:
	var datas :Array[MouseInputData]= []
	for index in get_buttons_index(event):
		datas.append(input_datas.get(index))
	return datas 

static func get_buttons_index(event:InputEvent) -> Array[MouseButton]:
	var indexs :Array[MouseButton]= []
	if event is not InputEventMouse:
		indexs.append(MOUSE_BUTTON_NONE)
	elif event is InputEventMouseButton:
		indexs.append(event.button_index)
	elif event is InputEventMouseMotion:
		if not event.button_mask:
			indexs.append(MOUSE_BUTTON_NONE)
		if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
			indexs.append(MOUSE_BUTTON_LEFT)
		if event.button_mask & MOUSE_BUTTON_MASK_RIGHT:
			indexs.append(MOUSE_BUTTON_RIGHT)	
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			indexs.append(MOUSE_BUTTON_MIDDLE)
	return indexs
