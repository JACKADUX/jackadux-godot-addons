@tool
extends EditorPlugin

const ScriptEditorContextPlugin = preload("uid://b7fyavsdmbp37")

var scripteditor_context_plugin : ScriptEditorContextPlugin

func _enter_tree() -> void:
	scripteditor_context_plugin = ScriptEditorContextPlugin.new()
	
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, scripteditor_context_plugin)
	
func _exit_tree() -> void:
	remove_context_menu_plugin(scripteditor_context_plugin)
