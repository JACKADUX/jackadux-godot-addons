@tool
#@icon("uid://4w1r4artnqj6")
class_name SuperContainer extends Control

signal type_changed(node:Node)

@export_tool_button("change_type") var change_type_button = _change_type
@export var color := Color.RED:
	set(v):
		color = v
		queue_redraw()
@export var width := -1:
	set(v):
		width = v
		queue_redraw()
var nodes = ["VBoxContainer","HBoxContainer","VFlowContainer","HFlowContainer", "VSplitContainer", "HSplitContainer","GridContainer"]

func clear():
	for child in get_children():
		remove_child_and_free(child)

func remove_child_and_free(value:Node):
	remove_child(value)
	value.queue_free()

func _change_type():
	if not Engine.is_editor_hint():
		return 
	var editor_interface = Engine.get_singleton("EditorInterface")
	var popup_menu = PopupMenu.new()
	var editor_theme = editor_interface.get_editor_theme()
	for node in nodes:
		var icon = editor_theme.get_icon(node, "EditorIcons")
		popup_menu.add_icon_item(icon, node)
	popup_menu.index_pressed.connect(func(idx):
		var node = change_type(nodes[idx])
		if not node:
			popup_menu.queue_free()
			return 
		editor_interface.edit_node(node)
		popup_menu.queue_free()
		queue_free()
	)
	popup_menu.popup_hide.connect(func():
		popup_menu.queue_free()
	)
	var mp = editor_interface.get_base_control().get_global_mouse_position()
	editor_interface.popup_dialog(popup_menu, Rect2i(mp+Vector2(0, 20), Vector2.ZERO))

func change_type(type_name:String):
	var node = _get_type_node(type_name)
	if not node:
		return 
	node.name = name
	node.unique_name_in_owner = unique_name_in_owner
	node.set_script(get_script())
	replace_by(node, true)
	node.color = color
	type_changed.emit(node)
	return node
	
func _get_type_node(type_name:String) -> Node:
	match type_name:
		"VBoxContainer": return VBoxContainer.new()
		"HBoxContainer": return HBoxContainer.new()
		"VFlowContainer": return VFlowContainer.new()
		"HFlowContainer": return HFlowContainer.new()
		"VSplitContainer": return VSplitContainer.new()
		"HSplitContainer": return HSplitContainer.new()
		"GridContainer": return GridContainer.new()
	return 

func _draw() -> void:
	if not Engine.is_editor_hint():
		return 
	draw_rect(Rect2(Vector2.ZERO, size), color, false, width)
