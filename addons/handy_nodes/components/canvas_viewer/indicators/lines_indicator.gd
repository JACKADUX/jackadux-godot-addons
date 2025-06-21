extends "../canvas_viewer_indicator.gd"

@export var lines: PackedVector2Array
@export var colors: PackedColorArray
@export var width := -1
@export var antialiased := false

func clear():
	lines.clear()
	queue_redraw()

func add_line(p1:Vector2, p2:Vector2, color:Color):
	lines.append(p1)
	lines.append(p2)
	colors.append(color)
	queue_redraw()

func update_lines(p_lines: PackedVector2Array):
	lines = p_lines
	queue_redraw()

func _draw_indicator(zoom: float):
	if not lines:
		return
	draw_multiline_colors(lines, colors, width, antialiased)
