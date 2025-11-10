extends Control

@onready var texture_rect: TextureRect = $TextureRect

var image_url := "https://rimage.gnst.jp/livejapan.com/public/article/detail/a/00/00/a0000276/img/basic/a0000276_main.jpg"

class API:
	const ROOT := "https://jsonplaceholder.typicode.com"
	const PHOTOS := ROOT + "/photos"
	const posts := ROOT + "/posts"
	
func _ready() -> void:
	
	var maybe_result = await HttpServer.simple_response_request(
		HttpServer.new_http_request_data(API.PHOTOS)
		.GET()
	)
	var maybe_image = await maybe_result.await_map(func(data:Array):
		var url = data[0].thumbnailUrl
		url = image_url
		var maybe = await HttpServer.simple_download_image(
			HttpServer.new_http_request_data(url)
			, 
			url.get_extension(), 1024*1024*10
		)
		return maybe
	)
	if maybe_image.is_nothing():
		maybe_image.pprint()
		return 
	texture_rect.texture = ImageTexture.create_from_image(maybe_image.get_value())
