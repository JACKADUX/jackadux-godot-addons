extends Control

@onready var circle_panel: PanelContainer = %CirclePanel

var circle := StyleBoxCircle.new()
var circle_model_data := preload("res://test/test_mvc/circle_model_data.tres") as ModelDataMapper

func _ready() -> void:
	ViewUtils.set_view_scale(1.5)
	circle_panel.add_theme_stylebox_override("panel", circle)
	
	circle_model_data.register_with(circle_panel, "custom_minimum_size")
	
	var props = ["radius_offset", "color", "outline_width", 
				 "outline_color", "point_count", "enable_aa"]
	for prop in props:
		circle_model_data.register_with(circle, prop)
	
	circle_model_data.register("reset_all", 
		func(value): 
			value = value as StyleBoxCircle
			for prop in props:
				circle.set(prop, value.get(prop))
				circle_model_data.update(prop)
			,
		func(_key): return 
	)
	
