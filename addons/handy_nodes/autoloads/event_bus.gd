extends Node

var counter := {}

#---------------------------------------------------------------------------------------------------
func add(key:String):
	add_user_signal(key)

#---------------------------------------------------------------------------------------------------
func listen(key:String, callback_fn:Callable):
	connect(key, callback_fn)

#---------------------------------------------------------------------------------------------------
func compress_notify(key:String, values=null):
	# 同一个消息在下一帧只通知一次
	if has_user_signal(key):
		counter[key] = values #counter.get_or_add(key, 1) + 1

#---------------------------------------------------------------------------------------------------
func immediate_notify(key:String, values=null):
	if has_user_signal(key):
		if values == null:
			emit_signal(key)
		else:
			emit_signal(key, values)

#---------------------------------------------------------------------------------------------------
func _process(_delta):
	if not counter:
		return
	for key in counter:
		immediate_notify(key, counter[key])
	counter = {}
