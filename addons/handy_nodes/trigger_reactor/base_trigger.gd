class_name BaseTrigger extends Node

signal triggered(data:Dictionary)

@export var trigger_control:Control
@export var trigger_on_ready := false

func _ready() -> void:
	if not trigger_control:
		trigger_control = get_parent()
	trigger_control.tree_exiting.connect(func():
		for cnt in triggered.get_connections():
			triggered.disconnect(cnt.callable)
	)
	connect_trigger()
	if not get_tree().root.is_node_ready():
		await get_tree().root.ready
	if trigger_on_ready:
		var data = {}
		for key in get_meta_list():
			data[key] = get_meta(key)
		raise_trigger()

func raise_trigger(data:Dictionary={}):
	triggered.emit(data)
	
func connect_trigger():
	pass
