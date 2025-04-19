class_name Reactor extends Node

@export var react_control: Control
@export var trigger : Trigger

@export var fn_pool :GDScript
@export var fn_name: =""
@export var fn_args := []

func _ready() -> void:
	if not trigger:
		trigger = get_parent()
	if not react_control:
		if not trigger.is_node_ready():
			await trigger.ready
		react_control = trigger.trigger_control
	
	if not fn_pool:
		fn_pool = fnPool
	if not fn_pool.has_method(fn_name):
		printerr("fn_name '%s' not exist in fn:%s"%[fn_name, str(fn_pool)])
		return 
	trigger.triggered.connect(func(data:Dictionary):
		Callable(fn_pool, fn_name).call(react_control, fn_args, data)
	)
	

	
