class_name ElementViewMapper

var map :Dictionary[String,int]= {}

func clear():
	map.clear()

func bind_element_and_view(id:String, view_id:int):
	map[id] = view_id
	
func unbind_element(id:String):
	map.erase(id)
	
func get_view_id(id:String)->int:
	return map.get(id, 0)
	
func get_view_ids() -> Array:
	return map.values()
	
func get_view_as_instance_id(id:String) -> Object:
	return instance_from_id(map.get(id, 0))
