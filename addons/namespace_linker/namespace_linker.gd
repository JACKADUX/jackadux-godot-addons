@tool
extends EditorPlugin

var script_editor:ScriptEditor

var utils := NamespaceUtils.new()
var use_shift = false  # 如果想要通过ctrl+shift 来跳转，则改为true

func _enter_tree() -> void:
	script_editor = EditorInterface.get_script_editor()
	script_editor.editor_script_changed.connect(func(script):
		for base in script_editor.get_open_script_editors():
			if base.request_open_script_at_line.is_connected(_on_script_changed):
				continue
			base.request_open_script_at_line.connect(_on_script_changed)
	)
	for base in script_editor.get_open_script_editors():
		base.request_open_script_at_line.connect(_on_script_changed)
	
	
func _on_script_changed(script: Script, line: int):
	if use_shift and not Input.is_key_pressed(KEY_SHIFT):
		return 
	if not is_namespace(script):
		return 
	var lines = script.source_code.rsplit("\n")
	var code = lines[line].strip_edges()
	if not code:
		return
	if utils.is_gd_load(code):
		var gd_path = utils.get_gd_path(code)
		EditorInterface.edit_script.call_deferred(load(gd_path))
		EditorInterface.select_file(gd_path)
		
	elif utils.is_tscn_load(code):
		var tscn_path = utils.get_tscn_path(code)
		EditorInterface.open_scene_from_path(tscn_path)
		EditorInterface.select_file(tscn_path)


func is_namespace(script:Script) -> bool:
	if not script:
		return false
	var base = script.get_base_script()
	return base and base.get_global_name() == "NAMESPACE"


class NamespaceUtils:
	var gds_pattern = r'load\(["\']res://.*.gd["\']\)'
	var gd_path_pattern = r'res://.*.gd'
	var tscn_pattern = r'load\(["\']res://.*.tscn["\']\)'
	var tscn_path_pattern = r'res://.*.tscn'
	
	var regex = RegEx.new()
		
	func is_gd_load(code:String) -> bool:
		# NOTE: load 和 preload都能识别
		regex.compile(gds_pattern)
		var result = regex.search(code)
		if not result:
			return false
		return true
		
	func get_gd_path(code:String) -> String:
		regex.compile(gd_path_pattern)
		var result = regex.search(code)
		if not result:
			return ""
		return result.get_string()
	
	func is_tscn_load(code:String) -> bool:
		regex.compile(tscn_pattern)
		var result = regex.search(code)
		if not result:
			return false
		return true
		
	func get_tscn_path(code:String) -> String:
		regex.compile(tscn_path_pattern)
		var result = regex.search(code)
		if not result:
			return ""
		return result.get_string()
