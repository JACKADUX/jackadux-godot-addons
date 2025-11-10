#class NodePopupUtils
 

const container_nodes := ["MarginContainer", "", 
						"HBoxContainer","VBoxContainer","HFlowContainer","VFlowContainer","HSplitContainer","VSplitContainer", "GridContainer","",
						"CenterContainer","ScrollContainer","FoldableContainer","TabContainer","",
						"Control","PanelContainer"]

const button_nodes := ["Button", "TextureButton", "", 
						"CheckButton", "CheckBox", "",
						"OptionButton", "MenuButton"]

const label_nodes := ["Label", "RichTextLabel","TextureRect","ColorRect","","Panel","ReferenceRect"]
const input_nodes := ["LineEdit","SpinBox","HSlider"]


static func add_control_sub_nodes(context_plugin:EditorContextMenuPlugin):
	var selected_node = get_selected_contorl_node()
	if not selected_node:
		return 
	var as_sibling = selected_node is not Container and selected_node.get_class() != "Control"

	var theme = EditorInterface.get_base_control()
	var _create_add_node_popup = func(nodes:Array, fn:Callable) -> PopupMenu:
		var popup_menu = PopupMenu.new()
		var index_id = 0
		for node in nodes:
			index_id += 1
			if node == "":
				popup_menu.add_separator("", index_id)
				continue
			if not ClassDB.can_instantiate(node):
				continue
			popup_menu.add_icon_item(theme.get_theme_icon(node, "EditorIcons"), node, index_id)
			
		popup_menu.id_pressed.connect(func(id):
			var _class = nodes[id-1]
			fn.call(_class)
		)
		return popup_menu
		#
	
	var _add_context_container = func(context_plugin:EditorContextMenuPlugin, target_node:Node, as_sibling:=false):
		var popup_menu = _create_add_node_popup.call(container_nodes, func(node_name:String):
			var node := general_create_control(node_name, target_node, as_sibling)
			if node_name in SuperContainer.nodes and Input.is_key_pressed(KEY_SHIFT):
				node.set_script(SuperContainer as Script)
				node.color = Color.from_ok_hsl(randf(), 0.8, 0.8)
			EditorInterface.edit_node(node)
		) 
		context_plugin.add_context_submenu_item("Add Container", popup_menu, theme.get_theme_icon("Container", "EditorIcons"))

	var _add_context_button = func(context_plugin:EditorContextMenuPlugin,target_node:Node, as_sibling:=false):
		var popup_menu = _create_add_node_popup.call(button_nodes, func(node_name:String):
			var node = general_create_control(node_name, target_node, as_sibling)
			node.set("text", node_name)
		) 
		context_plugin.add_context_submenu_item("Add Button", popup_menu, theme.get_theme_icon("BaseButton", "EditorIcons"))

	var _add_context_label = func(context_plugin:EditorContextMenuPlugin,target_node:Node, as_sibling:=false):
		var popup_menu = _create_add_node_popup.call(label_nodes, func(node_name:String):
			var node = general_create_control(node_name, target_node, as_sibling)
			node.set("text", node_name)
		) 
		context_plugin.add_context_submenu_item("Add Label", popup_menu, theme.get_theme_icon("Label", "EditorIcons"))

	var _add_context_input = func(context_plugin:EditorContextMenuPlugin,target_node:Node, as_sibling:=false):
		var popup_menu = _create_add_node_popup.call(input_nodes, func(node_name:String):
			var node = general_create_control(node_name, target_node, as_sibling)
			if node is LineEdit:
				node.set("placeholder_text", node_name)
			else:
				node.set("text", node_name)
		) 
		context_plugin.add_context_submenu_item("Add Input", popup_menu, theme.get_theme_icon("LineEdit", "EditorIcons"))

	
	_add_context_container.call(context_plugin, selected_node, as_sibling)
	_add_context_button.call(context_plugin, selected_node, as_sibling)
	_add_context_label.call(context_plugin, selected_node, as_sibling)
	_add_context_input.call(context_plugin, selected_node, as_sibling)
 
static func get_selected_nodes() -> Array:
	return EditorPlugin.new().get_editor_interface().get_selection().get_selected_nodes()

static func get_selected_contorl_node() -> Control:
	var selected_nodes = get_selected_nodes()
	if selected_nodes.size() != 1:
		return 
	var selected_node = selected_nodes[0]
	if selected_node is not Control:
		return 
	return selected_node

static func general_create_control(node_name:String, target_node:Node, as_sibling:=false) -> Node:
	var node = ClassDB.instantiate(node_name)
	node.name = node_name
	var is_root = target_node == EditorInterface.get_edited_scene_root()
	if as_sibling and not is_root:
		target_node.add_sibling(node)
	else:
		target_node.add_child(node)
	node.owner = target_node.owner if not is_root else target_node
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return node
