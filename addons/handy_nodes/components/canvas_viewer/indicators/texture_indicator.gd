extends "../canvas_viewer_indicator.gd"

var _texture: Texture2D

func update_texture(value: Texture2D):
	_texture = value
	queue_redraw()

func _draw_indicator(zoom: float):
	if not _texture:
		return
	_texture.draw(get_canvas_item(), Vector2.ZERO)
