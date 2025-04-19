
class_name ThemeTypeBuilder

var theme : Theme
var type_name := ""
		
func _init(p_theme:Theme=null):
	if not p_theme:
		p_theme = Theme.new()
	theme = p_theme

func remove_type(p_type_name:String) -> ThemeTypeBuilder:
	theme.remove_type(p_type_name)
	return self

func add_type(p_type_name:String, base_type:String="") -> ThemeTypeBuilder:
	if p_type_name:
		type_name = p_type_name
	if not type_name in theme.get_type_list():
		theme.add_type(type_name)
	if base_type:
		theme.set_type_variation(type_name, base_type)
	return self

## -------------------------------------------------------------------------------------------------
func set_color(p_name:String, value:Color) -> ThemeTypeBuilder:
	theme.set_color(p_name, type_name, value)
	return self
	
func set_constant(p_name:String, value:int) -> ThemeTypeBuilder:
	theme.set_constant(p_name, type_name, value)
	return self

func set_font(p_name:String, value:Font) -> ThemeTypeBuilder:
	theme.set_font(p_name, type_name, value)
	return self

func set_font_size(p_name:String, value:int) -> ThemeTypeBuilder:
	theme.set_font_size(p_name, type_name, value)
	return self

func set_icon(p_name:String, value:Texture2D) -> ThemeTypeBuilder:
	theme.set_icon(p_name, type_name, value)
	return self

func set_stylebox(p_name:String, value:StyleBox) -> ThemeTypeBuilder:
	theme.set_stylebox(p_name, type_name, value)
	return self

func save(path:String):
	ResourceSaver.save(theme, path) # "res://test_theme.tres"


## -------------------------------------------------------------------------------------------------
func panel_set_stylebox(value:StyleBox) -> ThemeTypeBuilder:
	set_stylebox("panel", value)
	return self

func margin_set_side(value:int, globalscope_side:=4) -> ThemeTypeBuilder:
	# globalscope_side -> @GlobalScope.SIDE
	match globalscope_side:
		0:
			set_constant("margin_left", value)
		1:
			set_constant("margin_top", value)
		2:
			set_constant("margin_right", value)
		3:
			set_constant("margin_bottom", value)
		_:
			set_constant("margin_left", value)
			set_constant("margin_top", value)
			set_constant("margin_right", value)
			set_constant("margin_bottom", value)
	return self

func button_set_stylebox_data(data:Dictionary, focus_emty:=false) -> ThemeTypeBuilder :
	for key in data:
		set_stylebox(key, data[key])
	if focus_emty:
		set_stylebox("focus", StyleBoxEmpty.new())
	return self

func button_set_colors_data(data:Dictionary)  -> ThemeTypeBuilder:
	for key in data:
		if key == "font_normal_color":
			set_color("font_color", data[key])
		else:
			set_color(key, data[key])
	return self

func button_set_font_color_all(value:Color) -> ThemeTypeBuilder:
	set_color("font_color", value)
	set_color("font_disabled_color", value)
	set_color("font_focus_color", value)
	set_color("font_hover_color", value)
	set_color("font_pressed_color", value)
	set_color("font_hover_pressed_color", value)
	return self

func button_set_icon_color_all(value:Color) -> ThemeTypeBuilder:
	set_color("icon_normal_color", value)
	set_color("icon_disabled_color", value)
	set_color("icon_focus_color", value)
	set_color("icon_hover_color", value)
	set_color("icon_pressed_color", value)
	set_color("icon_hover_pressed_color", value)
	return self

func button_set_color_all(value:Color) -> ThemeTypeBuilder:
	button_set_icon_color_all(value)
	button_set_font_color_all(value)
	return self

func button_set_color(prop:String, value:Color) -> ThemeTypeBuilder:
	set_color("font_%s"%prop, value)
	if prop == "color":
		prop = "normal_color"
	set_color("icon_%s"%prop, value)
	return self
	
	
	
	
