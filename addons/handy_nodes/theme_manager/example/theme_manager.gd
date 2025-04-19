@tool
extends ABSThemeManager

## Constant
const constant_stroke  = 6
const constant_corner_radius = constant_stroke*2
const constant_base    := 48   # x1
const constant_small   := 96   # x2
const constant_middle  := 144  # x3
const constant_large   := 240  # x5

## Color
const color_white := Color("faf4e6")
const color_black := Color("32312D")
const color_yellow := Color("FBC436")
const color_pink := Color("FF54BA")
const color_blue := Color("06B8BA")


# Brand  # 变化时饱和度降低/明度增加 -> 向白色
const color_main := color_yellow
const color_sub := Color("434D1A")
const color_bg_active := Color("434D1A") # 空按钮选中态背景色

# Neutrals  # 变化时饱和度降低/明度增加 -> 向白色
const color_text_primary := color_black
const color_text_subtext := color_black

# Background
const color_bg_base := color_white # 基础背景色
const color_bg_sub := Color("141414") # 次级容器背景色
const color_component_container := Color("171717") # 组件容器背景色
const color_float_container := Color("202122") # 浮层容器背景色
const color_border := color_black # 边框色

# System
const color_amber := Color("#FEB63D")
const color_notice := Color("#51CC56")
const color_warning := Color("#5B93FF")
const color_error := Color("#FF5555")
const color_error_dark := Color("#4D0000")

## FontSize
const fontsize_title :int=32 
const fontsize_body :int=32 

## Font
const font_base = preload("res://assets/fonts/DMSans-Regular.ttf")
const font_bold = preload("res://assets/fonts/DMSans-Medium.ttf")

func _initialize():
	set_font(font_base, fontsize_body)
	
	create_panel_container()
	create_label()
	create_seperator()
	create_button()
	
func create_panel_container():
	var main_panel = PipStyleBoxFlat.new().pip_bg_color(color_bg_base)
	builder.add_type("PanelContainer").panel_set_stylebox(main_panel.get_stylebox_flat())
	
	# base_panel
	var base_panel = (main_panel.pip_duplicate()
		.pip_corner_radius_all(constant_corner_radius)
		.pip_border(color_border, constant_stroke)
		.pip_shadow(color_border, 1, Vector2.ONE*constant_corner_radius)
	)
	builder.add_type("base_panel", "PanelContainer").panel_set_stylebox(base_panel.get_stylebox_flat())

	# popup_panel
	var popup_panel = (base_panel.pip_duplicate()
		.pip_bg_color(color_border)
		.pip_corner_radius_all(constant_corner_radius*2)
		.pip_border_color(color_bg_base)
		.pip_content_margin_all(12)
		.pip_shadow_color(Color(color_border, 0.5))
		.pip_shadow_offset(Vector2.ONE*constant_corner_radius*1.5)
	)
	builder.add_type("popup_panel", "PanelContainer").panel_set_stylebox(popup_panel.get_stylebox_flat())
	
	# clip_panel
	var clip_panel = (main_panel.pip_duplicate()
		.pip_corner_radius_all(constant_corner_radius-constant_stroke)
	)
	builder.add_type("clip_panel", "PanelContainer").panel_set_stylebox(clip_panel.get_stylebox_flat())
	
func create_label():
	(builder.add_type("Label")
		.set_color("font_color", color_text_primary)
	.add_type("label_title", "Label")
		.set_color("font_color", color_text_subtext)
		.set_font("font", font_bold)
		.set_font_size("font_size", fontsize_body) 
	.add_type("label_sub_title", "Label")
		.set_color("font_color", color_text_subtext)
		.set_font_size("font_size", fontsize_body)
	.add_type("label_details", "Label")
		.set_color("font_color", color_text_subtext)
		.set_font_size("font_size", fontsize_body) 
	.add_type("label_small", "Label")
		.set_color("font_color", color_text_subtext)
		.set_font_size("font_size", fontsize_body)
	)

func create_seperator():
	builder.add_type("VSeparator").set_stylebox("separator", StyleBoxEmpty.new())
	builder.add_type("HSeparator").set_stylebox("separator", StyleBoxEmpty.new())
		
	var line = PipStyleBoxFlat.create_stylebox_line(color_border, constant_stroke)
	builder.add_type("seperator_widget_h", "HSeparator").set_stylebox("separator", line)
	
	line = PipStyleBoxFlat.create_stylebox_line(color_border, constant_stroke, true)
	builder.add_type("seperator_widget_v", "VSeparator").set_stylebox("separator", line)
	
func create_button():
	var sc = (PipButtonStyleboxs.create_base_bottons()
		.pip_corner_radius_all(constant_corner_radius)
		.pip_bg_color(color_bg_base)
		.pip_border(color_border, constant_stroke)
		.pip_shadow(color_border, 1, Vector2.ONE*constant_corner_radius)
	)
	
	var cc = (PipButtonColors.create_base_bottons()
		.pip_color_all(color_border)
		.pip_font_color(PipButtonColors.DISABLED, Color(color_border, 0.5))
	)
	
	## base button
	var sc_base_button = (sc.pip_duplicate()
		.pip_content_margin_all(12)
		.pip_pressed()
			.pip_bg_color(color_main)
			.pip_shadow(color_border, 1, Vector2.ONE*constant_corner_radius*0.5)
			.retrieve_collection()
		.pip_hover()
			.pip_expand_margin_all(6)
			.pip_shadow(Color(color_border, 0.8), 1, Vector2.ONE*constant_corner_radius*1.2)
			.retrieve_collection()
		.pip_disabled()
			.pip_bg_color(Color(color_border, 0.5))
			.pip_border(Color(color_border, 0.8), constant_stroke)
			.pip_shadow(color_border, 0, Vector2.ZERO)
			.retrieve_collection()
	)
	(builder.add_type("base_button", "Button")
		.button_set_stylebox_data(sc_base_button.get_stylebox_flat_data(), true)
		.button_set_colors_data(cc.colors)
		.set_font_size("font_size", fontsize_body)
	)
	
	## tab button
	var sc_tab_button = (sc.pip_duplicate()
		.pip_corner_radius_all(0)
		.pip_border_width_all(0)
		.pip_shadow_size(0)
		.pip_pressed()
			.pip_bg_color(color_main)
			.retrieve_collection()
		.pip_disabled()
			.pip_bg_color(Color(color_border, 0.5))
			.retrieve_collection()
	)
	(builder.add_type("tab_button", "Button")
		.button_set_stylebox_data(sc_tab_button.get_stylebox_flat_data(), true)
		.button_set_colors_data(cc.colors)
	)
	
