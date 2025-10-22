class_name CanvasViewer extends Control

signal view_changed(view_zoom:float, view_offset:Vector2)
signal mouse_input_data_updated(mouse_input_data:MouseInputData) # NOTE: 只有 InputEventMouse 才会触发

@export var user_camera_controll := true
@export var fit_view_on_resize := false

var texture:Texture2D

var camera_component := CameraComponent.new()

var mouse_input_data_manager:= MouseInputDataManager.new()

var _view_size := Vector2.ONE

func _ready() -> void:
	resized.connect(func():
		if not fit_view_on_resize:
			return 
		fit_view(_view_size)
	)
	mouse_input_data_manager.init_datas(get_viewport())
	
func local_map_to_canvas_global(local_pos:Vector2) -> Vector2:
	#var local_pos = ElementCanvasViewer.get_global_transform().affine_inverse() * get_global_mouse_position()
	# or local_pos = ElementCanvasViewer.get_local_mouse_position()
	return camera_component.get_xform().affine_inverse()*local_pos

func global_map_to_canvas_global(global_pos:Vector2) -> Vector2:
	return local_map_to_canvas_global(get_global_transform().affine_inverse() *global_pos )

func fit_view(page_size:Vector2, factor:float=0.95):
	await get_tree().process_frame

	_view_size = page_size
	var canvas_size = size*factor
	var canvas_offset = (size -canvas_size)*0.5
	if canvas_size.is_zero_approx():
		canvas_size = Vector2.ONE
		#printerr("viewer size 不应该为0，调用calldeferred")
	var w = 0
	var h = 0
	var rel_pos = Vector2.ZERO
	var pg_asp = page_size.aspect()
	if canvas_size.aspect() > pg_asp:
		h = canvas_size.y
		w = h * pg_asp
		rel_pos.x = (canvas_size.x-w)*0.5
	else:
		w = canvas_size.x
		h = w / pg_asp
		rel_pos.y = (canvas_size.y-h)*0.5
	rel_pos += canvas_offset
	var scale_factor = w/page_size.x
	set_zoom(scale_factor, rel_pos*(1/scale_factor))

func set_zoom(zoom:float, view_offset:Vector2):
	camera_component.view_offset = view_offset
	camera_component.view_zoom = zoom
	update_view()

func update_view():
	queue_redraw()
	view_changed.emit(camera_component.view_zoom, camera_component.view_offset)

func set_texture(value:Texture2D):
	texture = value
	queue_redraw()

func set_viewport(viewport:Viewport):
	set_texture(viewport.get_texture())

func set_viewport_texuture(viewport:Viewport):
	await RenderingServer.frame_post_draw
	set_texture(ImageTexture.create_from_image(viewport.get_texture().get_image()))

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_input_data_manager.update_datas(event, local_map_to_canvas_global(get_local_mouse_position()), camera_component.view_zoom)
		for input_data in mouse_input_data_manager.get_datas(event):
			mouse_input_data_updated.emit(input_data)
	if user_camera_controll and CameraComponent.update_with_event(camera_component, event):
		update_view()

func _draw() -> void:
	if not texture:
		return 
	draw_set_transform_matrix(camera_component.get_xform())
	texture.draw(get_canvas_item(), Vector2.ZERO)
	

class CameraComponent:
	
	signal zoom_changed
	signal pan_changed
	
	var ZOOM_INCREMENT := 1.1 
	var MIN_ZOOM_LEVEL := 0.1
	var MAX_ZOOM_LEVEL := 100

	var _pan_active := false
	
	var view_offset := Vector2.ZERO
	var view_zoom :float = 1
	
	func _to_string():
		return "CameraComponent"
		
	func set_pan_active(value:bool):
		_pan_active = value
	
	func is_pan_active():
		return _pan_active
	
	func get_xform() -> Transform2D:
		return Transform2D().translated(view_offset).scaled(Vector2.ONE*view_zoom)
	
	func pan_offset(value:Vector2):
		""" 将摄像机视图中的世界坐标向 Value 方向偏移"""
		view_offset += value/view_zoom
		pan_changed.emit()
		
	func zoom_scroll(step:int, zoom_position:Vector2):
		var local_mouse_position = get_xform().affine_inverse() * zoom_position
		var prev_zoom = view_zoom
		var new_zoom = prev_zoom * pow(ZOOM_INCREMENT, step)
		if new_zoom > MAX_ZOOM_LEVEL or new_zoom < MIN_ZOOM_LEVEL:
			return 
		view_zoom = new_zoom
		view_offset += get_xform().affine_inverse() * zoom_position - local_mouse_position
		zoom_changed.emit()
	
	static func update_with_event(camera_component:CameraComponent, event:InputEvent) -> bool:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_MIDDLE:
				camera_component.set_pan_active(event.is_pressed())
			elif event.button_index in [MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_WHEEL_UP] and event.is_pressed():
				var value = 1 if event.button_index == MOUSE_BUTTON_WHEEL_DOWN else -1
				if Input.is_key_pressed(KEY_CTRL):
					if value > 0:
						camera_component.pan_offset(Vector2(0, -100))
					else:
						camera_component.pan_offset(Vector2(0, 100))
					
				elif Input.is_key_pressed(KEY_SHIFT):
					if value > 0:
						camera_component.pan_offset(Vector2(-100, 0))
					else:
						camera_component.pan_offset(Vector2(100, 0))
				else:
					var lmp = event.position
					if value > 0:
						camera_component.zoom_scroll(-1, lmp)
					else:
						camera_component.zoom_scroll(1, lmp)
				return true
				
		if event is InputEventMouseMotion:
			if camera_component.is_pan_active() and not event.relative.is_zero_approx():
				camera_component.pan_offset(event.relative)
				return true
		return false
