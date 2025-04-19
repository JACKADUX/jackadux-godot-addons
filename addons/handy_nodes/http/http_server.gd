class_name HttpServer

# WARNING : 依赖 Maybe / GeneralError / ImageUtils 对象

const GROUP_NAME:="HttpServer"

static var root:Node:
	get: return Engine.get_main_loop().current_scene

static func new_timer_http_request(wait_time:float=1, timeout:=0) -> HttpRequestTimer:
	var thr := HttpRequestTimer.create()
	thr.add_to_group(GROUP_NAME)
	thr.timer.wait_time = wait_time
	thr.timeout = timeout
	root.add_child(thr)
	return thr

static func new_http_request_data(url:String, timeout:float=0) -> HttpRequestData:
	var hr = HTTPRequest.new()
	hr.add_to_group(GROUP_NAME)
	hr.timeout = 60
	root.add_child(hr)
	return HttpRequestData.new(url).set_http_request(hr)

static func new_http_stream_client(host:String, response_fn:Callable) -> HttpStreamClient:
	var hsc = HttpStreamClient.new()
	hsc.add_to_group(GROUP_NAME)
	root.add_child(hsc)
	hsc.set_host(host)
	hsc.set_response_fn(response_fn)
	return hsc

static func simple_request(request_data:HttpRequestData) -> Maybe:
	var hr:HTTPRequest = request_data.http_request
	var maybe := Maybe.new()
	hr.request_completed.connect(func(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
		hr.queue_free()
		maybe.copy(Maybe.Just({"result":result, "response_code":response_code, "headers":headers, "body":body}))
		, 
		CONNECT_ONE_SHOT
	)
	var error = hr.request( request_data.url, 
							request_data.custom_headers, 
							request_data.method, 
							request_data.request_data
							)
	if error == OK:
		await hr.request_completed
	else:
		var msg = "[http_request_failed] error:"+error_string(error)
		maybe = Maybe.Nothing(GeneralError.new(msg))
	return maybe

static func simple_response_request(request_data:HttpRequestData) -> Maybe:
	var maybe = await simple_request(request_data)
	return maybe.map(func(data:Dictionary):
		var response = JSON.parse_string(data.body.get_string_from_utf8())
		if data.response_code != 200 or not response:
			data["response"] = response
			var msg = JSON.stringify(data,"\t")
			printerr(msg)
			return Maybe.Nothing(GeneralError.new(msg, GeneralError.Type.JSON_ERROR))
		return Maybe.Just(response)
	)

static func simple_download_file(request_data:HttpRequestData, file_path:String, callback_fn:=Callable(), chunk_size:=65536) -> Maybe:
	var hr := request_data.http_request
	hr.download_chunk_size = chunk_size
	hr.download_file = file_path
	WorkerThreadPool.add_task(func():
		while true:
			if not is_instance_valid(hr):
				break
			callback_fn.call_deferred(hr.get_downloaded_bytes())
			OS.delay_msec(1000)
	)
	return await simple_request(request_data)

static func simple_download_image(request_data:HttpRequestData, image_extension:String="", chunk_size:=65536) -> Maybe:
	# extension_type -> png/jpg/webp
	request_data.http_request.download_chunk_size = chunk_size
	var maybe = await simple_request(request_data)
	return maybe.map(func(data:Dictionary):
		if data.response_code != 200:
			var msg = JSON.stringify(data,"\t")
			printerr("simple_download_image_failed:",msg)
			return Maybe.Nothing(GeneralError.new(msg, GeneralError.Type.JSON_ERROR))
		var image = ImageUtils.create_image_from_buffer(data.body, image_extension)
		if not image:
			var msg = "create image failed, unknow image type?"
			printerr("simple_download_image:",msg)
			return Maybe.Nothing(GeneralError.new(msg))
		return Maybe.Just(image)
	)
