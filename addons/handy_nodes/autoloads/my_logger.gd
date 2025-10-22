#class_name MyLogger
extends Node

signal entry_written(entry: Entry)

enum Level {
	DEBUG,  # 最详细的日志信息，典型应用场景是 问题诊断
	INFO,   # 信息详细程度仅次于DEBUG，通常只记录关键节点信息，用于确认一切都是按照我们预期的那样进行工作
	NOTICE, # 提示用户信息
	WARNING,# 当某些不期望的事情发生时记录的信息（如，磁盘可用空间较低），但是此时应用程序还是正常运行的
	ERROR,  # 由于一个更严重的问题导致某些功能不能正常运行时记录的信息
	CRITICAL,
	ALERT,
	EMERGENCY
}

# 常量定义
const DEFAULT_FOLDER_PATH := "user://logs"
const MAX_FILE_SIZE := 5 * 1024 * 1024  # 5MB 最大文件大小
const MAX_BACKUP_FILES := 5  # 最大备份文件数

# 导出变量，方便在编辑器中配置
@export var enabled := true
@export var log_level: Level = Level.INFO
@export var write_to_file := true
@export var print_to_console := true
@export var max_file_size := MAX_FILE_SIZE
@export var max_backup_files := MAX_BACKUP_FILES

var _file: FileAccess
var file_path: String
var _pending_entries: Array[Entry] = []
#var _is_writing := false

#---------------------------------------------------------------------------------------------------
func _ready() -> void:
	if not enabled:
		return
	# 确保日志目录存在
	DirAccess.make_dir_recursive_absolute(DEFAULT_FOLDER_PATH)
	
	# 生成带时间戳的文件名
	var timestamp := Time.get_datetime_string_from_system().replace(":", "-").replace(" ", "_")
	file_path = DEFAULT_FOLDER_PATH.path_join("log_%s.txt" % timestamp)
	
	# 初始化文件
	_init_log_file()
	
	# 处理延迟的日志条目
	if _pending_entries.size() > 0:
		call_deferred("_write_pending_entries")

#---------------------------------------------------------------------------------------------------
func _exit_tree() -> void:
	if _file and _file.is_open():
		_file.close()

#---------------------------------------------------------------------------------------------------
func _init_log_file() -> void:
	if not write_to_file:
		return
	
	if _file and _file.is_open():
		_file.close()
	
	var err := _open_file()
	if err != OK:
		push_error("Failed to open log file: %s" % file_path)
		write_to_file = false

#---------------------------------------------------------------------------------------------------
func _open_file() -> int:
	_file = FileAccess.open(file_path, FileAccess.WRITE_READ)
	if not _file:
		return FileAccess.get_open_error()
	
	# 移动到文件末尾追加内容
	_file.seek_end()
	return OK

#---------------------------------------------------------------------------------------------------
func set_level(value: Level) -> void:
	log_level = value

#---------------------------------------------------------------------------------------------------
func write_entry(entry: Entry) -> void:
	if not enabled or entry.level < log_level:
		return
	
	if print_to_console:
		_godot_print(entry)
	
	if write_to_file:
		if _file and _file.is_open():
			_safe_write(entry)
		else:
			# 如果文件尚未准备好，暂存日志条目
			_pending_entries.append(entry)
	
	entry_written.emit(entry)

#---------------------------------------------------------------------------------------------------
func _write_pending_entries() -> void:
	for entry in _pending_entries:
		_safe_write(entry)
	_pending_entries.clear()

#---------------------------------------------------------------------------------------------------
func _safe_write(entry: Entry) -> void:
	if not _file or not _file.is_open():
		if _open_file() != OK:
			return
	
	var entry_text := "\n" + entry.to_string()
	_file.store_string(entry_text)
	
	# 检查文件大小并必要时轮转
	if _file.get_position() >= max_file_size:
		_rotate_log_file()

#---------------------------------------------------------------------------------------------------
func _rotate_log_file() -> void:
	if not _file or not _file.is_open():
		return
	
	_file.close()
	
	# 重命名当前文件
	var base_path := file_path.get_basename()
	var ext := file_path.get_extension()
	var new_path := "%s_%s.%s" % [base_path, Time.get_unix_time_from_system(), ext]
	
	DirAccess.rename_absolute(file_path, new_path)
	
	# 清理旧日志文件
	_cleanup_old_logs()
	
	# 重新初始化日志文件
	_init_log_file()

#---------------------------------------------------------------------------------------------------
func _cleanup_old_logs() -> void:
	var dir := DirAccess.open(DEFAULT_FOLDER_PATH)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_names := []
	var file_name := dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension() == "txt" and file_name.begins_with("log_"):
			file_names.append(file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	
	# 按修改时间排序
	file_names.sort_custom(func(a, b): 
		return FileAccess.get_modified_time(DEFAULT_FOLDER_PATH.path_join(a)) > FileAccess.get_modified_time(DEFAULT_FOLDER_PATH.path_join(b))
	)
	
	# 删除超出数量限制的文件
	if file_names.size() > max_backup_files:
		for i in range(max_backup_files, file_names.size()):
			dir.remove(file_names[i])

#---------------------------------------------------------------------------------------------------
func _get_stack_string() -> String:
	var result := ""
	var stack := get_stack()
	stack.pop_front()  # 移除当前函数
	
	for frame in stack:
		result += "\n\tat %s:%d in function %s" % [frame.source, frame.line, frame.function]
	
	return result

#---------------------------------------------------------------------------------------------------
func _godot_print(entry: Entry) -> void:
	var text := entry.to_string()
	
	match entry.level:
		Level.DEBUG:
			print_rich("[color=#888888]%s[/color]" % text)
		Level.INFO:
			print(text)
		Level.NOTICE:
			print_rich("[color=green]%s[/color]" % text)
		Level.WARNING:
			print_rich("[color=yellow]%s[/color]" % text)
			push_warning(text)
		Level.ERROR:
			print_rich("[color=red]%s[/color]" % text)
			push_error(text)
		Level.CRITICAL, Level.ALERT, Level.EMERGENCY:
			print_rich("[color=purple][b]%s[/b][/color]" % text)
			push_error(text)

#---------------------------------------------------------------------------------------------------
func debug(message: Variant) -> void:
	write_entry(Entry.new(str(message), Level.DEBUG))

#---------------------------------------------------------------------------------------------------
func info(message: Variant) -> void:
	write_entry(Entry.new(str(message), Level.INFO))

#---------------------------------------------------------------------------------------------------
func notice(message: Variant) -> void:
	write_entry(Entry.new(str(message), Level.NOTICE))

#---------------------------------------------------------------------------------------------------
func warning(message: Variant) -> void:
	write_entry(Entry.new(str(message), Level.WARNING))

#---------------------------------------------------------------------------------------------------
func error(message: Variant) -> void:
	var full_message := str(message)
	var stack_trace := _get_stack_string()
	write_entry(Entry.new("%s%s" % [full_message, stack_trace], Level.ERROR))

#---------------------------------------------------------------------------------------------------
func critical(message: Variant) -> void:
	var full_message := str(message)
	var stack_trace := _get_stack_string()
	write_entry(Entry.new("%s%s" % [full_message, stack_trace], Level.CRITICAL))

#---------------------------------------------------------------------------------------------------
class Entry:
	var message: String
	var level: Level
	var timestamp: Dictionary
	
	func _init(p_message: String, p_level: Level) -> void:
		message = p_message
		level = p_level
		timestamp = Time.get_datetime_dict_from_system()
	
	func _to_string() -> String:
		var level_str := _level_to_string(level)
		var time_str := "%02d:%02d:%02d" % [timestamp.hour, timestamp.minute, timestamp.second]
		return "[%s] %s | %s" % [level_str, time_str, message]
	
	static func _level_to_string(p_level: Level) -> String:
		match p_level:
			Level.DEBUG: return "DEBUG"
			Level.INFO: return "INFO"
			Level.NOTICE: return "NOTICE"
			Level.WARNING: return "WARNING"
			Level.ERROR: return "ERROR"
			Level.CRITICAL: return "CRITICAL"
			Level.ALERT: return "ALERT"
			Level.EMERGENCY: return "EMERGENCY"
			_: return "UNKNOWN"
