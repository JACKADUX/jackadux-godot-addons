class_name Reactor extends Node

@export var react_control: Control
@export var animation_trigger : Trigger

@export var fn_pool :GDScript
@export var fn_name: =""
@export var fn_args := []

func _ready() -> void:
	if not animation_trigger:
		animation_trigger = get_parent()
	if not react_control:
		if not animation_trigger.is_node_ready():
			await animation_trigger.ready
		react_control = animation_trigger.trigger_control
	
	if not fn_pool:
		fn_pool = fnPool
	if not fn_pool.has_method(fn_name):
		printerr("fn_name '%s' not exist in fn:%s"%[fn_name, str(fn_pool)])
		return 
	animation_trigger.triggered.connect(func(data:Dictionary):
		Callable(fn_pool, fn_name).call(react_control, fn_args, data)
	)
	

	
