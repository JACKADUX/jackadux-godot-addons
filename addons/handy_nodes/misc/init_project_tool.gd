@tool
extends EditorScript

# TODO: 从github直接下载并初始化项目

func _run() -> void:
	init_files()
	project_setting()
	
func project_setting():
	# NOTE: 用此方法可以直接编辑 project.godot 文件，快速设置项目设置
	var application_custom_setting := {
		"application/run/max_fps": 60,
		"application/run/low_processor_mode": true,
		
		"display/window/size/viewport_width": 1920,
		"display/window/size/viewport_height": 1080,
		"display/window/size/window_width_override": 1280,
		"display/window/size/window_height_override": 720,
		"display/window/stretch/mode": "disabled",
		"display/window/stretch/aspect": "ignore",
		"display/window/dpi/allow_hidpi": false,
		
		"debug/gdscript/warnings/static_called_on_instance":0,
		"debug/gdscript/warnings/incompatible_ternary":0,
	}
	
	_project_setting(application_custom_setting)

	
func init_files():
	var file_system :=  EditorInterface.get_resource_filesystem()
	var dirs := ["scenes", "globals", "misc", "_tests", "assets", "addons", "components", "utils"]
	dirs.append_array(["assets/resources", "assets/fonts", "assets/icons", "assets/shaders", "assets/images"])
	for dir in dirs:
		var path = ProjectSettings.globalize_path("res://"+dir)
		DirAccess.make_dir_recursive_absolute(path)
	file_system.scan()
	
	_project_setting({
		"file_customization/folder_colors": {
			"res://assets/": "yellow",
			"res://_tests/": "red"
		},
	})

## Utils
func _project_setting(custom_setting:Dictionary):
	for key in custom_setting:
		ProjectSettings.set_setting(key, custom_setting[key])
	ProjectSettings.save()
