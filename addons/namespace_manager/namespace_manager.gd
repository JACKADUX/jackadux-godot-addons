@tool
extends EditorPlugin

var script_editor:ScriptEditor

var use_shift = false  # 如果想要通过ctrl+shift 来跳转，则改为true
const ResourcePathHelper = preload("misc/resource_path_helper.gd")

var resource_path_helper := ResourcePathHelper.new()

const NAMESPACE_PANEL = preload("namespace_panel/namespace_panel.tscn")
const NamespacePanel = preload("namespace_panel/namespace_panel.gd")
var namespace_panel :NamespacePanel


func _enter_tree() -> void:
	script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.connect(_update_connections.unbind(1))
	_update_connections()
	
	namespace_panel = NAMESPACE_PANEL.instantiate()
	add_control_to_bottom_panel(namespace_panel, "Namespace Manager")
	
	#add_custom_type("CanvasViewer", "Control", preload("xx.gd"), icon)

func _exit_tree() -> void:
	remove_control_from_bottom_panel(namespace_panel)
	namespace_panel.queue_free()

func _update_connections():
	# NOTE: 只有绑定了才能获取变化的信号
	for base in script_editor.get_open_script_editors():
		if base.request_open_script_at_line.is_connected(_on_script_changed):
			continue
		base.request_open_script_at_line.connect(_on_script_changed)

func _on_script_changed(script: Script, line: int):
	# NOTE: 找到对应的文件并打开
	if not script:
		return 
	if use_shift and not Input.is_key_pressed(KEY_SHIFT):
		return 
	var base = script.get_base_script()
	if not base or base.get_global_name() != "NAMESPACE":
		return 
		
	var lines = script.source_code.rsplit("\n")
	var code = lines[line].strip_edges()
	if not code:
		return
		
	if resource_path_helper.is_gd_load(code):
		var gd_path = resource_path_helper.get_gd_path(code)
		if not gd_path.begins_with("res://"):
			gd_path = script.resource_path.get_base_dir().path_join(gd_path)
		EditorInterface.edit_script.call_deferred(load(gd_path))
		EditorInterface.select_file(gd_path)
		
	elif resource_path_helper.is_tscn_load(code):
		var tscn_path = resource_path_helper.get_tscn_path(code)
		if not tscn_path.begins_with("res://"):
			tscn_path = script.resource_path.get_base_dir().path_join(tscn_path)
		EditorInterface.open_scene_from_path(tscn_path)
		EditorInterface.select_file(tscn_path)
