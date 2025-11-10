@tool
# class NodePanel
extends PanelContainer

@onready var container_nodes: SuperContainer = %ContainerNodes
@onready var n_container_nodes: SuperContainer = %NContainerNodes

const NodeUtils = preload("uid://d1narqgeaet86")


func _ready(): 
	var inspector = EditorInterface.get_inspector()
	inspector.edited_object_changed.connect(func():
		return 
		var edit_object = inspector.get_edited_object()
		if not edit_object or edit_object is not Control:
			hide()
		else:
			show()
	)
	
	_init_control_nodes()
	if get_parent() is HSplitContainer:
		size.x = 0
		get_parent().dragging_enabled = false
	 

func create_btn(node_name:String, fn:Callable, use_text = true) -> Button:
	var editor_theme = EditorInterface.get_editor_theme()
	var button = Button.new()
	button.custom_minimum_size.y = 32
	button.focus_mode = Control.FOCUS_NONE
	if use_text:
		button.text = node_name
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.icon = editor_theme.get_theme_item(Theme.DATA_TYPE_ICON, node_name, "EditorIcons")
	button.pressed.connect(func():
		var selected_node = NodeUtils.get_selected_contorl_node()
		if not selected_node:
			return 
		#if Input.is_key_pressed(KEY_ALT):
			#var node = change_type(selected_node, node_name)
			#EditorInterface.edit_node(node)
		var as_sibling = selected_node is not Container and selected_node.get_class() != "Control"
		var node := NodeUtils.general_create_control(node_name, selected_node, as_sibling)
		fn.call(node, node_name)
		EditorInterface.edit_node(node)
			
	)
	return button

func change_type(target_node:Node, node_name):
	var node = ClassDB.instantiate(node_name)
	if not node:
		return 
	for p in target_node.get_property_list():
		node.set(p.name, target_node.get(p.name))
	node.set_script(target_node.get_script())
	target_node.replace_by(node, true)
	return node

func _init_control_nodes():
	var arr = [
		NodeUtils.container_nodes,
		NodeUtils.button_nodes,
		NodeUtils.label_nodes,
		NodeUtils.input_nodes,
	]
	var info :=[
		"Container",
		"Button",
		"Label",
		"Input",
	]
	var color :=[
		Color(1, 1, 1),
		Color(0.9, 1, 1),
		Color(1, 0.9, 1),
		Color(1, 1, 0.9),
	]
	var fns = [
		func(node:Node, node_name:String):
			if node_name in SuperContainer.nodes and Input.is_key_pressed(KEY_SHIFT):
				node.set_script(SuperContainer as Script)
				node.color = Color.from_ok_hsl(randf(), 0.8, 0.8)
			,
		func(node:Node, node_name:String):
			node.set("text", node_name)
			,
		func(node:Node, node_name:String):
			node.set("text", node_name)
			,
		func(node:Node, node_name:String):
			if node is LineEdit:
				node.set("placeholder_text", node_name)
			else:
				node.set("text", node_name)
	]
	for index in arr.size():
		var fold = FoldableContainer.new()
		fold.title = info[index]
		var vbox = VBoxContainer.new()
		fold.add_child(vbox)
		fold.focus_mode = Control.FOCUS_NONE
		if index == 0:
			container_nodes.add_child(fold)
		else:
			n_container_nodes.add_child(fold)
		fold.modulate = color[index]
		for contianer in arr[index]:
			if contianer == "":
				var sep = HSeparator.new()
				vbox.add_child(sep)
				continue
			var btn = create_btn(contianer, fns[index])
			vbox.add_child(btn)
		
