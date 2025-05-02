extends Control

var mapper = preload("res://test/test_mvc2/circle_main_model_mapper.tres") as ModelDataMapper

var circle := StyleBoxCircle.new()
@onready var circle_panel: PanelContainer = %CirclePanel

func _ready() -> void:
	circle_panel.add_theme_stylebox_override("panel", circle)
	
	circle.color = Color.WHITE
	
	mapper.register_with(circle_panel, "custom_minimum_size")
	mapper.register_with(circle, "radius_offset")
	mapper.register_with(circle, "color")
