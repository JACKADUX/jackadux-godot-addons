extends "../canvas_viewer_indicator.gd"

var _rect_datas:=[]

func clear():
	_rect_datas.clear()
	queue_redraw()
	
func add_rect(rect:Rect2, color:Color, fill:=false, width:=-1):
	_rect_datas.append({"rect":rect, "color":color, "fill":fill, "width":width})
	queue_redraw()
	
func update_rect_datas(rect_datas: Array):
	_rect_datas = rect_datas
	queue_redraw()

func _draw_indicator(zoom: float):
	if not _rect_datas:
		return
	for rect_data in _rect_datas:
		draw_rect(rect_data.rect, rect_data.get("color", Color.BLACK), rect_data.get("fill",false), rect_data.get("width",-1))
