class_name PipButtonStyleboxs

const NORMAL := "normal"
const PRESSED := "pressed"
const HOVER := "hover"
const DISABLED := "disabled"
const FOCUS := "focus"
const HOVER_PRESSED := "hover_pressed"

static var Empty := StyleBoxEmpty.new()

var styleboxs :Dictionary[String, PipStyleBoxFlat] = {}

func get_stylebox_flat_data() -> Dictionary[String, StyleBoxFlat]:
	var data :Dictionary[String, StyleBoxFlat] = {}
	for key in styleboxs:
		data[key] = styleboxs[key].get_stylebox_flat()
	return data
	
func pip_into(stylebox_key:String) -> PipStyleBoxFlat:
	return styleboxs[stylebox_key].pip_set_collection(self)
	
func pip_normal() -> PipStyleBoxFlat:
	return pip_into(NORMAL)

func pip_pressed() -> PipStyleBoxFlat:
	return pip_into(PRESSED)

func pip_hover() -> PipStyleBoxFlat:
	return pip_into(HOVER)

func pip_disabled() -> PipStyleBoxFlat:
	return pip_into(DISABLED)

func pip_focus() -> PipStyleBoxFlat:
	return pip_into(FOCUS)

func pip_duplicate() -> PipButtonStyleboxs:
	var new_collection = PipButtonStyleboxs.new()
	for key in styleboxs:
		new_collection.styleboxs[key] = styleboxs[key].pip_duplicate()
	return new_collection
	
func pip_bg_color(value:Color, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#bg_color = value
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.bg_color = value
	return self

func pip_draw_center(value:bool, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#draw_center = value
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.draw_center = value
	return self
	
func pip_skew(value:Vector2, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#skew = value
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.skew = value
	return self

func pip_border_width_all(value:int, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#set_border_width_all(value)
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.set_border_width_all(value)
	return self

func pip_border_width(margin: Side, value: int, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#set_border_width(margin, value)
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.set_border_width(margin, value)
	return self
	
func pip_border_color(value:Color, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#border_color = value
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.border_color = value
	return self

func pip_border_blend(value:bool, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.border_blend = value
	return self
	
func pip_border(color:Color, width:int, blend:bool=false, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	pip_border_color(color, excluded)
	pip_border_width_all(width, excluded)
	pip_border_blend(blend, excluded)
	return self

func pip_corner_radius_all(value:int, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#set_corner_radius_all(value)
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.set_corner_radius_all(value)
	return self

func pip_corner_radius(corner: Corner, value: int, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#set_corner_radius(corner, value)
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.set_corner_radius(corner, value)
	return self

func pip_expand_margin_all(value:float, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#set_expand_margin_all(value)
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.set_expand_margin_all(value)
	return self

func pip_expand_margin(margin: Side, value: float, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#set_expand_margin(margin, value)
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.set_expand_margin(margin, value)
	return self
	
func pip_shadow_color(value:Color, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#shadow_color = value
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.shadow_color = value
	return self

func pip_shadow_size(value:int, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#shadow_size = value
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.shadow_size = value
	return self
	
func pip_shadow_offset(value:Vector2, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#shadow_offset = value
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.shadow_offset = value
	return self

func pip_shadow(color:Color, size:int, offset:Vector2, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	pip_shadow_color(color, excluded)
	pip_shadow_size(size, excluded)
	pip_shadow_offset(offset, excluded)
	return self

func pip_content_margin_all(value:float, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#set_content_margin_all(value)
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.set_content_margin_all(value)
	return self
	
func pip_content_margin(margin: Side, value: float, excluded:PackedStringArray=[]) -> PipButtonStyleboxs:
	#set_content_margin(margin, value)
	for key in styleboxs:
		if key in excluded:
			continue
		var styb = styleboxs[key]._stylebox_flat
		styb.set_content_margin(margin, value)
	return self


func test():
	var normal := PipStyleBoxFlat.new().pip_bg_color(Color.BLACK).pip_border_width_all(12).pip_corner_radius_all(16)
	var pressed := normal.pip_duplicate()
	var hover := normal.pip_duplicate()
	var disabled := normal.pip_duplicate()

static func create_base_bottons() -> PipButtonStyleboxs:
	var sbu = PipButtonStyleboxs.new()
	sbu.styleboxs[NORMAL] = PipStyleBoxFlat.new()
	sbu.styleboxs[HOVER] = PipStyleBoxFlat.new()
	sbu.styleboxs[PRESSED] = PipStyleBoxFlat.new()
	sbu.styleboxs[DISABLED] = PipStyleBoxFlat.new()
	return sbu
