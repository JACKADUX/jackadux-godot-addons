extends CanvasViewerIndicator

@export var rect: Rect2
@export var gap: float
@export var color := Color.RED
@export var rounded := true

func update_rect(_value: Rect2, _gap: float):
	rect = _value
	gap = _gap
	queue_redraw()

func _draw_indicator():
	if gap <= 0:
		return
	if not rect:
		return
	var points: PackedVector2Array = []
	var offset = rect.position
	var x: float = 0
	var y: float = 0
	while rounded:
		if x <= rect.size.x:
			points.append((offset + Vector2(x, 0)).round())
			points.append((offset + Vector2(x, rect.size.y)).round())
			x += gap
		if y <= rect.size.y:
			points.append((offset + Vector2(0, y)).round())
			points.append((offset + Vector2(rect.size.x, y)).round())
			y += gap
		if x > rect.size.x and y > rect.size.y:
			break
			
	while not rounded:
		if x <= rect.size.x:
			points.append(offset + Vector2(x, 0))
			points.append(offset + Vector2(x, rect.size.y))
			x += gap
		if y <= rect.size.y:
			points.append(offset + Vector2(0, y))
			points.append(offset + Vector2(rect.size.x, y))
			y += gap
		if x > rect.size.x and y > rect.size.y:
			break
	draw_multiline(points, color)
