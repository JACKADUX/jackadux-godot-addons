class_name HttpRequestData

var http_request:HTTPRequest
var url:String
var custom_headers: PackedStringArray = PackedStringArray()
var method:= HTTPClient.METHOD_GET
var request_data:String=""

const HEADER_JSON := "Content-Type: application/json"
const HEADER_TOKEN := "token: %s"
const HEADER_AUTHORIZATION := "Authorization: Bearer %s"

func _init(url:String):
	self.url = url

func _to_string() -> String:
	return JSON.stringify({
		"http_request":http_request,
		"url":url,
		"custom_headers":custom_headers,
		"method":method,
		"request_data":request_data,
	})
	
func set_http_request(http_request:HTTPRequest) -> HttpRequestData:
	self.http_request = http_request
	return self

func GET() -> HttpRequestData:
	method = HTTPClient.METHOD_GET
	return self

func POST() -> HttpRequestData:
	method = HTTPClient.METHOD_POST
	return self

func PUT() -> HttpRequestData:
	method = HTTPClient.METHOD_PUT
	return self

func PATCH() -> HttpRequestData:
	method = HTTPClient.METHOD_PATCH
	return self

func join_header(header:String) ->HttpRequestData:
	custom_headers.append(header)
	return self

func H_JSON() -> HttpRequestData:
	if HEADER_JSON not in custom_headers:
		custom_headers.append(HEADER_JSON)
	return self

func H_TOKEN(token:String) -> HttpRequestData:
	var value = HEADER_TOKEN%token
	if value not in custom_headers:
		custom_headers.append(value)
	return self

func H_AUTHORIZATION(authorization:String) -> HttpRequestData:
	var value = HEADER_AUTHORIZATION%authorization
	if value not in custom_headers:
		custom_headers.append(value)
	return self

func set_body(data:String) -> HttpRequestData:
	request_data = data
	return self
	
func set_data(data:Dictionary) -> HttpRequestData:
	request_data = JSON.stringify(data, "\t")
	return self
