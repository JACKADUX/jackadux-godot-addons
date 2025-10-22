extends CanvasViewerIndicator

var _views :Array[TextureObject] = []

func clear():
	for view in _views:
		view.clear()
	_views.clear()
	queue_redraw()

func init_views(datas:Array):
	clear()
	for data in datas:
		creat_view(data)
	queue_redraw()
	
func update_views(datas:Array):
	for data in datas:
		var view = get_view(data.get("id",""))
		if not view:
			continue
		update_view(view, data)
	queue_redraw()
	
func creat_view(view_data:Dictionary) :
	var view = TextureObject.create(get_canvas_item())
	update_view(view, view_data)
	_views.append(view)

func update_view(view:TextureObject, view_data:Dictionary):
	"""{
		id:String
		image: Image
		position:Vector2
		scale_factor:float 
		view_rect:Rect2 
		clip_region:false 
	}"""
	view.id = view_data.get("id", "")
	view.set_texture_from_image(view_data.get("image"))
	view.position = view_data.get("position", Vector2.ZERO)
	view.scale_factor = view_data.get("scale_factor", 1)
	view.view_rect = view_data.get("view_rect", Rect2(0,0,0,0))
	view.clip_region = view_data.get("clip_region", false)
	view.queue_redraw()

func get_view(id:String) -> TextureObject:
	for view in _views:
		if view.id == id:
			return view
	return

func _draw() -> void:
	if not _views:
		return
	var xform = get_canvas_xform()
	draw_set_transform_matrix(xform)
	for view:TextureObject in _views:
		view.set_view_transform(xform)
		view.render()

class TextureObject: 
	var _rid :RID 
	var _texture_rid :RID 
	var _texture_size :Vector2 
	var id : String
	var position :Vector2
	var scale_factor :float = 1
	var view_rect := Rect2(0,0,32,32)
	var clip_region := false
	var filter_mode := RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	var _redraw :=true
	
	func _init():
		_rid = RenderingServer.canvas_item_create()
	
	func queue_redraw():
		_redraw = true
	
	func clear():
		RenderingServer.free_rid(_rid)
		RenderingServer.free_rid(_texture_rid)
	
	func get_rid() -> RID:
		return _rid
		
	func get_texture_rid() -> RID:
		return _texture_rid
	
	func set_texture_from_image(image:Image):
		_texture_rid = RenderingServer.texture_2d_create(image) if image else RID()
		_texture_size = image.get_size() if image else Vector2.ZERO
		
	func get_texture_size() -> Vector2:
		return _texture_size
	
	func set_view_transform(xform:Transform2D):
		RenderingServer.canvas_item_set_transform(_rid, xform)
	
	func render():
		if not _redraw:
			return 
		_redraw = false
		RenderingServer.canvas_item_clear(_rid)
		if not _texture_rid:
			return
		RenderingServer.canvas_item_set_default_texture_filter(_rid, filter_mode)
		var rect = Rect2(position, _texture_size)
		var src_rect = Rect2(Vector2.ZERO, _texture_size)
		if clip_region:
			rect = rect.intersection(view_rect)
			src_rect = src_rect.intersection(Rect2(-position, view_rect.size))
		rect.position *= scale_factor
		rect.size *= scale_factor
		RenderingServer.canvas_item_add_texture_rect_region(_rid, rect, _texture_rid, src_rect)

	
	static func create(parent_rid:RID) -> TextureObject:
		var obj = TextureObject.new()
		RenderingServer.canvas_item_set_parent(obj.get_rid(), parent_rid)
		return obj
