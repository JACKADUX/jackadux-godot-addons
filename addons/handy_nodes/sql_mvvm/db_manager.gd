#class_name DBManager

class SQLite: pass  # WARNING : 依赖 SQLite 插件， 下载好 SQLite 插件后删除这行代码

var app_user: AppUser
var subject: Subject
var subject_type: SubjectTypeTable
var file: File
var file_type: FileTypeTable
var subject_file:Subject_File

var db := SQLite.new()
var user_id: int = 0


enum SubjectType {
	PROJECT = 1000,
}

enum FileType {
	IMAGE = 1000,
}

const EVENT_INITIALIZE = "EVENT_INITIALIZE"
const EVENT_CREATE = "EVENT_CREATE"
const EVENT_UPDATE = "EVENT_UPDATE"
const EVENT_DELETE = "EVENT_DELETE"

const trigger_updated_at := """
		CREATE TRIGGER IF NOT EXISTS trigger_{table}_updated_at AFTER UPDATE ON {table}
		BEGIN
			UPDATE {table} SET updated_at = CURRENT_TIMESTAMP WHERE rowid == NEW.rowid;
		END
	"""


func _init(path: String) -> void:
	db.path = path
	db.foreign_keys = true
	db.open_db()
	
	app_user = AppUser.new(db)
	subject_type = SubjectTypeTable.new(db)
	subject = Subject.new(db)
	file_type = FileTypeTable.new(db)
	file = File.new(db)
	subject_file = Subject_File.new(db)
	
func _test_loop():
	# WARNING : query 的调用比较消耗性能，所以尽量避免在for循环中调用，推荐直接使用等效的SQL语法
	var dt = Time.get_ticks_msec()
	for i in range(100): # 7313 ms
		db.query_with_bindings("""
			INSERT INTO test (name, value) VALUES (?, ?)
		""", ["TEST%d"%i, i])
	
	var qu = "INSERT INTO test (name, value) VALUES "
	for i in range(100): # 84 ms
		qu += "('%s', '%d')," % ["TEST%d"%i, i]
	db.query(qu.rstrip(","))
	print(Time.get_ticks_msec() - dt)

## -------------------------------------------------------------------------------------------------
class BaseTable:
	var db: SQLite
	func _init(p_db: SQLite):
		db = p_db
	
	func add_colum_if_not_exists(table_name:String, colum_name:String, column_sql:String):
		# NOTE: 如果在项目发布后新增表的列就使用该方法新增
		db.query("PRAGMA table_info(%s)"%table_name)
		for res in db.query_result:
			if res.name == colum_name:
				return 
		db.query("""
			ALTER TABLE %s
			%s;  -- ADD COLUMN xxx TEXT
		"""%[table_name, column_sql])
		
class AppUser extends BaseTable:
	
	func _init(p_db: SQLite):
		super(p_db)
		#db.drop_table("")
		db.query("""
			CREATE TABLE IF NOT EXISTS app_user (
				id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				username TEXT NOT NULL,
				password TEXT ,
				is_active INTEGER,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
			);
		""")
		
	func has_user(username: String) -> bool:
		db.query_with_bindings("""
			SELECT username FROM app_user WHERE username = (?)
		""", [username])
		return not db.query_result.is_empty()
			
	func create_user(username: String):
		if has_user(username):
			print("用户名已存在")
			return
		db.query_with_bindings("""
			INSERT INTO app_user (username, is_active) VALUES (?,0);
		""", [username, 0])
	
	func get_user_id(username: String) -> int:
		db.query_with_bindings("""
			SELECT id FROM app_user WHERE username = (?);
		""", [username])
		if not db.query_result:
			return -1
		return db.query_result[0].id
	
	func get_active_user_id() -> int:
		db.query("""
			SELECT id FROM app_user WHERE is_active = 1;
		""")
		if not db.query_result:
			return -1
		return db.query_result[0].id
		
	func set_active_user(username: String):
		var user_id = get_user_id(username)
		assert(user_id, "username 无效")
		db.query_with_bindings("""
			UPDATE app_user SET is_active = 0;
			UPDATE app_user SET is_active = 1 WHERE id = (?);
		""", [user_id])
		
class Subject extends BaseTable:
	func _init(p_db: SQLite):
		super(p_db)
		db.query("""
			CREATE TABLE IF NOT EXISTS subject (
				id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
				parent_id INTEGER ,
				user_id INTEGER ,
				type_id INTEGER ,
				name TEXT NOT NULL,
  				metadata TEXT,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				FOREIGN KEY (parent_id) REFERENCES subject (id) ON DELETE CASCADE,
				FOREIGN KEY (user_id) REFERENCES app_user (id) ON DELETE CASCADE,
				FOREIGN KEY (type_id) REFERENCES subject_type (id) ON DELETE CASCADE
			);
		"""
		)
		#add_colum_if_not_exists("subject", "metadata", "ADD COLUMN metadata TEXT")
		
		db.query(trigger_updated_at.format({"table": "subject"}))
	
	func new_subject(p_name: String, type_id: int = 0) -> Dictionary:
		if not p_name:
			return {}
		db.query_with_bindings("""
			INSERT INTO subject (name, type_id) VALUES (?,?);
			SELECT * FROM subject WHERE rowid = last_insert_rowid();
		""", [p_name, type_id])
		return db.query_result[0]
	
	func set_user_id(subject_id: int, user_id:int):
		db.query_with_bindings("""
			UPDATE subject SET user_id = (?) WHERE id = (?)
		""", [user_id, subject_id])
	
	func set_parent_id(subject_id: int, parent_id:int):
		db.query_with_bindings("""
			UPDATE subject SET parent_id = (?) WHERE id = (?)
		""", [parent_id, subject_id])
	
	func get_parent_id(subject_id: int) -> int:
		db.query_with_bindings("""
			SELECT parent_id FROM subject WHERE id = (?)
		""", [ subject_id])
		return db.query_result[0].parent_id if db.query_result[0].parent_id else 0
			
	func get_subject_data(subject_id: int) -> Dictionary:
		db.query("""
			SELECT 
				* ,
				(SELECT COUNT(*) FROM subject WHERE parent_id = subject.id) AS child_count
			FROM 
				subject 
			WHERE 
				id =%d
		""" % [subject_id])
		return db.query_result[0]
	
	func get_subject_datas_with_type_parent_user(type_id: int, parent_id:int, user_id:int) -> Array:
		var sql = """
			SELECT 
				s.*, 
				(SELECT COUNT(*) FROM subject WHERE parent_id = s.id) AS child_count
			FROM 
				subject s
			WHERE 
		"""
		if not parent_id:
			sql += """
				s.type_id =(?) AND s.user_id =(?) AND s.parent_id IS null 
			"""
			db.query_with_bindings(sql, [ type_id, user_id])
		else:
			sql += """
				s.type_id =(?) AND s.user_id =(?) AND s.parent_id =(?)
			"""
			db.query_with_bindings(sql, [ type_id, user_id, parent_id])		
		return db.query_result
	
	func get_all_subject_datas(user_id: int) -> Array:
		db.query("""
			SELECT * FROM subject WHERE user_id =%d
			ORDER BY created_at ASC
		""" % [user_id])
		return db.query_result
	
	func set_name(subject_id: int, p_name: String):
		db.query_with_bindings("""
			UPDATE subject SET name = (?) WHERE id = (?)
		""", [p_name, subject_id])
	
	func delete_subject(subject_id: int):
		return db.query_with_bindings("""
			DELETE FROM subject WHERE id = (?);
		""", [subject_id])
		
class SubjectTypeTable extends BaseTable:

	func _init(p_db: SQLite):
		super(p_db)
		#db.drop_table("subject_type")
		db.query("""
			CREATE TABLE IF NOT EXISTS subject_type (
				id INTEGER PRIMARY KEY NOT NULL,
				name TEXT NOT NULL
			);
		"""
		)
		for id in SubjectType.values():
			var name = SubjectType.find_key(id)
			db.query_with_bindings("""
				INSERT OR IGNORE INTO subject_type (id, name) VALUES (?, ?);
			""", [int(id), name])

			
	func update_order(ordered_ids: Array):
		var case_str = ""
		var ids_str = ",".join(ordered_ids)
		for index in ordered_ids.size():
			var id = ordered_ids[index]
			case_str += "WHEN %d THEN %d\n" % [id, index]
		db.query("""
			BEGIN TRANSACTION;
			UPDATE list
			SET position = CASE id
				%s -- WHEN 1 THEN 3
			END
			WHERE id IN (%s);
			COMMIT;
		""" % [case_str, ids_str])

class File extends BaseTable:

	func _init(p_db: SQLite):
		super(p_db)
		db.query("""
			CREATE TABLE IF NOT EXISTS file (
				id INTEGER PRIMARY KEY NOT NULL,
				path TEXT,
				type_id INTEGER,
				is_cache INTEGER DEFAULT 0,
				metadata TEXT,
				created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
				FOREIGN KEY (type_id) REFERENCES file_type (id) ON DELETE CASCADE
			);
		""")
		#add_colum_if_not_exists("file", "metadata", "ADD COLUMN metadata TEXT")
		db.query(trigger_updated_at.format({"table": "file"}))
		
	func new_file(path:String="", type_id: int = 0, is_cache:bool=false) -> Dictionary:
		db.query_with_bindings("""
			INSERT INTO file (path, type_id, is_cache) VALUES (?,?,?);
			SELECT * FROM file WHERE rowid = last_insert_rowid();
		""", [path, type_id, int(is_cache)])
		return db.query_result[0]
	
	func find_file(path:String) -> Array:
		db.query_with_bindings("""
			SELECT id FROM file WHERE path = (?);
		""", [path])
		return db.query_result
		
class FileTypeTable extends BaseTable:
	
	func _init(p_db: SQLite):
		super(p_db)
		db.query("""
			CREATE TABLE IF NOT EXISTS file_type (
				id INTEGER PRIMARY KEY NOT NULL,
				name TEXT NOT NULL
			);
		""")
		for id in FileType.values():
			var name = FileType.find_key(id)
			db.query_with_bindings("""
				INSERT OR IGNORE INTO file_type (id, name) VALUES (?, ?);
			""", [int(id), name])

class Subject_File extends BaseTable:
	
	func _init(p_db: SQLite):
		super(p_db)
		db.query("""
			CREATE TABLE IF NOT EXISTS subject_file (
				subject_id INTEGER NOT NULL,
				file_id INTEGER NOT NULL,
				tag TEXT
			);
		""")

	func bind_subject_file(subject_id:int, file_id:int, tag:String=""):
		db.query_with_bindings("""
			INSERT INTO subject_file (subject_id, file_id, tag) VALUES (?, ?, ?);
		""", [subject_id, file_id, tag])

	func unbind_subject_file(subject_id:int, file_id:int, tag:String=""):
		db.query_with_bindings("""
			DELETE FROM subject_file WHERE subject_id = (?) AND file_id = (?) AND tag = (?);
		""", [subject_id, file_id, tag])
		
	func get_subject_file_datas(subject_id:int, tag:String="") -> Array:
		db.query_with_bindings("""
			SELECT f.* FROM subject_file sf
			LEFT JOIN file f ON sf.file_id = f.id
			WHERE sf.subject_id = (?) AND sf.tag = (?);
		""", [subject_id, tag])
		return db.query_result

	func is_existes(subject_id:int, file_id:int, tag:String="") -> bool:
		db.query_with_bindings("""
			SELECT COUNT(*) AS count FROM subject_file WHERE subject_id = (?) AND file_id = (?) AND tag = (?);
		""", [subject_id, file_id, tag])
		return db.query_result[0].count > 0
