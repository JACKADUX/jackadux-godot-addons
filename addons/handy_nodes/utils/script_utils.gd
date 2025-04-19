class_name ScriptUtils

#var obj = SomeClass.new()
#var script = obj.get_script()
#print(obj is SomeClass)  -> true
#print(script.instance_has(obj)) -> true

# print(SomeClass.get_global_name())  # 不行
# print((SomeClass as Script).get_global_name())  # 可以！


# print(ScriptUtils.get_class_name(Node.new())) -> "Node"
# print(ScriptUtils.get_class_name(SomeClass.new())) -> "SomeClass"
# print(ScriptUtils.get_class_name(SomeClass.SubClass.new()))  -> "SubClass"

static func create_with_args(script:Script, args:=[]):
	var obj = script.new()
	var proplist = inst_to_dict(obj).keys()
	for index in args.size():
		obj.set(proplist[index+2], args[index])
	return obj

static func create_with_kwargs(script:Script, kwargs:={}):
	var obj = script.new()
	for key in kwargs.keys():
		obj.set(key, kwargs[key])
	return obj

static func get_class_name(object:Object) -> String:
	var script:Script = object.get_script()
	if not script:
		return object.get_class()
	var classname = script.get_global_name()
	if classname:
		return classname
	return inst_to_dict(object).get("@subpath", "")


static func script_info(script:Script):
	print("get_script_constant_map ==")
	print(JSON.stringify(script.get_script_constant_map(),"\t"))
	print("get_script_property_list ==")
	print(JSON.stringify(script.get_script_property_list(),"\t"))
	print("get_script_method_list ==")
	print(JSON.stringify(script.get_script_method_list(), "\t"))
