extends Node

signal entry_written(entry)

enum Level {
	DEBUG,  # 最详细的日志信息，典型应用场景是 问题诊断
	INFO,   # 信息详细程度仅次于DEBUG，通常只记录关键节点信息，用于确认一切都是按照我们预期的那样进行工作
	NOTICE, # 提示用户信息
	WARNING,# 当某些不期望的事情发生时记录的信息（如，磁盘可用空间较低），但是此时应用程序还是正常运行的
	ERROR,  # 由于一个更严重的问题导致某些功能不能正常运行时记录的信息
	_CRITICAL,
	_ALERT,
	_EMERGENCY
}

var _file :FileAccess 
var file_path: String
var _level := Level.INFO



#---------------------------------------------------------------------------------------------------
#func _ready():
	#const DEFAULT_FOLDER_PATH: String = "user://auto_logs"
	#DirAccess.make_dir_recursive_absolute(DEFAULT_FOLDER_PATH)
	#file_path = DEFAULT_FOLDER_PATH.path_join("%s.txt")%Time.get_date_string_from_system()
	#set_file_path(file_path)
	
#---------------------------------------------------------------------------------------------------
func set_file_path(value:String):
	file_path = ProjectSettings.globalize_path(value)
	if not FileAccess.file_exists(file_path):
		FileAccess.open(file_path, FileAccess.WRITE).close()
		
#---------------------------------------------------------------------------------------------------
func _process(delta):
	if _file and _file.is_open():
		_file.close()

#---------------------------------------------------------------------------------------------------
func set_level(value:Level):
	_level = value

#---------------------------------------------------------------------------------------------------
func write_entry(entry: Entry) -> void:
	if entry.level < _level:
		return 
	_godot_print(entry)
	_simple_write("\n" + entry.to_string())
	entry_written.emit(entry)

#---------------------------------------------------------------------------------------------------
func debug(message: Variant) -> void:
	# 调试
	write_entry(Entry.new(str(message), Level.DEBUG))
	
#---------------------------------------------------------------------------------------------------
func info(message: Variant) -> void:
	# 常规
	write_entry(Entry.new(str(message), Level.INFO))

#---------------------------------------------------------------------------------------------------
func notice(message: Variant) -> void:
	# 消息
	write_entry(Entry.new(str(message), Level.NOTICE))
	
#---------------------------------------------------------------------------------------------------
func warning(message: Variant) -> void:
	# 警告
	write_entry(Entry.new(str(message), Level.WARNING))

#---------------------------------------------------------------------------------------------------
func error(message: Variant) -> void:
	# 错误
	write_entry(Entry.new(str(message), Level.ERROR))
	_simple_write(_get_stack_string())

#---------------------------------------------------------------------------------------------------
func _simple_write(text:String):
	if not _file or not _file.is_open():
		_file = FileAccess.open(file_path, FileAccess.READ_WRITE)
	_file.seek(_file.get_length())
	_file.store_string(text)
	
#---------------------------------------------------------------------------------------------------
func _get_stack_string():
	var result = ""
	var stacks = get_stack()
	stacks.pop_front()
	for data in stacks:
		result += "\n\t"
		for key in data:
			result += "||  %s : %s  "%[key, str(data[key])]
	return result
	
#---------------------------------------------------------------------------------------------------
func _godot_print(entry: Entry) -> void:
	var text = entry.to_string()
	match entry.level:
		Level.INFO:
			print(text)
		Level.NOTICE:
			print_rich("[color=green]%s[/color]"%text)
		Level.WARNING:
			print_rich("[color=yellow]%s[/color]"%text)
			push_warning(text)
		Level.ERROR:
			print_rich("[color=red]%s[/color]"%text)
			push_error(text)


#---------------------------------------------------------------------------------------------------
class Entry:
	
	var message: String
	var timestamp: Dictionary:
		get: 
			return timestamp.duplicate()
	var level: Level

	func _init(p_message: String, p_level: Level) -> void:
		message = p_message
		level = p_level
		timestamp = Time.get_datetime_dict_from_system()
		
	func _to_string() -> String:
		return "[%s] at %d:%d:%d | %s" % [Entry._level_to_string(level), timestamp["hour"], timestamp["minute"], timestamp["second"], message]

	static func _level_to_string(_level: Level) -> String:
		match _level:
			Level.DEBUG:
				return "Debug"
			Level.INFO:
				return "Info"
			Level.NOTICE:
				return "Notice"
			Level.WARNING:
				return "Warning"
			Level.ERROR:
				return "Error"
			_: 
				return ""
