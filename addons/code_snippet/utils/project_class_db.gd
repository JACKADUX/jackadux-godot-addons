#class ProjectClassDB:
extends RefCounted
 
static var _cache_hash := 0
static var _cache := {}

static func get_class_data() -> Dictionary:
	var list = ProjectSettings.get_global_class_list()
	var hash_code = hash(list)
	if hash_code == _cache_hash:
		return _cache
	_cache_hash = hash_code
	_cache = {}
	for d in list:
		_cache[d.class] = d
	return _cache
	
static func list():
	for d in get_class_data().values():
		prints(d.class, d.path, d.base)
		
static func get_data(name:String) -> Dictionary:
	return get_class_data().get(name, {})

static func class_exists(name:String) -> bool:
	return get_class_data().has(name)
