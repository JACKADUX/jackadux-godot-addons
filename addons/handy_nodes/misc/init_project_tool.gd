@tool
extends EditorScript

# TODO: 从github直接下载并初始化项目

func _run() -> void:
	init_files()

func init_files():
	var file_system :=  EditorInterface.get_resource_filesystem()
	var dirs := ["scenes", "globals", "misc", "test", "assets", "addons", "components"]
	dirs.append_array(["assets/resources", "assets/fonts", "assets/icons", "assets/shaders"])
	for dir in dirs:
		var path = ProjectSettings.globalize_path("res://"+dir)
		DirAccess.make_dir_recursive_absolute(path)
	file_system.scan()
