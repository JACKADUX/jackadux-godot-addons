@tool
class_name SuperContainer extends Control

signal type_changed(node:Node)

@export_tool_button("change_type") var change_type_button = _change_type

var nodes = ["VBox","HBox","VFlow","HFlow", "VSplit", "HSplit","Grid"]

func clear():
	for child in get_children():
		remove_child_and_free(child)

func remove_child_and_free(value:Node):
	remove_child(value)
	value.queue_free()

func _change_type():
	if not Engine.is_editor_hint():
		return 
	var popup_menu = PopupMenu.new()
	for node in nodes:
		popup_menu.add_item(node)
	popup_menu.index_pressed.connect(func(idx):
		var node = change_type(nodes[idx])
		if not node:
			popup_menu.queue_free()
			return 
		EditorInterface.edit_node(node)
		popup_menu.queue_free()
		queue_free()
	)
	popup_menu.popup_hide.connect(func():
		popup_menu.queue_free()
	)
	var mp = EditorInterface.get_base_control().get_global_mouse_position()
	EditorInterface.popup_dialog(popup_menu, Rect2i(mp+Vector2(0, 20), Vector2.ZERO))

func change_type(type_name:String):
	var node = _get_type_node(type_name)
	if not node:
		return 
	node.name = name
	node.unique_name_in_owner = unique_name_in_owner
	node.set_script(get_script())
	replace_by(node, true)
	type_changed.emit(node)
	return node
	
func _get_type_node(type_name:String) -> Node:
	match type_name:
		"VBox": return VBoxContainer.new()
		"HBox": return HBoxContainer.new()
		"VFlow": return VFlowContainer.new()
		"HFlow": return HFlowContainer.new()
		"VSplit": return VSplitContainer.new()
		"HSplit": return HSplitContainer.new()
		"Grid": return GridContainer.new()
	return 
