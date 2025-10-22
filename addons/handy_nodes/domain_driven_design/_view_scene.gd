extends PanelContainer

## Controller --------------------------------------------------------------
var view_container : Node
var scene :PackedScene
var model_view_mapper := DDD.ModelViewMapper.ContainerModelViewMapper.new()

var controller:Object

func init_with_controller(p_controller:Object):
	controller = p_controller
	bind_with_controller()
	controller.domain_event_raised.connect(handle_controller_event)
	## init views
	# entity_view_mapper.init_views_with(controller.__get_entities())
	## update views
	# entity_view_mapper.update_views_with(controller.__get_entities())

func bind_with_controller():
	# button.pressed.connect(func(): app_controller.do_something())
	model_view_mapper.init_fns(view_container, scene
			,
		func init_view_fn(view:Button): 
			view.pressed.connect(func():
				# WARNING: 如果需要处理交互反馈，这里必须要用 entity_view_mapper.get_view_model_data() 方法获取最新 entity_data
				var entity_data = model_view_mapper.get_view_model_data(view)
				print(entity_data.get("id", ""))
			)
			,
		func convert_data_fn(entity): 
			return {
				"id":entity.get_id(),
				"title":entity.get_title(),
			}
			,
		func view_update_fn(view:Node, data:Dictionary): 
			view.title = data.get("title", "")
	)

func handle_controller_event(domain_event:DDD.DomainEvent):
	#if domain_event is NS_YourNameSpace.Events.AnyEvent:
	#	do_something
	pass

## 
