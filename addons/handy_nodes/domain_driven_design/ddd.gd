class_name DDD

class Presentation: pass # 用户界面层
class Application: # 应用层
	signal domain_event_raised(domain_event: DDD.DomainEvent)
	
	var _infrastructures :Dictionary[GDScript, Object] = {}
	var _services :Dictionary[GDScript, DDD.DomainService] = {}
	
	func register_infrastructure(object: Object):
		_infrastructures[object.get_script()] = object
	
	func get_infrastructure(object_script:GDScript) -> Object:
		return _infrastructures.get(object_script)
	
	func register_service(service: DDD.DomainService):
		_services[service.get_script()] = service
		service.domain_event_raised.connect(handle_domain_event)
	
	func get_service(service_script:GDScript) -> DDD.DomainService:
		return _services.get(service_script)
	
	func handle_domain_event(domain_event: DDD.DomainEvent):
		raise_event(domain_event)
	
	func raise_event(domain_event: DomainEvent):
		domain_event_raised.emit(domain_event)
		
class Domain: pass # 领域层定义接口
class Infrastructure: pass # 基础设施层实现接口

class DomainEvent: # 领域事件驱动
	var _kwargs := {}
	func _init(...args: Array):
		var index = 0
		for arg in self.get_property_list():
			if (arg.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != PROPERTY_USAGE_SCRIPT_VARIABLE:
				continue
			if arg.name.begins_with("_"):
				continue
			self.set(arg.name, args[index])
			assert(self.get(arg.name) == args[index],
					"参数类型必须是一致的，否则 set 会无效 。Array[String] ！= Array"
					)
			index += 1
		
		if index < args.size():
			push_error("not all args being used! %d/%d" % [index, args.size()])
	
	func _to_string():
		return "<DomainEvent::%s::%d>" % [get_event_name(), get_instance_id()]
	
	static func get_event_name() -> String:
		return "DomainEvent"
		
	func add_kwarg(key: String, value: Variant) -> DomainEvent:
		_kwargs[key] = value
		return self
		
	func has_kwarg(key: String):
		return _kwargs.has(key)
	
	func get_kwarg(key: String):
		# 保证调用时这个值一定存在，否则会报错
		return _kwargs[key]

class DomainEventHandler: # 领域事件处理器
	static func connect_event_handler(sender, handler):
		assert(handler.has_method("handle_message"))
		sender.message_sended.connect(func(msg: DomainEvent):
			#prints(sender, "[Send]:", msg, "[To]:", handler)
			handler.handle_message(msg)
		)
	
class DomainService: # 领域服务处理跨边界逻辑(跨聚合)或复杂业务逻辑
	signal domain_event_raised(event: DomainEvent)
	func raise_event(event: DomainEvent):
		domain_event_raised.emit(event)
		
class AggregateRoot: # 管理一组关联对象的根实体,聚合根管理边界内一致性
	signal domain_event_raised(event: DomainEvent)
	var _id:String = UUID.v4()
	func get_id()->String:
		return _id
	func raise_event(event: DomainEvent):
		domain_event_raised.emit(event)
	func serialize() -> Dictionary: 
		return {
			"id" : _id
		}
	func deserialize(_data: Dictionary) -> void: 
		_id = _data.get("id", UUID.v4())
	
class Entity: # 具有唯一标识和生命周期的对象
	var _id:String = UUID.v4()
	func get_id()->String:
		return _id
	func serialize() -> Dictionary: 
		return {
			"id" : _id
		}
	func deserialize(_data: Dictionary) -> void: 
		_id = _data.get("id", UUID.v4())
	
class ValueObject: pass # 无标识，通过属性描述

class Repository:
	static func repository_add_update_time(data: Dictionary) -> Dictionary:
		var ts = Time.get_datetime_string_from_system(false, true)
		data["updated_at"] = ts
		return data
		
	static func split_page(arr: Array, page: int, max_number: int) -> Array:
		if max_number > 0:
			var begin = page * max_number
			var end = begin + max_number
			arr = arr.slice(begin, end)
		return arr
		
	static func get_page_count(arr: Array, max_number: int) -> int:
		if max_number > 0:
			return int(ceil(arr.size() / float(max_number)))
		return 1
	
class Factory: pass


##
class EntityViewMapper:
	# NOTE: Entity.serialize() -> data -> view
	const META_ENTITY_DATA := "META_ENTITY_DATA"
	var map :Dictionary[String,int]= {}
	var _new_view_fn : Callable  # fn() -> Object 
	var _init_view_fn : Callable # fn(view:Object) -> void
	var _convert_data_fn : Callable  # fn(entity) -> Dictionary 
	var _view_update_fn : Callable	# fn(view:Node, entity_data:Dictionary) -> void
	var _view_container : WeakRef	# fn(view:Node, entity_data:Dictionary) -> void
	
	func init_fns(view_container:Node, new_view_fn:Callable, init_view_fn:Callable, convert_data_fn:Callable, view_update_fn:Callable):
		_view_container = weakref(view_container)
		_new_view_fn = new_view_fn
		_init_view_fn = init_view_fn
		_convert_data_fn = convert_data_fn
		_view_update_fn = view_update_fn
	
	func init_views(entities:Array):
		clear()
		for entity in entities:
			create_view(entity)
				
	func update_views(entities:Array):
		for entity in entities:
			update_view(entity)
	
	## 
	func new_view() -> Node:
		return _new_view_fn.call()
	
	func create_view(entity) -> Node:
		return create_view_with_data(_convert_data_fn.call(entity))
		
	func delete_view(entity_id:String):
		if not map.has(entity_id):
			return 
		var view = get_view(entity_id)
		_view_container.get_ref().remove_child(view)
		view.queue_free()
		map.erase(entity_id)
	
	func update_view(entity):
		update_view_with_data(_convert_data_fn.call(entity))
	
	func get_entity_data(view:Node) -> Dictionary:
		return view.get_meta(META_ENTITY_DATA, {})
		
	func get_entity_id(view:Node) -> String:
		return view.get_meta(META_ENTITY_DATA, {}).get("id", "")
	
	func get_view(entity_id:String) -> Object:
		return instance_from_id(map.get(entity_id, 0))
	## 
	func create_view_with_data(entity_data:Dictionary) :
		var entity_id = entity_data.get("id", "")
		if not entity_id:
			printerr("create_view failed:", "entity_data must contain 'id' key with String value")
			return 
		if map.has(entity_id):
			delete_view(entity_id)
		var view = _new_view_fn.call()
		if not view:
			return
		map[str(entity_id)] = view.get_instance_id()
		_view_container.get_ref().add_child(view)
		view.set_meta(META_ENTITY_DATA, entity_data)
		_init_view_fn.call(view)
		_view_update_fn.call(view, entity_data)
		return view
		
	func update_view_with_data(entity_data:Dictionary):
		if not _view_update_fn:
			printerr("update_views failed:", "view_update_fn is invalid")
			return
		var entity_id = entity_data.get("id")
		if not entity_id: 
			printerr("update_views failed:", "entity_data must contain 'id' key with String value")
			return 
		var view = instance_from_id(map.get(entity_id, 0))
		if not view:
			return
		view.set_meta(META_ENTITY_DATA, entity_data)
		_view_update_fn.call(view, entity_data)
		
	func clear():
		map.clear()
		clear_view_container()
		
	func bind_with_id(entity_id:String, view_id:int):
		map[entity_id] = view_id
	
	func unbind_view(entity_id:String):
		map.erase(entity_id)
	
	func clear_view_container():
		var view_container = _view_container.get_ref()
		if not view_container:
			return 
		for view in view_container.get_children():
			view_container.remove_child(view)
			view.queue_free()
	
