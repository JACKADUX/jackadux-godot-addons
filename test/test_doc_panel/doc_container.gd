@tool
class_name DocContainer extends Container

const DocSplitContainer = preload("uid://erikvv868evt")

var _widget_size := Vector2(24, 24)
var _rect_bar : Rect2 :
	get: return Rect2(_widget_size.x, 0, size.x - _widget_size.x, _widget_size.y).abs()
var _rect_main : Rect2:
	get: return Rect2(0, _widget_size.y, size.x, size.y-_widget_size.y).abs()
	
@export var style_box : StyleBoxFlat
@export var widget_icon : Texture2D

var _inside_flag = false

const GROUP_ID_DOC := "__DOCCONTAINER_GROUP_ID__JACKADUX"
	
func _enter_tree() -> void:
	add_to_group(GROUP_ID_DOC)

func _exit_tree() -> void:
	remove_from_group(GROUP_ID_DOC)

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_editor_processing()
	
func _get_minimum_size() -> Vector2:
	var rect = Rect2(Vector2.ZERO, _widget_size)
	for child : Control in get_children():
		if not child.is_visible_in_tree(): 
			continue
		rect = rect.merge(child.get_rect())
	return rect.size

func _get_allowed_size_flags_horizontal() -> PackedInt32Array:
	return PackedInt32Array([SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END, SIZE_FILL])

func _get_allowed_size_flags_vertical() -> PackedInt32Array:
	return PackedInt32Array([SIZE_SHRINK_BEGIN, SIZE_SHRINK_CENTER, SIZE_SHRINK_END, SIZE_FILL])

func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_fit_size()

func _draw() -> void:
	#draw_rect(_rect_bar, Color.RED, false, 2)
	#draw_rect(_rect_main, Color.BLUE, false, 2)
	if style_box:
		draw_style_box(style_box, Rect2(Vector2.ZERO, size))
	if widget_icon:
		draw_texture_rect(widget_icon, Rect2(Vector2.ZERO, _widget_size), false)
	if _inside_flag:
		var area_index = get_area_index()
		var full_rect = _rect_main
		var gx = -full_rect.size.x *0.3
		var gy = -full_rect.size.y *0.3
		var rect = full_rect.grow_individual(gx, gy, gx, gy)
		var f_points = RectUtils.create_points_from_rect(full_rect)
		var c_points = RectUtils.create_points_from_rect(rect)
		match area_index:
			0: draw_rect(rect, Color.BLUE_VIOLET, false, 2)
			1: draw_polyline([f_points[0], c_points[0], c_points[3], f_points[3], f_points[0]], Color.TOMATO, 2)
			2: draw_polyline([f_points[0], f_points[1], c_points[1], c_points[0], f_points[0]], Color.TOMATO, 2)
			3: draw_polyline([f_points[1], f_points[2], c_points[2], c_points[1], f_points[1]], Color.TOMATO, 2)
			4: draw_polyline([f_points[2], f_points[3], c_points[3], c_points[2], f_points[2]], Color.TOMATO, 2)
		
	
##
func get_area_index() -> int:
	#   2
	# 1 0 3
	#   4
	var mp = get_local_mouse_position()
	var full_rect = _rect_main
	if not full_rect.has_point(mp):
		return -1
	var gx = -full_rect.size.x *0.3
	var gy = -full_rect.size.y *0.3
	var rect = full_rect.grow_individual(gx, gy, gx, gy)
	if rect.has_point(mp) and get_child_count() == 0:
		return 0
	var parent = _get_doc_ancestor()
	if not parent:
		if get_child_count() == 0:
			return 0
		else:
			return -1
	var v1 = (mp - full_rect.get_center())
	var f_ratio = full_rect.size.abs().aspect()
	var p_ratio = v1.abs().aspect()
	if p_ratio > f_ratio: #x
		return 1 if v1.x < 0 else 3
	else:
		return 2 if v1.y < 0 else 4

var _pressed := false
var _gnodes = []
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var mp = get_local_mouse_position()
			if mp.x > _widget_size.x or mp.y > _widget_size.y:
				return 
			_pressed = true
			_gnodes = get_tree().get_nodes_in_group(GROUP_ID_DOC)
			_gnodes.reverse()
			modulate.a = 0.5
		else:
			if _pressed:
				get_tree().call_group(GROUP_ID_DOC, "_doc_drop", self)
			_pressed = false
			_gnodes.clear()
			modulate.a = 1
	elif event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_MASK_LEFT and _pressed:
		_doc_check_drop()

func _doc_check_drop():
	get_tree().call_group(GROUP_ID_DOC, "set_inside_flage", false)
	var mp = get_global_mouse_position()
	for doc_container :DocContainer in _gnodes:
		if doc_container == self or is_ancestor_of(doc_container):
			continue
		if not doc_container.get_global_rect().has_point(mp):
			continue
		var area_index = doc_container.get_area_index()
		if area_index == -1:
			continue
		doc_container._inside_flag = true
		break
	get_tree().call_group(GROUP_ID_DOC, "queue_redraw")

func _doc_drop(doc:DocContainer):
	if not doc or doc == self or not _inside_flag:
		return 
	_inside_flag = false
	queue_redraw()
	var area_index = get_area_index()
	match area_index:
		0:
			doc.get_parent().remove_child(doc)
			add_child(doc)
		1: 
			var parent = _get_doc_ancestor()
			if not parent :
				return 
			_add_to_split(doc, self)
		2: 
			var parent = _get_doc_ancestor()
			if not parent :
				return 
			_add_to_split(doc, self, true)
		3: 
			var parent = _get_doc_ancestor()
			if not parent :
				return 
			_add_to_split(self, doc)
		4: 
			var parent = _get_doc_ancestor()
			if not parent :
				return 
			_add_to_split(self, doc, true)
	_fit_size()
	
func set_inside_flage(value:bool):
	_inside_flag = value

##
func _editor_processing():
	queue_redraw()

func _fit_size():
	for child_index in get_child_count():
		fit_child_in_rect(get_child(child_index), _rect_main)

func _add_to_split(node1:Control, node2:Control, is_vertical:=false) -> DocSplitContainer:
	var split = DocSplitContainer.new()
	if node1 == self:
		node1.add_sibling(split)
	else:
		node2.add_sibling(split)
	split.vertical = is_vertical
	split.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	split.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	node1.get_parent().remove_child(node1)
	node2.get_parent().remove_child(node2)
	split.add_child(node1)
	split.add_child(node2)
	return split

func _get_doc_ancestor():
	var parent = get_parent()
	if parent is DocContainer or parent is DocSplitContainer:
		return parent
	return 
	
	
