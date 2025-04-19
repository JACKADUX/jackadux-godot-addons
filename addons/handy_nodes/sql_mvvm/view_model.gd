#class_name ViewModel
extends RefCounted

# 遵循 CURD 原则
# 	Create
# 	Update
# 	Read
# 	Delete
const DBManager = preload("res://addons/handy_nodes/sql/dbmanager.gd")
var db_manager: DBManager

signal event_emited(event:String, data:Dictionary)

func _init(db_path: String):
	db_manager = DBManager.new(db_path)
	#_debug_user()

func send_event(event:String, data:={}):
	event_emited.emit(event, data)


#region User
func _debug_user():
	db_manager.app_user.create_user("JACKADUX")
	set_active_user("JACKADUX")

func set_active_user(username: String):
	db_manager.app_user.set_active_user(username)
	db_manager.user_id = db_manager.app_user.get_user_id(username)
	send_event(DBManager.EVENT_INITIALIZE)
	#EventBus.compress_notify(AppConst.EVENT_INITIALIZE)

func get_active_user() -> int:
	if not db_manager.user_id:
		db_manager.user_id = db_manager.app_user.get_active_user_id()
	return db_manager.user_id
#endregion

#region Subjects
func new_subject(type:DBManager.SubjectType, p_name: String, parent_id:int = 0) -> int:
	var subject_data = db_manager.subject.new_subject(p_name, type)
	db_manager.subject.set_user_id(subject_data.id, get_active_user())
	if parent_id != 0:
		db_manager.subject.set_parent_id(subject_data.id, parent_id)
	send_event(DBManager.EVENT_CREATE, get_subject(subject_data.id))
	return subject_data.id

func delete_subject(subject_id:int):
	send_event(DBManager.EVENT_DELETE, {"id": subject_id})
	db_manager.subject.delete_subject(subject_id)

func get_subjects(type:DBManager.SubjectType, parent_id:int) -> Array:
	return db_manager.subject.get_subject_datas_with_type_parent_user(type, parent_id, get_active_user())

func get_subject(subject_id:int) -> Dictionary:
	return db_manager.subject.get_subject_data(subject_id)

func get_subject_to_root(subject_id:int) -> Array:
	# 返回从当前id到根节点的路径 [root_id, ... , subject_id]
	var paths = []
	var parent_id = subject_id
	while true:
		paths.insert(0, parent_id)
		if parent_id == 0:
			break
		parent_id = db_manager.subject.get_parent_id(parent_id)
	return paths

func is_type(subject_id:int, type:DBManager.SubjectType) -> bool:
	var data = db_manager.subject.get_subject_data(subject_id)
	if not data:
		return false
	return data.get("type_id") == type

#endregion

func _new_file(path:String, type:DBManager.FileType, is_cache:=false) -> int:
	return db_manager.file.new_file(path, type, is_cache).id

func new_image_file(path:String) -> int:
	if not FileAccess.file_exists(path) or not ImageUtils.is_image_file(path):
		return 0
	var ids = db_manager.file.find_file(path)
	if not ids:
		return _new_file(path, DBManager.FileType.IMAGE, false)
	else:
		return ids.front().id

func get_subject_file_datas(subject_id:int, tag:String) -> Array:
	return db_manager.subject_file.get_subject_file_datas(subject_id, tag)

func _set_file(subject_id:int, path:String, tag:String):
	var file_ids = db_manager.file.find_file(path)
	if file_ids and db_manager.subject_file.is_existes(subject_id, file_ids.front().id, tag):
		return 
	var file_id = new_image_file(path)
	if not file_id:
		return
	db_manager.subject_file.bind_subject_file(subject_id, file_id, tag)

func set_file(subject_id:int, path:String, tag:String):
	_set_file(subject_id, path, tag)
	send_event(DBManager.EVENT_UPDATE, get_subject(subject_id))

func set_files(subject_id:int, paths:Array, tag:String):
	for path in paths:
		_set_file(subject_id, path, tag)
	send_event(DBManager.EVENT_UPDATE, get_subject(subject_id))
