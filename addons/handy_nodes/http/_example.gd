
func base_request():
	var url = ""
	var data = {"test":123}
	var maybe_result := await HttpServer.simple_response_request(
			HttpServer.new_http_request_data(url).POST()
			.H_JSON().H_TOKEN("some_token").H_AUTHORIZATION("some_string")
			.set_data(data)
	)
	maybe_result.pprint()
	if maybe_result.is_nothing():
		return false
	var result = maybe_result.get_value()
	return true

func download_file():
	var url = ""
	var file_path := "user://file_path.txt"
	var download_fn := func(downloaded_bytes:int):
		print(downloaded_bytes)
	var maybe_result := await HttpServer.simple_download_file(
			HttpServer.new_http_request_data(url), 
			file_path,
			download_fn
	)
	maybe_result.pprint()
	if maybe_result.is_nothing():
		return false
	return true

func download_image():
	var url = ""
	var maybe_result := await HttpServer.simple_download_image(
			HttpServer.new_http_request_data(url), 
			"png"
	)
	maybe_result.pprint()
	if maybe_result.is_nothing():
		return false
	var image = maybe_result.get_value()
	return true

func loop_request():
	var url = ""
	var thr = HttpServer.new_timer_http_request()
	thr.bind_simple_request(HttpServer.new_http_request_data(url))
	thr.bind_response_complete(func(data:Dictionary):
		print("check_finished:", data)
		# thr.finished.emit()
		# return true # if you want stop timer
	)
	thr.processing.connect(func(data):
		print("processing:", data)
	)
	thr.failed.connect(func(data):
		print("failed:", data)
	)
	thr.start()

func stream_client():
	var stream = HttpServer.new_http_stream_client("https://www.boghma.com", func(response_data:Dictionary):
		print(response_data)
	)
	stream.stream_started.connect(func():
		pass
	)
	stream.stream_ended.connect(func():
		pass
	)
	# call request when needed
	stream.request_stream(
			HttpRequestData.new("/v1/any/request/url")
			.POST()
			.H_JSON()
			.set_data({"requsted": "data"})
		)
