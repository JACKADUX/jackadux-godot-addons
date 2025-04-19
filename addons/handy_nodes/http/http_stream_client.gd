class_name HttpStreamClient extends Node

signal status_changed(status:HTTPClient.Status)
signal stream_started
signal stream_ended
signal err_msg(data:Dictionary)

var client = HTTPClient.new()
var response_buffer: PackedByteArray = PackedByteArray()
var is_streaming: bool = false
var _host := ""
var _response_fn : Callable  # -> bool

var _prev_status := HTTPClient.Status.STATUS_DISCONNECTED

func set_host(host:String):
	_host = host

func set_response_fn(fn:Callable):
	_response_fn = fn

func _state_changed(status:HTTPClient.Status):
	if _prev_status == status:
		return 
	_prev_status = status
	status_changed.emit(status)

func connect_client():
	var err = client.connect_to_host(_host, 443, TLSOptions.client())
	if err != OK:
		var msg = "连接失败:"+error_string(err)
		printerr(msg)
		err_msg.emit({"msg": msg})
		return
	while true:
		client.poll()
		var status = client.get_status()
		_state_changed(status)
		match status:
			HTTPClient.STATUS_CONNECTED:
				#print("连接成功!")
				return
			HTTPClient.STATUS_CANT_RESOLVE, HTTPClient.STATUS_CANT_CONNECT, HTTPClient.STATUS_CONNECTION_ERROR, HTTPClient.STATUS_TLS_HANDSHAKE_ERROR:
				#print("连接失败:",status)
				var msg = "连接请求失败:"+error_string(err)
				printerr(msg)
				err_msg.emit({"msg": msg})
				return
			HTTPClient.STATUS_RESOLVING, HTTPClient.STATUS_CONNECTING:
				await get_tree().create_timer(0.1).timeout  # 避免阻塞主线程
				#prints("正在连接...")
			_:
				#print("无需执行连接...", status)
				return 

func request_stream(reqeust_data:HttpRequestData):
	if client.get_status() == HTTPClient.STATUS_DISCONNECTED:
		await connect_client()
	var err = client.request(reqeust_data.method, reqeust_data.url, reqeust_data.custom_headers, reqeust_data.request_data)
	if err != OK:
		var msg = "请求失败:"+error_string(err)
		printerr(msg)
		err_msg.emit({"msg": msg})
		return
	stream_started.emit()
	is_streaming = true
	
	
func stop_stream():
	client.close()
	is_streaming = false

func _process(delta):
	if !is_streaming:
		return
	client.poll()
	var status = client.get_status()
	_state_changed(status)
	if status == HTTPClient.STATUS_REQUESTING:
		response_buffer.clear()
		
	elif status == HTTPClient.STATUS_BODY:
		if client.has_response():
			if client.get_response_code() != 200:
				var msg = "response_code："+str(client.get_response_code())
				printerr(msg)
				err_msg.emit({"msg": msg})
				
		var chunk = client.read_response_body_chunk()
		if chunk.size() > 0:
			response_buffer += chunk
			if _parse_stream_data():
				is_streaming = false
				response_buffer.clear()
				stream_ended.emit()
	
	elif status == HTTPClient.STATUS_DISCONNECTED:
		is_streaming = false


func _parse_stream_data():
	var text = response_buffer.get_string_from_utf8()
	var lines = text.split("\n")
	for line:String in lines:
		line = line.strip_edges()
		if line.begins_with("data:"):
			var json_str = line.substr(5).strip_edges()
			if json_str == "[DONE]":
				return true
			var json = JSON.new()
			var err = json.parse(json_str)
			if err == OK:
				var data = json.get_data()
				_response_fn.call(data)
				if data:
					# 清理缓冲区
					var processed_length = text.find(line) + line.length() + 1
					response_buffer = response_buffer.slice(processed_length)
			
	return false
	
