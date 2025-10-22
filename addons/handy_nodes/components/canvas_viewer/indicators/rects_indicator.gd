extends CanvasViewerIndicator

var _rect_datas:=[]

func clear():
	_rect_datas.clear()
	queue_redraw()
	
func add_rect(rect:Rect2, color:Color, fill:=false, width:=-1, fixed_width:=true):
	if width == -1:
		fixed_width = false
	_rect_datas.append({"rect":rect, "color":color, "fill":fill, "width":width, "fixed_width":fixed_width})
	queue_redraw()
	
func update_rect_datas(rect_datas: Array):
	_rect_datas = rect_datas
	queue_redraw()

func _draw_indicator():
	if not _rect_datas:
		return
	var zoom := get_zoom()
	for rect_data in _rect_datas:
		var width = rect_data.get("width",-1) 
		if rect_data.get("fixed_width", true):
			width /= zoom 
		draw_rect(rect_data.rect, rect_data.get("color", Color.BLACK), rect_data.get("fill",false), width)
