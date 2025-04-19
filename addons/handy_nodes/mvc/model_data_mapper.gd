class_name ModelDataMapper extends Resource

signal property_updated(p_prop_name:String, value:Variant)

var module_caller := {}

func register(key:String, setter:Callable, getter:Callable):
	if module_caller.has(key):
		push_warning("key:'%s' already exist in ModelDataMapper"%key)
		return 
	module_caller[key] = {"setter":setter, "getter":getter}

func register_with(object:Object, key:String):
	register(key, 
		func(value): object.set(key, value),
		func(key): return object.get(key)
	)

func set_value(key:String, value:Variant):
	if not module_caller.has(key):
		printerr("ModelDataMapper not has key called: '%s'"%key)
		return
	var res = module_caller[key].setter.call(value)
	if res == false:
		return 
	property_updated.emit(key, value)
	
func get_value(key:String, default:Variant=null) -> Variant:
	if not module_caller.has(key):
		printerr("ModelDataMapper not has key called: '%s'"%key)
		return
	var res = module_caller[key].getter.call(key)
	return default if res == null else res
