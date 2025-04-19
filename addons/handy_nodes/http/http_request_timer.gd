class_name HttpRequestTimer extends HTTPRequest
## 用于做轮询调用

signal processing(response)
signal finished(msg:Dictionary)
signal failed(msg:Dictionary)

var timer:Timer
var maybe := Maybe.new()

func start():
	timer.start()

func stop():
	timer.stop()

func bind_simple_request(request_data:HttpRequestData):
	timer.one_shot = true
	timer.timeout.connect(func():
		var error = request(request_data.url, 
							request_data.custom_headers, 
							request_data.method, 
							request_data.request_data
							)
		if error == OK:
			await request_completed
			start()
		else:
			var msg = "[http_request_failed] error:"+error_string(error)
			printerr(msg)
			failed.emit({"msg":msg})
			stop()
	)

func bind_response_complete(finished_fn:=Callable()):
	# fn(maybe_response:Maybe)
	request_completed.connect(func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
		var response = JSON.parse_string(body.get_string_from_utf8())
		if response_code != 200 or not response:
			var data = {"result":result, "response_code":response_code, "response":response}
			data["msg"] = "request_completed_with_failed"
			printerr(data)
			failed.emit(data)
			stop()
			return
		processing.emit(response)
		if finished_fn and finished_fn.call(response):
			stop()
	)

static func create() -> HttpRequestTimer:
	var thr = HttpRequestTimer.new()
	var timer = Timer.new()
	thr.add_child(timer)
	thr.timer = timer
	return thr
