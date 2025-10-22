@tool
class_name QuickExportProject extends EditorScript
# https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html
const godot_path := r"G:\Godot_4_5\Godot_v4.5_mono_win64\Godot_v4.5-stable_mono_win64.exe"


func _run() -> void:
	export_project()

func export_project() -> void:
	var is_debug = true
	var name = "XXX"
	var version = "0.0.0"
	version = version_add_bugfix(ProjectSettings.get_setting("application/config/version", "0.0.0"))
	var main_scene := "res://main.tscn"
	
	var project_dir := r"G:\Godot_4_5\XXX" # .godot所在文件夹
	var export_dir := r"G:\Godot_4_5\XXX\测试版导出" 
	var full_name = name if not is_debug else "内测版_"+name
	var export_name :String= full_name+".exe"
	var export_path = export_dir.path_join(export_name)
	var template_name := "Public" # 导出预设名称
	_save_project_setting(get_export_project_setting(name, version, main_scene))
	execute_export(project_dir, export_path, template_name, is_debug)
	install_zip(full_name, export_dir, version)
	DisplayServer.beep()
	OS.shell_open(export_dir)
	
func execute_export(project_dir:String, export_path:String, template_name:String, is_debug:=true):
	var _export := "debug" if is_debug else "release" 
	var cmd = PackedStringArray([
		"/C",
		godot_path,
		"--headless",
		"--path", project_dir,
		"--export-%s"%_export, template_name,
		export_path
	])
	OS.execute("CMD.exe", cmd, [])
	
func get_export_project_setting(name:String, version:String, main_scene:String):
	return {
		"application/config/name":name,
		"application/config/version":version,
		"application/run/main_scene":main_scene,
	}

func install_zip(full_name:String, path:String, version:String):
	var exe_path := path.path_join(full_name + ".exe")
	var console_path := path.path_join(full_name + ".console.exe")
	var cs_folder = path.path_join("data_xxx_windows_x86_64")
	var export_path = path.path_join("v"+version+"_"+full_name+".zip")
	var writer = FileUtils.SimpleZipper.new()
	var err = writer.open(export_path)
	if err != OK:
		return
	writer.write_file(exe_path)
	if FileAccess.file_exists(console_path):
		writer.write_file(console_path)
	if DirAccess.dir_exists_absolute(cs_folder):
		writer.write_folder(cs_folder)
	writer.close()

func version_add_bugfix(version:String) -> String:
	# NOTE: 快速增量版本号 main.feature.bugfix : 0.1.3 -> 0.1.4
	assert(version and version.count(".") == 2, "version not valid")
	version = version.replace(" ", "").strip_edges()
	var split = version.split(".")
	split[2] = str(int(split[2])+1)
	return ".".join(split)
	
## Utils
func _save_project_setting(custom_setting:Dictionary):
	for key in custom_setting:
		ProjectSettings.set_setting(key, custom_setting[key])
	ProjectSettings.save()
