extends "../canvas_viewer_indicator.gd"

@export var points:Array[Dictionary]=[]

func clear():
	points.clear()
	queue_redraw()

func add_point(position:Vector2, radius:float, color:Color, filled:=false, width:=-1, antialiased:=false):
	points.append({
		"position":position,
		"radius":radius,
		"color":color,
		"filled":filled,
		"width":width,
		"antialiased":antialiased
	})
	queue_redraw()

func update_points(p_points: Array):
	points.assign(p_points)
	queue_redraw()

func _draw_indicator(zoom: float):
	if not points:
		return
	for point in points:
		draw_circle(
			point.get("position",Vector2.ZERO),
			point.get("radius",10),
			point.get("color",Color.RED),
			point.get("filled",false),
			point.get("width",-1),
			point.get("antialiased",false)
		)
