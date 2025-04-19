class_name ItemButton extends Button

# hovered 可以用 mouse enter 和 exit
signal selection_changed
signal double_clicked

@export var group_name: String = ""
@export var container: Control # 用作取消选择的点击区域

var multiy_select := true

func _ready():
	if group_name:
		add_to_group(group_name)
	toggle_mode = true
	#action_mode = ACTION_MODE_BUTTON_PRESS
	toggled.connect(func(v):
		if Input.is_key_pressed(KEY_CTRL) and multiy_select:
			set_selected(v)
			selection_changed.emit()
		elif Input.is_key_pressed(KEY_SHIFT) and multiy_select:
			var selects = get_selected()
			selects.erase(self)
			if not selects:
				set_selected(true)
			else:
				var ibs = get_tree().get_nodes_in_group(group_name)
				var select_index = ibs.find(selects[0])
				var current_index = ibs.find(self)
				var start = min(select_index, current_index)
				var end = max(select_index, current_index)
				var index = 0
				var _select_start = false
				for _ib in ibs:
					if index == start:
						_select_start = true
					if _select_start:
						_ib.set_selected(true)
					if index == end:
						_select_start = false
					index += 1
			selection_changed.emit()
		else:
			for button: ItemButton in get_tree().get_nodes_in_group(group_name):
				button.set_selected(false)
			set_selected(true)
	)
	if container:
		container.focus_entered.connect(func():
			set_selected(false)
		)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if event.double_click:
			double_clicked.emit()

func set_container(p_container: Control):
	# NOTE: 为了能接受 focus, container的 mouse_filter 需要设置为 stop
	if not p_container:
		return
	container = p_container
	container.focus_mode = Control.FOCUS_CLICK
	container.focus_entered.connect(func():
		if button_pressed:
			set_selected(false)
			selection_changed.emit()
	)
	
func set_group_name(value: String):
	if is_in_group(group_name):
		remove_from_group(group_name)
	group_name = value
	add_to_group(group_name)

func set_selected(value: bool):
	if value != button_pressed:
		set_pressed_no_signal(value)
		selection_changed.emit()

func get_selected() -> Array:
	return get_tree().get_nodes_in_group(group_name) \
			.filter(func(item_button): return item_button.button_pressed)
