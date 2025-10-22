@tool
extends EditorPlugin

const FileSystemContextPlugin = preload("uid://dssec8kqvvtsf")
const ScriptEditorContextPlugin = preload("uid://b7fyavsdmbp37")
const SceneTreeContextPlugin = preload("uid://drt3slowysky7")

const UiBuilderPanel = preload("uid://cyfygk2k02nci")
const UI_BUILDER_PANEL = preload("uid://5l7v2vc6hro8")
 

var ui_builder_panel : UiBuilderPanel
var filesystem_context_plugin : FileSystemContextPlugin
var scenetree_context_plugin : SceneTreeContextPlugin
var scripteditor_context_plugin : ScriptEditorContextPlugin
var editor2d_context_plugin : Editor2DContextPlugin

func _enter_tree() -> void:
	ui_builder_panel = UI_BUILDER_PANEL.instantiate()
	filesystem_context_plugin = FileSystemContextPlugin.new()
	scenetree_context_plugin = SceneTreeContextPlugin.new()
	scripteditor_context_plugin = ScriptEditorContextPlugin.new()
	editor2d_context_plugin = Editor2DContextPlugin.new()
	
	#add_control_to_bottom_panel(ui_builder_panel, "UI Builder")
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, filesystem_context_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, scenetree_context_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, scripteditor_context_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_2D_EDITOR, editor2d_context_plugin)
	
	var inspector = EditorInterface.get_inspector()
	inspector.property_edited.connect(scenetree_context_plugin._on_property_edited)
	


func _exit_tree() -> void:
	var inspector = EditorInterface.get_inspector()
	inspector.property_edited.disconnect(scenetree_context_plugin._on_property_edited)
	
	remove_context_menu_plugin(filesystem_context_plugin)
	remove_context_menu_plugin(scenetree_context_plugin)
	remove_context_menu_plugin(scripteditor_context_plugin)
	remove_context_menu_plugin(editor2d_context_plugin)
		
	#remove_control_from_bottom_panel(ui_builder_panel)
	ui_builder_panel.queue_free()


class Editor2DContextPlugin extends EditorContextMenuPlugin:
	func _popup_menu(paths:PackedStringArray):
		return 
		if paths.size() == 1:
			add_context_menu_item("test", func(a): pass)
