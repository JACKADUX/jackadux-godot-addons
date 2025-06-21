class_name FileUtils

static func delet_folder(source_folder:String) -> bool:
	assert(DirAccess.dir_exists_absolute(source_folder))
	for file in DirAccess.get_files_at(source_folder):
		DirAccess.remove_absolute(source_folder.path_join(file))
	for folder in DirAccess.get_directories_at(source_folder):
		delet_folder(source_folder.path_join(folder))
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
