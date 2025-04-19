class_name LabelLineEdit extends LineEdit

signal value_changed(value:String)

@export var target_label:Label

func _ready():
	hide()
	
	text_submitted.connect(func(v):
		submit()
	)
	focus_exited.connect(func():
		submit()
	)
	if target_label:
		target_label.gui_input.connect(handle_input)
	set_target_label(target_label)

func set_value(value):
	target_label.text = value
	text = value

func submit():
	hide()
	target_label.show()
	if text != target_label.text:
		target_label.text = text
		value_changed.emit(text)

func set_target_label(value:Label):
	if target_label:
		target_label.gui_input.disconnect(handle_input) 
	target_label = value
	if target_label:
		target_label.gui_input.connect(handle_input)
	
	
func handle_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click:
			activate()
			
func activate():
	custom_minimum_size = target_label.custom_minimum_size
	size_flags_horizontal = target_label.size_flags_horizontal
	size_flags_vertical = target_label.size_flags_vertical
	size_flags_stretch_ratio = target_label.size_flags_stretch_ratio
	size = target_label.size
	global_position = target_label.global_position
	text = target_label.text
	show()
	target_label.hide()
	grab_focus()
	select_all()
