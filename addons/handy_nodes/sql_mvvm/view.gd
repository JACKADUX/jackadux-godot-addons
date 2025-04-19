extends PanelContainer

const DBManager = preload("res://addons/handy_nodes/sql/dbmanager.gd")
const ViewModel = preload("res://addons/handy_nodes/sql/view_model.gd")
var view_model : ViewModel


## VIEW MODEL
func set_view_model(p_view_model:ViewModel):
	if not p_view_model.get_active_user():
		push_error("需要先创建user")
		return 
	view_model = p_view_model
	_bind_view_signals()
	_bind_view_model_signals()
	_init_items()

func _bind_view_model_signals():
	view_model.event_emited.connect(func(event:String, data:Dictionary):
		match event:
			DBManager.EVENT_CREATE:
				_new_item(data)
			DBManager.EVENT_DELETE:
				_delete_item(data.id)
			DBManager.EVENT_UPDATE:
				_init_items()
	)

func _bind_view_signals():
	pass
	#new_project_button.pressed.connect(func():
		#view_model.new_subject(DBManager.SubjectType.PROJECT, "未命名项目", id_path.back())
	#)
	
## VIEW  
func _init_items():
	#datas = view_model.get_subjects(DBManager.SubjectType.PROJECT, parent_id)
	pass

func _init_items_with(datas:Array):
	# default_block.container_agent.clear()
	for data in datas:
		_new_item(data)

func _new_item(data:Dictionary):
	return 

func _delete_item(id:int):
	var item = _get_item(id)
	if not item:
		return 
	item.delete()

func _get_item(id:int):
	return null
