extends CanvasViewerIndicator

var _textures :Array[Texture2D] = []
var _offsets :Array[Vector2] = []
var _scale_factors :Array[float] = []

func clear():
	_textures.clear()
	_offsets.clear()
	_scale_factors.clear()

func add_texture(value: Texture2D, offset:=Vector2.ZERO, scale_factor:float=1):
	_textures.append(value)
	_offsets.append(offset)
	_scale_factors.append(scale_factor)
	queue_redraw()

func _draw_indicator():
	if not _textures:
		return
	for i in _textures.size():
		var _texture = _textures[i]
		var _offset = _offsets[i]
		var _scale_factor = _scale_factors[i]
		var rect = Rect2i(_offset*_scale_factor, _texture.get_size()*_scale_factor)
		_texture.draw_rect(get_canvas_item(), rect, false)
