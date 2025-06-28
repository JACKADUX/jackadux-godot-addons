#class CodeGenerater:
#var package_paths :PackedStringArray= [
	#"res://addons/package_manager/test_package"
#]

func update(package_paths:PackedStringArray) -> Array:
	var files = []
	for package_path in package_paths:
		if not DirAccess.dir_exists_absolute(package_path):
			continue
		var namespace_file = package_path.path_join("_namespace.gd")
		var namespace_script :GDScript
		if not FileAccess.file_exists(namespace_file):
			namespace_script = GDScript.new()
		else:
			namespace_script = load(namespace_file)
		namespace_script.source_code = generate(package_path)
		ResourceSaver.save(namespace_script, namespace_file)
		files.append(namespace_file)
	return files

func generate(root_path: String) -> String:
	var main_class_name = root_path.get_file().to_pascal_case()
	if not main_class_name:
		return ""
	var output := PackedStringArray()
	_generate_recursive(root_path, root_path, "", output, 0)
	
	if output.size() == 0:
		push_warning("No valid files found for namespace generation in: " + root_path)
		return ""
	
	# 添加文件头
	var header := PackedStringArray()
	header.append("# Auto-generated namespace file. Do not edit manually!")
	header.append("class_name NS_%s extends NAMESPACE"%main_class_name)
	header.append("")
	output = header + output
	var output_str = "\n".join(output)
	return output_str

# 递归生成函数
func _generate_recursive(base_path: String, current_path: String, indent: String, output: PackedStringArray, depth: int) -> void:
	var dir := DirAccess.open(current_path)
	if not dir:
		push_error("Cannot open directory: " + current_path)
		return
	
	# 获取所有文件和子目录
	var files := PackedStringArray()
	var dirs := PackedStringArray()
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			dirs.append(file_name)
		else:
			files.append(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	# 处理文件
	var processed_files := {}
	for f in files:
		# 跳过下划线开头的文件
		if f.begins_with("_"):
			continue
			
		# 只处理 .gd 和 .tscn 文件
		if not f.ends_with(".gd") and not f.ends_with(".tscn"):
			continue
							
		# 获取基本名称（不含扩展名）
		var const_name := f.get_basename().to_pascal_case()
		
		# 处理重复名称
		if processed_files.has(const_name):
			push_warning("Duplicate name detected: " + const_name + " in " + current_path)
			continue
		processed_files[const_name] = true
		
		# 计算相对路径
		var rel_path := current_path.replace(base_path, "").lstrip("/\\")
		if rel_path != "":
			rel_path += "/"
		rel_path += f
		
		# 添加到输出
		output.append(indent + "const " + const_name + " = preload(\"" + rel_path + "\")")
	
	# 处理子目录
	for d in dirs:
		var subdir_path := current_path.path_join(d)
		
		# 检查子目录中是否有 _init.gd 文件
		if not FileAccess.file_exists(subdir_path.path_join("_init.gd")):
			continue
		
		# 添加类定义
		var name_class_name := d.to_pascal_case()
		output.append("")
		output.append(indent + "class " + name_class_name + ":")
		
		# 递归处理子目录（增加缩进）
		var new_indent := indent + "    "
		_generate_recursive(base_path, subdir_path, new_indent, output, depth + 1)
	
