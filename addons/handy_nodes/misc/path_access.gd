class_name PathAccess

static func get_root_path() -> String:
	if OS.has_feature("editor"):
		return "" # debug_root_path
	return OS.get_executable_path().get_base_dir() 

static func get_resource_path() -> String:
	return get_root_path() + "/resource"
