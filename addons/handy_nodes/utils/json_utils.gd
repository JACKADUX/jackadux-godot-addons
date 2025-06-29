class_name JsonUtils

static func load_meta(json_path):
	if not FileAccess.file_exists(json_path):
		return {}
	var file = FileAccess.open(json_path, FileAccess.READ)
	return JSON.parse_string(file.get_as_text())

static func save_meta(json_path, file_data):
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(file_data))

static func load_meta_native(json_path, allow_objects := false):
	if not FileAccess.file_exists(json_path):
		return {}
	var file = FileAccess.open(json_path, FileAccess.READ)
	return JSON.to_native(JSON.parse_string(file.get_as_text()), allow_objects)

static func save_meta_native(json_path, file_data, full_objects := false):
	var file = FileAccess.open(json_path, FileAccess.WRITE)
	file.store_line(JSON.stringify(JSON.from_native(file_data, full_objects)))


static func stringify(data):
	print(JSON.stringify(data, "\t"))
