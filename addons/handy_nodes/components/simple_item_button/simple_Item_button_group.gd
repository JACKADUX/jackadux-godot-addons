class_name SimpleItemButtonGroup extends Resource

signal selection_changed
signal context_menu_reqeusted

var _group_name := ""
var _multi_select := true

var last_pressed :WeakRef

func _init(group_name:String, unpress_container:Control, multi_select:=true):
	_multi_select = multi_select
	_group_name = group_name 
	if unpress_container:
		unpress_container.gui_input.connect(func(event):
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
				for button:SimpleItemButton in get_item_buttons():
					button.set_pressed_no_signal(false)
				selection_changed.emit()
			elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
				context_menu_reqeusted.emit()
		)

func add_item_button_to_group(item_button:SimpleItemButton):
	item_button.add_to_group(_group_name)
	item_button.toggled.connect(_on_button_toggle.bind(item_button))
	item_button.gui_input.connect(_on_button_gui_input.bind(item_button))
	
func remove_item_button_from_group(item_button:SimpleItemButton):
	item_button.remove_from_group(_group_name)
	item_button.toggled.disconnect(_on_button_toggle.bind(item_button))
	item_button.gui_input.disconnect(_on_button_gui_input.bind(item_button))
	
func _on_button_gui_input(event:InputEvent, item_button:SimpleItemButton):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if not item_button.button_pressed:
			deselect_all_no_signal()
			item_button.set_pressed_no_signal(true)
		context_menu_reqeusted.emit()

func _on_button_toggle(on_toggle:bool, item_button:SimpleItemButton):
	if not item_button.is_in_group(_group_name):
		printerr("item_button '%s'必须退出当前组对象 '%s'"%[item_button, _group_name])
		return 
	var ctrl_pressed := Input.is_key_label_pressed(KEY_CTRL)
	var shift_pressed := Input.is_key_label_pressed(KEY_SHIFT)
	if not _multi_select:
		Engine.get_main_loop().call_group(get_group_name(), "set_pressed_no_signal", false)
		item_button.set_pressed_no_signal(on_toggle)
		selection_changed.emit()
		return 
	if ctrl_pressed:
		last_pressed = weakref(item_button)
		 
	elif shift_pressed and last_pressed.get_ref():
		var buttons = get_item_buttons()
		var start = buttons.find(last_pressed.get_ref())
		var end =  buttons.find(item_button)
		var rstart = min(start, end)
		var rend = max(start, end)
		Engine.get_main_loop().call_group(get_group_name(), "set_pressed_no_signal", false)
		for i in range(rstart, rend+1):
			buttons[i].set_pressed_no_signal(true)
		selection_changed.emit()
	else: 
		Engine.get_main_loop().call_group(get_group_name(), "set_pressed_no_signal", false)
		item_button.set_pressed_no_signal(true)
		selection_changed.emit()
	last_pressed = weakref(item_button)

func deselect_all_no_signal():
	for button:SimpleItemButton in get_item_buttons():
		button.set_pressed_no_signal(false)

func get_group_name():
	return _group_name
	
func get_item_buttons() -> Array[SimpleItemButton]:
	var item_buttons :Array[SimpleItemButton] = []
	item_buttons.assign(Engine.get_main_loop().get_nodes_in_group(get_group_name()))
	return item_buttons

func get_selected_items()-> Array[SimpleItemButton]:
	return get_item_buttons().filter(func(itembutton): return itembutton.button_pressed)
