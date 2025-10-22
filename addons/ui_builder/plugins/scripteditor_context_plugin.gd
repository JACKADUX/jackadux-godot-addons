#class_name ScriptEditorContextPlugin
extends EditorContextMenuPlugin

const ProjectClassDB = preload("uid://c72n7w0j0tapq")

const common_signal_code = """{0}.{1}.connect(func({2}): pass)"""

func _popup_menu(paths:PackedStringArray):
	if paths.size() != 1:
		return 

	var codeedit :CodeEdit= Engine.get_main_loop().root.get_node(paths[0]);
	var selected_text = codeedit.get_selected_text()
	var theme = EditorInterface.get_base_control()
	var signal_icon = theme.get_theme_icon("Signal", "EditorIcons")
	var signals_icon = theme.get_theme_icon("Signals", "EditorIcons")
	
	if selected_text:
		var res_type = find_type(selected_text, codeedit.text)
		if res_type and ClassDB.class_exists(res_type):
			add_context_submenu_item("Connect Singal Code", create_signal_popup_menu_inner_class(selected_text, res_type, signals_icon), signal_icon)
		elif res_type and ProjectClassDB.class_exists(res_type):
			var data = ProjectClassDB.get_data(res_type)
			if data:
				var gdscript :GDScript = load(data.path)
				var list = gdscript.get_script_signal_list()
				add_context_submenu_item("Connect Singal Code", create_signal_popup_menu_custom_class(selected_text, list, signals_icon), signal_icon)
				
	# Snippet
	var popup_menu = PopupMenu.new()
	popup_menu.add_icon_item(signals_icon, "Signal Lambda", 100)
	#
	var json_path = "res://code_snippet.json"
	var id_start_json = 200
	var id_map := {}
	if FileAccess.file_exists(json_path):
		var datas = JSON.parse_string(FileAccess.get_file_as_string(json_path))
		if datas:
			var index = 0
			for data in datas:
				index += 1
				var id = id_start_json+index
				var icon = theme.get_theme_icon(data.get("icon", ""), "EditorIcons") if data.has("icon") else null
				if icon:
					popup_menu.add_icon_item(icon, data.get("name", "<Unknow>"), id)
				else:
					popup_menu.add_item(data.get("name", "<Unknow>"), id)
				id_map[id] = data
				
	popup_menu.id_pressed.connect(func(id):
		var t_indent = get_tab_indent(codeedit)
		var t_indent_str = "\t".repeat(t_indent)
		var caret_line = codeedit.get_caret_line()
		var caret_column = codeedit.get_caret_column()
		match id:
			100:
				var final_code :=common_signal_code.format(["object","value_changed","...args:Array"])
				codeedit.insert_line_at(caret_line, final_code)
				codeedit.set_caret_line(caret_line)
		if id >= id_start_json:
			var data = id_map.get(id, {})
			var final_code = data.get("code", "")
			if final_code:
				codeedit.insert_text(final_code, caret_line, caret_column)
				codeedit.set_caret_line(caret_line)
	)
	add_context_submenu_item("Code Snippet", popup_menu)

func create_signal_popup_menu_inner_class(object:String, name_class:String, signals_icon:Texture2D):
	var popup_menu = PopupMenu.new()
	var id_map := {}
	var pop_id = 100
	while name_class:
		var signal_list = ClassDB.class_get_signal_list(name_class, true)
		if signal_list: 
			popup_menu.add_separator(name_class)
		for signal_data in signal_list:
			pop_id += 1
			var label = signal_data.name
			var args:=""
			if signal_data.args:
				for arg in signal_data.args:
					var ts = type_string(arg.type) if not arg.class_name else arg.class_name
					args += arg.name +": "+ts+", "
				args = args.trim_suffix(", ")
				label += "(%s )"%args
			id_map[pop_id] = {"name":signal_data.name, "args":args }
			popup_menu.add_icon_item(signals_icon, label, pop_id)
		name_class = ClassDB.get_parent_class(name_class)
		
	popup_menu.id_pressed.connect(func(id):
		var signal_data = id_map[id]
		var final_code :=common_signal_code.format([object, signal_data.name,signal_data.args])
		DisplayServer.clipboard_set(final_code)
		EditorInterface.get_editor_toaster().push_toast("signal code copied!")
	)
	return popup_menu
	
func create_signal_popup_menu_custom_class(object:String, signal_list:Array, signals_icon:Texture2D):
	var id_map := {}
	var popup_menu = PopupMenu.new()
	var pop_id = 100
	for signal_data in signal_list:
		pop_id += 1
		var label = signal_data.name
		var args:=""
		if signal_data.args:
			for arg in signal_data.args:
				var ts = type_string(arg.type) if not arg.class_name else arg.class_name
				args += arg.name +": "+ts+", "
			args = args.trim_suffix(", ")
			label += "(%s )"%args
		id_map[pop_id] = {"name":signal_data.name, "args":args }
		popup_menu.add_icon_item(signals_icon, label, pop_id)
	popup_menu.id_pressed.connect(func(id):
		var signal_data = id_map[id]
		var final_code :=common_signal_code.format([object,signal_data.name,signal_data.args])
		DisplayServer.clipboard_set(final_code)
		EditorInterface.get_editor_toaster().push_toast("signal code copied!")
	)
	return popup_menu
	
func get_tab_indent(codeedit:CodeEdit) -> int:
	var line = codeedit.get_caret_line()
	var indent = codeedit.get_indent_level(line)
	var tabsize = codeedit.get_tab_size()
	return indent/tabsize
		 
func find_type(a: String, b: String) -> String:
	if not a:
		return ""
	# 构建正则表达式模式
	# 转义用户输入的字符串a，防止其中有特殊字符
	var escaped_a = a.strip_escapes()
	# 模式解释：a后面跟着可选的空格、冒号、可选的空格，然后捕获非空的类型字符（直到行尾或下一个不合适字符）
	var pattern = escaped_a + "\\s*:\\s*(\\w+)\\s*"
	
	var regex = RegEx.new()
	var compile_result = regex.compile(pattern)
	if compile_result != OK:
		push_error("Failed to compile regex: " + pattern)
		return ""
	
	var match_result = regex.search(b)
	if match_result:
		# 返回第一个捕获组（分组1），即类型字符串
		return match_result.get_string(1)
	else:
		return ""	
		
func test(codeedit:CodeEdit):
	var theme = EditorInterface.get_base_control()
	var icon = theme.get_theme_icon("Node", "EditorIcons")
	#print(codeedit.get_selected_text())
	#print(codeedit.get_gutter_count())
	#print(codeedit.get_caret_line())
	var gutter = -1
	var gutter_name := "custom_gutter_test"
	for i in codeedit.get_gutter_count():
		if gutter_name == codeedit.get_gutter_name(i):
			gutter = i
			break
	if not has_meta("line_gutter_count"):
		set_meta("line_gutter_count", 0)
	var line_gutter_count = get_meta("line_gutter_count")
	if line_gutter_count == 0:
		codeedit.add_gutter(gutter)
		gutter = codeedit.get_gutter_count()-1
		codeedit.set_gutter_name(gutter, gutter_name)
		codeedit.set_gutter_type(gutter, TextEdit.GUTTER_TYPE_ICON)
		codeedit.gutter_clicked.connect(func(line: int, clicked_gutter: int):
			if gutter != clicked_gutter:
				return 
			prints(line, gutter)
		)
	var line = codeedit.get_caret_line()
	if not codeedit.is_line_gutter_clickable(line, gutter):
		codeedit.set_line_gutter_clickable(line, gutter, true)
		codeedit.set_line_gutter_icon(line, gutter, icon)
		line_gutter_count += 1
	else:
		codeedit.set_line_gutter_clickable(line, gutter, false)
		codeedit.set_line_gutter_icon(line, gutter, null)
		line_gutter_count -= 1
		if line_gutter_count == 0:
			codeedit.remove_gutter(gutter)
	set_meta("line_gutter_count", line_gutter_count)
