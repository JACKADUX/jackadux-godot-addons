class_name CustomRenderer

var rs = RenderingServer

var viewport_id :RID  = rs.viewport_create()
var viewport_canvas_id :RID  = rs.canvas_create()
var canvas_id :RID  = rs.canvas_item_create() 

var _prev_size := Vector2.ZERO

#----------------------------------------------------------------------------------------------------
func _init():
	rs.viewport_set_update_mode(viewport_id, rs.VIEWPORT_UPDATE_DISABLED)  # 设置更新模式
	rs.viewport_set_clear_mode(viewport_id, rs.VIEWPORT_CLEAR_NEVER)
	rs.viewport_set_active(viewport_id, true)  # 激活
	rs.viewport_set_transparent_background(viewport_id, true)
	
	rs.viewport_attach_canvas(viewport_id, viewport_canvas_id)  # 添加 canvas_layer
	rs.canvas_item_set_parent(canvas_id, viewport_canvas_id)

#----------------------------------------------------------------------------------------------------
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(self):
			free_rids()

#----------------------------------------------------------------------------------------------------
func reguler_mode():
	rs.viewport_set_update_mode(viewport_id, rs.VIEWPORT_UPDATE_WHEN_VISIBLE)
	rs.viewport_set_clear_mode(viewport_id, rs.VIEWPORT_CLEAR_ALWAYS)

#----------------------------------------------------------------------------------------------------
func render_next_frame():
	rs.viewport_set_update_mode(viewport_id, rs.VIEWPORT_UPDATE_ONCE)
	rs.viewport_set_clear_mode(viewport_id, rs.VIEWPORT_CLEAR_ONLY_NEXT_FRAME)

#----------------------------------------------------------------------------------------------------
func set_viewport_size(size:Vector2):
	if _prev_size != size:
		_prev_size = size
		rs.viewport_set_size(viewport_id, size.x, size.y) # 设置尺寸

#----------------------------------------------------------------------------------------------------
func clear_canvas():
	rs.canvas_item_clear(canvas_id)

#----------------------------------------------------------------------------------------------------
func get_texture_rid() -> RID:
	return rs.viewport_get_texture(viewport_id)

func get_texture_image() -> Image:
	return rs.texture_2d_get(get_texture_rid())

#----------------------------------------------------------------------------------------------------
func free_rids():
	rs.free_rid(viewport_id)
	rs.free_rid(viewport_canvas_id)
	rs.free_rid(canvas_id)

#----------------------------------------------------------------------------------------------------
func render(draw_fn:Callable) -> Image:
	draw_fn.call(viewport_id, canvas_id)
	rs.viewport_set_update_mode(viewport_id, rs.VIEWPORT_UPDATE_ONCE)
	rs.viewport_set_clear_mode(viewport_id, rs.VIEWPORT_CLEAR_ONLY_NEXT_FRAME)
	await rs.frame_post_draw
	var texture = rs.viewport_get_texture(viewport_id)
	if not texture:
		return 
	return rs.texture_2d_get(texture)
		

static func create_with_reguler() -> CustomRenderer:
	# 会自动保持刷新
	var renderer = CustomRenderer.new()
	renderer.reguler_mode()
	return renderer

##----------------------------------------------------------------------------------------------------
#func draw_fn(viewport:RID, canvas:RID):
	#rs.viewport_set_size(viewport, 400, 400) # 设置尺寸
	#rs.canvas_item_clear(canvas)
	#rs.canvas_item_add_rect(canvas, Rect2(10,10,200,200), Color.AQUA, true)
	#
