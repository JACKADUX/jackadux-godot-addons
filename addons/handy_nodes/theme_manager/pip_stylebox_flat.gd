class_name PipStyleBoxFlat

var _stylebox_flat := StyleBoxFlat.new()
var _collection : PipButtonStyleboxs

func get_stylebox_flat() -> StyleBoxFlat:
	return _stylebox_flat

func pip_set_collection(collection:PipButtonStyleboxs) -> PipStyleBoxFlat:
	_collection = collection
	return self

func retrieve_collection() -> PipButtonStyleboxs:
	return _collection

func pip_duplicate() -> PipStyleBoxFlat:
	# NOTE: 不知道为什么编辑器中无法直接复制 Resource
	var psbf = PipStyleBoxFlat.new()
	if Engine.is_editor_hint():
		for i in _stylebox_flat.get_property_list():
			if i.usage != 6:
				continue
			psbf._stylebox_flat.set(i.name, _stylebox_flat.get(i.name))
	else:
		psbf._stylebox_flat = _stylebox_flat.duplicate(true)
	return psbf
	
func pip_bg_color(value:Color) -> PipStyleBoxFlat:
	_stylebox_flat.bg_color = value
	return self

func pip_draw_center(value:bool) -> PipStyleBoxFlat:
	_stylebox_flat.draw_center = value
	return self
	
func pip_skew(value:Vector2) -> PipStyleBoxFlat:
	_stylebox_flat.skew = value
	return self

func pip_border_width_all(value:int) -> PipStyleBoxFlat:
	_stylebox_flat.set_border_width_all(value)
	return self

func pip_border_width(margin: Side, value: int) -> PipStyleBoxFlat:
	_stylebox_flat.set_border_width(margin, value)
	return self
	
func pip_border_color(value:Color) -> PipStyleBoxFlat:
	_stylebox_flat.border_color = value
	return self

func pip_border_blend(value:bool) -> PipStyleBoxFlat:
	_stylebox_flat.border_blend = value
	return self

func pip_border(color:Color, width:int, blend:bool=false) -> PipStyleBoxFlat:
	pip_border_color(color)
	pip_border_width_all(width)
	pip_border_blend(blend)
	return self

func pip_corner_radius_all(value:int) -> PipStyleBoxFlat:
	_stylebox_flat.set_corner_radius_all(value)
	return self

func pip_corner_radius(corner: Corner, value: int) -> PipStyleBoxFlat:
	_stylebox_flat.set_corner_radius(corner, value)
	return self

func pip_expand_margin_all(value:float) -> PipStyleBoxFlat:
	_stylebox_flat.set_expand_margin_all(value)
	return self

func pip_expand_margin(margin: Side, value: float) -> PipStyleBoxFlat:
	_stylebox_flat.set_expand_margin(margin, value)
	return self
	
func pip_shadow_color(value:Color) -> PipStyleBoxFlat:
	_stylebox_flat.shadow_color = value
	return self
	
func pip_shadow_size(value:int) -> PipStyleBoxFlat:
	_stylebox_flat.shadow_size = value
	return self
	
func pip_shadow_offset(value:Vector2) -> PipStyleBoxFlat:
	_stylebox_flat.shadow_offset = value
	return self

func pip_shadow(color:Color, size:int, offset:Vector2) -> PipStyleBoxFlat:
	pip_shadow_color(color)
	pip_shadow_size(size)
	pip_shadow_offset(offset)
	return self

func pip_content_margin_all(value:float) -> PipStyleBoxFlat:
	_stylebox_flat.set_content_margin_all(value)
	return self
	
func pip_content_margin(margin: Side, value: float) -> PipStyleBoxFlat:
	_stylebox_flat.set_content_margin(margin, value)
	return self

static func create_stylebox_line(color:Color, thickness:int, vertical:=false, grow_begin:float=1, grow_end:float=1) -> StyleBoxLine:
	var line = StyleBoxLine.new()
	line.color = color
	line.thickness = thickness
	line.vertical = vertical
	line.grow_begin = grow_begin
	line.grow_end = grow_end
	return line
