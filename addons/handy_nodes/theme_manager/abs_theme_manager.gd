class_name ABSThemeManager extends EditorScript

var theme_path :String
var builder: ThemeTypeBuilder


func _run():
	theme_path = _get_theme_path()
	builder = ThemeTypeBuilder.new(load(theme_path))
	builder.theme.clear()
	store_base()
	_initialize()
	builder.save(theme_path)
	print("Theme Generated")
	
func _get_theme_path() -> String:
	return "res://assets/main_theme.tres"

func _initialize():
	pass

func set_font(font:Font, size:int):
	builder.theme.default_font = font
	builder.theme.default_font_size = size

func store_base():
	builder.add_type("BASE")
	var const_map = get_script().get_script_constant_map()
	for key:String in const_map:
		if key.begins_with("color_"):
			builder.set_color(key, const_map[key])
		if key.begins_with("constant_"):
			builder.set_constant(key, const_map[key])
		if key.begins_with("fontsize_"):
			builder.set_font_size(key, const_map[key])
		if key.begins_with("font_"):
			builder.set_font(key, const_map[key])
