class_name ThreadHelper extends Thread

var _thread_break := true

func bind_with(node:Node):
	node.tree_exiting.connect(func():
		stop()
	)

func new_fns() -> Array[Callable]:
	var fns :Array[Callable]= []
	return fns

func stop():
	if is_started() or is_alive():
		_thread_break = true
		wait_to_finish()

func call_fns(fns:Array[Callable]):
	stop()
	_thread_break = false
	start(func():
		for fn : Callable in fns:
			if _is_thread_break():
				break
			fn.call()
	)

func _is_thread_break() -> bool:
	return _thread_break
