@tool
class_name QuickInitAddons extends EditorScript

func _run() -> void:
	var plugin_name = "lib_linker"
	#var plugin_name = "ui_builder"
	EditorInterface.set_plugin_enabled(plugin_name, false)
	EditorInterface.set_plugin_enabled(plugin_name, true)
