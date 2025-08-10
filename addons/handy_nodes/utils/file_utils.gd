class_name FileUtils

static func get_file_name_unique(file_path:String, max_counter:= 100) -> String:
	if not FileAccess.file_exists(ProjectSettings.globalize_path(file_path)):
		return file_path
	var basename = file_path.get_basename()
	var extension = file_path.get_extension()
	var counter = 1
	while true:
		# file_path = "basename (counter).extension"
		file_path = ProjectSettings.globalize_path("%s (%d).%s"%[basename, counter, extension])
		if not FileAccess.file_exists(file_path):
			break
		counter += 1
		if counter > max_counter:
			# 如果超出最大值 直接使用当前时间戳保存 
			file_path = "%s (%d).%s"%[basename, Time.get_ticks_usec(), extension]
			break
	return file_path

static func delete_folder(source_folder:String) -> bool:
	assert(DirAccess.dir_exists_absolute(source_folder))
	for file in DirAccess.get_files_at(source_folder):
		DirAccess.remove_absolute(source_folder.path_join(file))
	for folder in DirAccess.get_directories_at(source_folder):
		delete_folder(source_folder.path_join(folder))
	DirAccess.remove_absolute(source_folder)
	return true

static func unzip_file(source_file:String, target_path:String) -> bool:
	assert(DirAccess.dir_exists_absolute(target_path))
	var reader := ZIPReader.new()
	var err := reader.open(source_file)
	if err != OK:
		return false
	var dir_access = DirAccess.open(target_path)
	for file in reader.get_files():
		if file.get_extension():
			file = file.get_base_dir()
		dir_access.make_dir_recursive(file)
	for file in reader.get_files():
		if file.get_extension():
			var file_access = FileAccess.open(target_path.path_join(file),FileAccess.WRITE)
			if not file_access:
				push_error("unzip_file skip '%s'"%[file])
				continue
			file_access.store_buffer(reader.read_file(file))
			file_access.close()
	reader.close()
	return true
	

static var prev_opened_directory :String
static func file_dialog(callback:Callable, title:String="File Dialog", filter=[], mode=DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, current_directory: String="", filename: String=""):
	var _on_folder_selected = func(status:bool, selected_paths:PackedStringArray, _selected_filter_index:int):
		if not status or not selected_paths:
			return 
		var file :String = selected_paths[0]
		if DirAccess.dir_exists_absolute(file):
			prev_opened_directory = file
		else:
			prev_opened_directory = file.get_base_dir()
		callback.call(selected_paths)
	if not prev_opened_directory:
		prev_opened_directory = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	if not current_directory:
		current_directory = prev_opened_directory
	DisplayServer.file_dialog_show(title, current_directory, filename,false,
								mode,
								filter,
								_on_folder_selected)

static func open_folder_dialog(callback:Callable, title:String="Open Dir", current_directory: String=""):
	file_dialog(callback, title, [], DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_DIR, current_directory, "")

static func open_file_dialog(callback:Callable, title:String="Open File", filter=[], current_directory: String="", filename:String=""):
	file_dialog(callback, title, filter, DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILE, current_directory, filename)

static func open_files_dialog(callback:Callable, title:String="Open Files", filter=[], current_directory: String="", filename:String=""):
	file_dialog(callback, title, filter, DisplayServer.FileDialogMode.FILE_DIALOG_MODE_OPEN_FILES, current_directory, filename)

static func save_file_dialog(callback:Callable, title:String="Save File", filter=[], current_directory: String="", filename:String=""):
	file_dialog(callback, title, filter, DisplayServer.FileDialogMode.FILE_DIALOG_MODE_SAVE_FILE, current_directory, filename)

class NaturalSort:
	# NOTE: 加载本地路径的文件时可以按照文件夹中的顺序排序
	var _regex = RegEx.new()

	func _init():
		# 初始化时编译正则表达式，提高性能
		_regex.compile("(\\d+|\\D+)")

	func sort_files(file_list: Array) -> Array:
		file_list.sort_custom(_natural_compare)
		return file_list

	func _natural_compare(a: String, b: String) -> bool:
		var parts_a = _split_filename(a)
		var parts_b = _split_filename(b)
		
		var min_len = min(parts_a.size(), parts_b.size())
		for i in range(min_len):
			var part_a = parts_a[i]
			var part_b = parts_b[i]
			
			var is_num_a = part_a.is_valid_int()
			var is_num_b = part_b.is_valid_int()
			
			if is_num_a and is_num_b:
				# 数值比较
				var num_a = part_a.to_int()
				var num_b = part_b.to_int()
				if num_a != num_b:
					return num_a < num_b
				
				# 数值相等时比较字符串形式（处理前导零）
				if part_a != part_b:
					return part_a < part_b
			else:
				# 类型不同时数字优先
				if is_num_a: return true
				if is_num_b: return false
				
				# 字符串比较
				if part_a != part_b:
					return part_a < part_b
		
		# 处理长度差异
		if parts_a.size() != parts_b.size():
			return parts_a.size() < parts_b.size()
		
		# 最终回退到不区分大小写的完整字符串比较
		return a.to_lower() < b.to_lower()

	func _split_filename(name: String) -> Array:
		var parts = []
		var results = _regex.search_all(name)
		for result in results:
			parts.append(result.get_string().to_lower())
		return parts

	static func sort(files:Array)->Array:
		return NaturalSort.new().sort_files(files)
