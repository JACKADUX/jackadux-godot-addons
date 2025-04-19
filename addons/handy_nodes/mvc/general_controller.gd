class_name GeneralController extends Node

@export var model : ModelDataMapper
@export var view:Node
@export var prop_name:String =""

func _ready() -> void:
	if not prop_name:
		return 
	if not view:
		view = get_parent()
	bind_view_model(view, model, prop_name)

# NOTE: 必须满足如下接口信号和方法
# view  -> value_changed    :: signal
#	    -> set_value        :: func
# model -> property_updated :: signal
#	    -> set_value        :: func
#	    -> get_value        :: func
static func bind_view_model(view:Node, model:Object, prop_name:String):
	if not prop_name or not view or not model:
		push_error(view, "prop_name/view/model 不能为空")
		return 
	# 控制器修改模型
	var _on_value_changed := func(value):
		model.set_value(prop_name, value)
	view.value_changed.connect(_on_value_changed)
	# 更新视图
	var _on_property_updated := func(p_prop_name:String, value:Variant):
		if not p_prop_name == prop_name:
			return 
		view.set_value(value)
	model.property_updated.connect(_on_property_updated)
	
	# NOTE: 如果 view 对象在一次性场景里 (比如： PopupPanel)，
	# 		则必须如下断开连接，否则有重复连接信号得风险，也会报错
	view.tree_exited.connect(func():
		model.property_updated.disconnect(_on_property_updated)
		view.value_changed.disconnect(_on_value_changed)
	)
	
	var init_value = func():
		view.set_value(model.get_value(prop_name))
	init_value.call_deferred()
