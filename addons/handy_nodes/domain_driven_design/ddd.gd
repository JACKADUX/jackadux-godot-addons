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
		sender.domain_event_raised.connect(func(domain_event: DomainEvent):
			handler.handle_event(domain_event)
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
const ElementIdGroup = preload("element_id_group.gd")
const ModelViewMapper = preload("model_view_mapper.gd")
