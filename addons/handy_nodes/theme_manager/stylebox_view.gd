extends VBoxContainer

@export var stylebox_collection:Dictionary
@export var colors_collection:Dictionary

@export var minsize := Vector2(0, 0)

@export var icon : Texture2D
@export var text : String
@export var font : Font

func set_stylebox_collection(value:Dictionary):
	stylebox_collection = value

func set_colors_collection(value:Dictionary):
	colors_collection = value

func clear():
	for child in get_children():
		remove_child(child)
		child.queue_free()

func update_buttons():
	clear()
	
	var active_button = Button.new()
	add_child(active_button)
	active_button.custom_minimum_size = minsize
	active_button.icon = icon
	active_button.text = text
	active_button.add_theme_font_override("font", font)
	active_button.add_theme_font_size_override("font_size", 24)
	
	if not stylebox_collection.has("focus"):
		active_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
	var check_box = CheckButton.new()
	add_child(check_box)
	check_box.pressed.connect(func():
		active_button.disabled = check_box.button_pressed
	)
	
	for key in stylebox_collection:
		var stylebox = stylebox_collection[key]
		active_button.add_theme_stylebox_override(key, stylebox)
		
		var button = Button.new()
		add_child(button)
		button.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.custom_minimum_size = minsize
		button.icon = icon
		button.text = key
		
		button.add_theme_font_override("font", font)
		button.add_theme_font_size_override("font_size", 24)
		button.add_theme_stylebox_override("normal", stylebox)
		
		for color_key in colors_collection:
			var color = colors_collection[color_key]
			if color_key == "font_normal_color":
				active_button.add_theme_color_override("font_color", color)
			else:
				active_button.add_theme_color_override(color_key, color)
			if key in color_key:
				if color_key.begins_with("font_"):
					button.add_theme_color_override("font_color", color)
				if color_key.begins_with("icon_"):
					button.add_theme_color_override("icon_normal_color", color)
		
func update_panels():
	clear()
	for key in stylebox_collection:
		var stylebox = stylebox_collection[key]
		var panel = PanelContainer.new()
		panel.custom_minimum_size = minsize
		panel.add_theme_stylebox_override("panel", stylebox)
		add_child(panel)
		var label = Label.new()
		panel.add_child(label)
		label.text = key
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 24)
	
