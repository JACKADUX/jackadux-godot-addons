@tool
extends EditorPlugin

const CMD_KEY = "JACKADUX/%s"

func register(value:=true):
	var command_palette = EditorInterface.get_command_palette()
	for method in get_script().get_script_method_list():
		if not method.name.begins_with("cmd_"):
			continue
		var cmd_name = method.name.substr(4,-1)
		if value:
			command_palette.add_command(cmd_name, CMD_KEY%cmd_name, Callable(self, method.name))
		else:
			command_palette.remove_command(CMD_KEY%cmd_name)	

func _enter_tree() -> void:
	register(true)

func _exit_tree() -> void:
	register(false)

static func cmd_test():
	print("abc")

static func cmd_plugin_toggler_quick_ui():
	var plugin_name = "quick_ui"
	EditorInterface.set_plugin_enabled(plugin_name, false)
	EditorInterface.set_plugin_enabled(plugin_name, true)

static func cmd_plugin_toggler_namespace_manager():
	var plugin_name = "namespace_manager"
	EditorInterface.set_plugin_enabled(plugin_name, false)
	EditorInterface.set_plugin_enabled(plugin_name, true)
