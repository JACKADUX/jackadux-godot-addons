@tool
class_name ApplyThemeColor extends Node

@export var color_name := "color_border"

func _ready():
	apply(get_parent(), color_name)
	if not Engine.is_editor_hint():
		queue_free()

static func get_color(color_name:String) -> Color:
	var color = ThemeDB.get_project_theme().get_color(color_name, "BASE")
	return Color.RED if not color else color

static func apply(node:CanvasItem, color_name:String):
	node.self_modulate = get_color(color_name)
