@tool
extends EditorPlugin

const Editor2DContextPlugin = preload("uid://pqt4g7opvaeh")
const FileSystemContextPlugin = preload("uid://dssec8kqvvtsf")
const SceneTreeContextPlugin = preload("uid://drt3slowysky7")



var filesystem_context_plugin : FileSystemContextPlugin
var scenetree_context_plugin : SceneTreeContextPlugin
var editor2d_context_plugin : Editor2DContextPlugin


const NodePanel = preload("uid://ce48aow1iwynm")
const NODE_PANEL = preload("uid://bxr1c1k422ba2")

const ControlPropertyPanel = preload("uid://bqxhjeqsgqbj8")
const CONTROL_PROPERTY_PANEL = preload("uid://vwhqlqcfov01")

var node_panel :NodePanel
var control_property_panel :ControlPropertyPanel

func _enter_tree() -> void:
	filesystem_context_plugin = FileSystemContextPlugin.new()
	scenetree_context_plugin = SceneTreeContextPlugin.new()
	editor2d_context_plugin = Editor2DContextPlugin.new()
	
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, filesystem_context_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, scenetree_context_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_2D_EDITOR, editor2d_context_plugin)
	
	node_panel = NODE_PANEL.instantiate() as NodePanel
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, node_panel)
	
	control_property_panel = CONTROL_PROPERTY_PANEL.instantiate() as ControlPropertyPanel
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, control_property_panel)
	
	control_property_panel.nodes_panel_button.toggled.connect(func(_tv):
		_update()
	)
	_update()
	
	

func _update():
	node_panel.visible = control_property_panel.nodes_panel_button.button_pressed
	
func _exit_tree() -> void:
	remove_context_menu_plugin(filesystem_context_plugin)
	remove_context_menu_plugin(scenetree_context_plugin)
	remove_context_menu_plugin(editor2d_context_plugin)
		
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, node_panel)
	node_panel.queue_free()
	
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, control_property_panel)
	control_property_panel.queue_free()
