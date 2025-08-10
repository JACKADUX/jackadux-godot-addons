@tool
extends EditorScript

# TODO: 从github直接下载并初始化项目
const event_code :="""
## Domain Events
class SomeEvent extends DDD.DomainEvent:
	static func get_event_name(): return "SomeEvent"
	var prop : String
"""

const interface_code := """
## Domain Interface
@abstract class I_SomeFactory extends DDD.Factory:
	@abstract func create(type:String) -> Object
	@abstract func create_with(data:Dictionary) -> Object
	@abstract func register(gds:GDScript)->void
	
@abstract class I_SomeRepository extends DDD.Repository:
	@abstract func save_object(object:Object) -> void
	@abstract func load_object(object_id:String) -> Dictionary
	@abstract func find_object_by_id(object_id:String) -> Object
"""


const aggregate_root_code := """
## SomeAggregateRoot
extends DDD.AggregateRoot
"""

const path_access_code := """
## PathAccess
extends RefCounted
\"\"\"
root_path/
├── xxx.json
│── foo/
│	└── {foo_id}.json

\"\"\"
var root_path:String

func _init(root_path:String):
	self.root_path = root_path

func create_dirs(dir_path:String):
	if dir_path.get_extension() != "":
		dir_path = dir_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)

func get_foo_dir() -> String:
	return self.root_path.path_join("foo")

func get_foo_data_path(foo_id:String) -> String:
	return get_foo_dir().path_join(foo_id+".json")
"""

const service_code := """
## DomainService
extends DDD.DomainService
"""

func _run() -> void:
	init_domain("pixel_graph", "res://domain")
	
func init_domain(domain:String, root_dir:String):
	# init_domain("image_edit", "res://model")
	var file_system :=  EditorInterface.get_resource_filesystem()
	var dirs := ["aggregate", "infrastructure", "service", "misc"]
	root_dir = root_dir.path_join(domain)
	DirAccess.make_dir_recursive_absolute(root_dir)
	for dir in dirs:
		var path = ProjectSettings.globalize_path(root_dir.path_join(dir))
		if DirAccess.dir_exists_absolute(path):
			# NOTE: 存在的路径都跳过，防止覆盖
			continue
		DirAccess.make_dir_recursive_absolute(path)
		if dir == "misc":
			continue
		ResourceSaver.save(GDScript.new(), path.path_join("_init.gd"))
		match dir:
			"aggregate":
				var script = GDScript.new()
				script.source_code = aggregate_root_code
				ResourceSaver.save(script, path.path_join("some_aggregate.gd"))
			"infrastructure":
				var script = GDScript.new()
				script.source_code = path_access_code
				ResourceSaver.save(script, path.path_join("some_path_access.gd"))
			
			"service":
				var script = GDScript.new()
				script.source_code = service_code
				ResourceSaver.save(script, path.path_join("some_service.gd"))
			
	var files := ["events.gd", "interfaces.gd", "utils.gd", "consts.gd"]
	for file in files:
		var file_path = ProjectSettings.globalize_path(root_dir.path_join(file))
		if FileAccess.file_exists(file_path):
			# NOTE: 存在的路径都跳过，防止覆盖
			continue
		var script := GDScript.new()
		match file:
			"events.gd":
				script.source_code = event_code
			"interfaces.gd":
				script.source_code = interface_code
		ResourceSaver.save(script, file_path)
	
	
	file_system.scan()
