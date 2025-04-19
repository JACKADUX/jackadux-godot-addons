class_name AwaitBloker

# NOTE: 用来作为 await 信号的中继器
signal continued

## 异步处理
#var blocker = AwaitBloker.new()
#WorkerThreadPool.add_task(func():
	# havey_task()
	# blocker.go_on_deferred()  # call_deferred 否则多线程会报错
#)
#await blocker.continued

## 定时轮询
#WorkerThreadPool.add_task(func():
	#var counter = 0
	#while true:
		#OS.delay_msec(1000)
		#counter += 1
		#prints(OS.get_thread_caller_id(), "thread running...")
#)


func go_on_deferred():
	continued.emit.call_deferred()


	
