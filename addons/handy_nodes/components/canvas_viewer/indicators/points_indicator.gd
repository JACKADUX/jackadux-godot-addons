extends CanvasViewerIndicator

@export var points:Array[Dictionary]=[]

func clear():
	points.clear()
	queue_redraw()

func add_point(p_position:Vector2, radius:float, color:Color, filled:=false, width:=-1, antialiased:=false, fixed_width:=true):
	if width == -1:
		fixed_width = false
	points.append({
		"position":p_position,
		"radius":radius,
		"color":color,
		"filled":filled,
		"width":width,
		"antialiased":antialiased,
		"fixed_width":fixed_width
	})
	queue_redraw()

func update_points(p_points: Array):
	points.assign(p_points)
	queue_redraw()

func _draw_indicator():
	if not points:
		return
	var zoom := get_zoom()
	for point in points:
		var width = point.get("width",-1) 
		if point.get("fixed_width", true):
			width /= zoom 
		draw_circle(
			point.get("position",Vector2.ZERO),
			point.get("radius",10),
			point.get("color",Color.RED),
			point.get("filled",false),
			width,
			point.get("antialiased",false)
		)
