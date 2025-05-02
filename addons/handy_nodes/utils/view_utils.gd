class_name ViewUtils

enum Type {
	NONE,
	MIN,
	MAX,
	AVERAGE,
}

static func print_info():
	print(Engine.get_main_loop().root.size)
	print("screen_get_size:",DisplayServer.screen_get_size())
	print("screen_get_dpi:",DisplayServer.screen_get_dpi())
	print("screen_get_max_scale:",DisplayServer.screen_get_max_scale())
	print("screen_get_scale:",DisplayServer.screen_get_scale())

static func get_scale_factor() -> Vector2:
	var screen_size = DisplayServer.screen_get_size()
	var win_size = Engine.get_main_loop().root.size
	return Vector2(screen_size.x/float(win_size.x), screen_size.y/float(win_size.y))

static func auto_content_scale(type:=Type.AVERAGE):
	var factor = get_scale_factor()
	var res = 1.
	match type:
		Type.MIN : res = min(factor.x, factor.y)
		Type.MAX : res = max(factor.x, factor.y)
		Type.AVERAGE : res = (factor.x+factor.y)*0.5
	Engine.get_main_loop().root.content_scale_factor = res
	
static func view_scale(factor:float=1):
	Engine.get_main_loop().root.content_scale_factor *= factor

static func set_view_scale(factor:float=1):
	Engine.get_main_loop().root.content_scale_factor = factor

static func get_view_scale() -> float:
	return Engine.get_main_loop().root.content_scale_factor
