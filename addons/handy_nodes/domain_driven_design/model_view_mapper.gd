# class_name ModelViewMapper

var map :Dictionary[String, int]= {}
const META_MODEL_DATA := "META_MODEL_DATA"

var view_scene : PackedScene

var get_views_fn :Callable  # get_views_fn() -> Array
	# view_manager.get_children()
	
var add_view_fn :Callable  # add_view_fn(view) -> viod
	# view_manager.add_child(view)
	
var remove_view_fn :Callable  # remove_view_fn(view) -> viod
	# view_manager.remove_child(view)
	# view.queue_free()
	
var init_view_fn :Callable  # init_view_fn(view) -> void
	#view.some_signal.connect(func():
		#var model_data = get_view_model_data(view)
		#print(model_data.id)
	#)
	
var convert_data_fn :Callable  # convert_data_fn(model) -> Dictionary
	#return {
		#"id":model.get_id(),
	#}
	
var update_view_fn :Callable  # update_view_fn(view, model_data) -> void
	# view.title = model_data.title

func convert_datas(models:Array) -> Array[Dictionary]:
	var datas : Array[Dictionary] = []
	datas.resize(models.size())
	var index = -1
	for model in models:
		index += 1
		datas[index] = convert_data_fn.call(model)
	return datas

func init_views_with(models:Array):
	init_views(convert_datas(models))

func init_views(model_datas:Array):
	clear_views()
	for model_data :Dictionary in model_datas:
		var view = create_view(model_data.id)
		init_view_fn.call(view)
		update_view(view, model_data)

func update_views_with(models:Array):
	update_views(convert_datas(models))

func update_views(model_datas:Array):
	for model_data:Dictionary in model_datas:
		var view = get_view(model_data.id)
		if not view:
			continue
		update_view(view, model_data)
		
func get_view(id:String) -> Object:
	return instance_from_id(map[id])

func get_view_model_data(view:Object) -> Dictionary:
	return view.get_meta(META_MODEL_DATA)
	
func clear_views():
	for view in get_views_fn.call():
		remove_view_fn.call(view)
	
func create_view(id:String) -> Object:
	var view = view_scene.instantiate()
	map[id] = view.get_instance_id()
	view.set_meta(META_MODEL_DATA, {"id": id})
	add_view_fn.call(view)
	return view

func update_view(view:Object, model_data:Dictionary):
	view.set_meta(META_MODEL_DATA, model_data)
	update_view_fn.call(view, model_data)


class ContainerModelViewMapper extends DDD.ModelViewMapper:
	
	var _container : Node
	
	func init_fns(container:Node, p_view_scene:PackedScene, p_init_view_fn:Callable, p_convert_data_fn:Callable, p_update_view_fn:Callable):
		_container = container
		add_view_fn = func(view):
			_container.add_child(view)
		remove_view_fn = func(view):
			_container.remove_child(view)
			view.queue_free()
		get_views_fn = func():
			return _container.get_children()
		
		view_scene = p_view_scene
		init_view_fn = p_init_view_fn 
		convert_data_fn = p_convert_data_fn 
		update_view_fn = p_update_view_fn
		
