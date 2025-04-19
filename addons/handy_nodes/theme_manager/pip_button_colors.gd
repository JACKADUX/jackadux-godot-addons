class_name PipButtonColors extends Resource

const NORMAL := "normal"
const PRESSED := "pressed"
const HOVER := "hover"
const DISABLED := "disabled"
const FOCUS := "focus"
const HOVER_PRESSED := "hover_pressed"
const OUTLINE := "outline"

enum ColorType {NONE, FONT,ICON,BOTH}

@export var colors :Dictionary[String, Color]= {}

func pip_add_colors(props:PackedStringArray, color:=Color.BLACK) -> PipButtonColors:
	for key in props:
		colors[key] = color
	return self
	
func pip_add_font_color() -> PipButtonColors:
	pip_add_colors([
		"font_normal_color",
		"font_pressed_color",
		"font_hover_color",
		"font_disabled_color",
		"font_hover_pressed_color",
		"font_outline_color",
		"font_focus_color",
	], Color.BLACK)
	return self
	
func pip_add_icon_color() -> PipButtonColors:
	pip_add_colors([
		"icon_normal_color",
		"icon_pressed_color",
		"icon_hover_color",
		"icon_disabled_color",
		"icon_hover_pressed_color",
		"icon_focus_color",
	], Color.BLACK)
	return self

func pip_color_all(value:Color) -> PipButtonColors:
	pip_font_color_all(value)
	pip_icon_color_all(value)
	return self
	
func pip_font_color_all(value:Color) -> PipButtonColors:
	for key in colors:
		if key.begins_with("font_"):
			colors[key] = value
	return self
	
func pip_icon_color_all(value:Color) -> PipButtonColors:
	for key in colors:
		if key.begins_with("icon_"):
			colors[key] = value
	return self

func pip_color(key_prop:String, value:Color, type:=ColorType.BOTH) -> PipButtonColors:
	match type:
		ColorType.FONT:
			key_prop = "font_%s_color"%key_prop 
		ColorType.ICON:
			key_prop = "icon_%s_color"%key_prop 
		ColorType.BOTH:
			pip_color(key_prop, value, ColorType.FONT)
			pip_color(key_prop, value, ColorType.ICON)
	colors[key_prop] = value
	return self

func pip_font_color(key_prop:String, value:Color) -> PipButtonColors:
	pip_color(key_prop, value, ColorType.FONT)
	return self

func pip_icon_color(key_prop:String, value:Color) -> PipButtonColors:
	pip_color(key_prop, value, ColorType.ICON)
	return self

static func create_base_bottons() -> PipButtonColors:
	var pbc = PipButtonColors.new()
	pbc.pip_add_font_color()
	pbc.pip_add_icon_color()
	return pbc
