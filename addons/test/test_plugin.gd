@tool
extends EditorPlugin

const Utils = preload("uid://jtlcdumqthyc")


const FileSystemContextPlugin = preload("uid://dssec8kqvvtsf")
const ScriptEditorContextPlugin = preload("uid://b7fyavsdmbp37")
const SceneTreeContextPlugin = preload("uid://drt3slowysky7")
const Editor2DContextPlugin = preload("uid://pqt4g7opvaeh")

const UiBuilderPanel = preload("uid://cyfygk2k02nci")
const UI_BUILDER_PANEL = preload("uid://5l7v2vc6hro8")

var ui_builder_panel : UiBuilderPanel
var filesystem_context_plugin : FileSystemContextPlugin
var scenetree_context_plugin : SceneTreeContextPlugin
var scripteditor_context_plugin : ScriptEditorContextPlugin
var editor2d_context_plugin : Editor2DContextPlugin

func _enter_tree() -> void:
	ui_builder_panel = UI_BUILDER_PANEL.instantiate()
	filesystem_context_plugin = FileSystemContextPlugin.new()
	scenetree_context_plugin = SceneTreeContextPlugin.new()
	scripteditor_context_plugin = ScriptEditorContextPlugin.new()
	editor2d_context_plugin = Editor2DContextPlugin.new()
	
	#add_control_to_bottom_panel(ui_builder_panel, "UI Builder")
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, filesystem_context_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCENE_TREE, scenetree_context_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_SCRIPT_EDITOR_CODE, scripteditor_context_plugin)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_2D_EDITOR, editor2d_context_plugin)
	
	var inspector = EditorInterface.get_inspector()
	inspector.property_edited.connect(scenetree_context_plugin._on_property_edited)
	
	handle_editor2d()
	
	text_edit = TextEdit.new()
	add_child(text_edit)

func _exit_tree() -> void:
	disconnect_all_signal(get_editor2d(), "gui_input")
	var inspector = EditorInterface.get_inspector()
	inspector.property_edited.disconnect(scenetree_context_plugin._on_property_edited)
	
	remove_context_menu_plugin(filesystem_context_plugin)
	remove_context_menu_plugin(scenetree_context_plugin)
	remove_context_menu_plugin(scripteditor_context_plugin)
	remove_context_menu_plugin(editor2d_context_plugin)
		
	#remove_control_from_bottom_panel(ui_builder_panel)
	text_edit.queue_free()
	ui_builder_panel.queue_free()

##
var _object :Control
var _hovered_object:Control
var _widget_data : Dictionary = {}
func disconnect_all_signal(node:Node, sig):
	for d in node.get_signal_connection_list(sig):
		node.disconnect(sig, d.callable)

func get_editor2d() -> VBoxContainer:
	return EditorInterface.get_base_control().find_child("@CanvasItemEditor*", true, false)

func handle_editor2d():
	set_force_draw_over_forwarding_enabled()
	var editor_viewport := get_editor2d()
	disconnect_all_signal(editor_viewport, "gui_input")
	editor_viewport.gui_input.connect(func(event:InputEvent):
		# NOTE: 没选任何对象时绘制
		if _object:
			return 
		if event is InputEventMouseMotion:
			if _update_hovered():
				update_overlays()
	)
	
func _update_hovered() -> bool:
	var root = EditorInterface.get_edited_scene_root()
	var next_hovered_object :Control 
	var arr := []
	Utils.iter_hover_control_nodes(root, func(node:Control):
		if node != root and node.owner != root:
			return 
		arr.append(node)
	)
	next_hovered_object = arr[0] if arr else null
	if next_hovered_object == _hovered_object:
		return false
	_hovered_object = next_hovered_object
	return true
##
func _handles(object: Object) -> bool:
	if object and object is Control:
		return true
	return false
	
func _edit(object: Object) -> void:
	if not object or object is not Control:
		object = null
	_object = object
	update_overlays()

func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if _handle_special_edit(event):
		return true

	if event is InputEventMouseMotion and event.button_mask == MOUSE_BUTTON_NONE:
		_update_hovered()
		update_overlays()
	return _widget_gui_input(event)


func _forward_canvas_draw_over_viewport(viewport_control: Control) -> void:
	custom_draw(viewport_control)

func _forward_canvas_force_draw_over_viewport(viewport_control: Control) -> void:
	custom_draw(viewport_control)
	
var viewport_transform :Transform2D
var zoom :float:
	get: return viewport_transform.get_scale().x
func custom_draw(viewport_control: Control):
	var root = EditorInterface.get_edited_scene_root()
	viewport_transform = root.get_viewport_transform()
	if _hovered_object:
		var rect = viewport_transform*_hovered_object.get_global_rect()
		viewport_control.draw_rect(rect, Color(Color.GREEN, 0.8), false, -1)
		_draw_container_child(viewport_control)
		_draw_node_info(viewport_control)
		
	if _object and not _pressed:
		_widget_draw(viewport_control)

func _draw_node_info(viewport_control: Control):
	if not _hovered_object:
		return 
	var rect = viewport_transform*_hovered_object.get_global_rect()
	var theme = EditorInterface.get_base_control()
	var icon = theme.get_theme_icon(_hovered_object.get_class(), "EditorIcons")
	if not icon:
		return 
	var icon_size = Vector2(18, 18)
	var gap = 4
	var icon_rect = Rect2(rect.position - Vector2(0, icon_size.y+gap), icon_size)
	viewport_control.draw_texture_rect(icon, icon_rect, false)
	viewport_control.draw_string(theme.get_theme_default_font(), icon_rect.end + Vector2(gap, -gap), _hovered_object.name, HORIZONTAL_ALIGNMENT_LEFT)

func _draw_container_child(viewport_control: Control):
	#if not _hovered_object or (_hovered_object is not Container and _hovered_object.get_class() != "Control"):
	if not _hovered_object or _hovered_object is not Container:
		return 
	for child :Control in _hovered_object.get_children():
		if not child.is_visible_in_tree():
			continue
		var rect = viewport_transform*child.get_global_rect().grow(-2/zoom)
		var rt = Vector2(rect.end.x, rect.position.y)
		var lb = Vector2(rect.position.x, rect.end.y)
		viewport_control.draw_rect(rect, Color(Color.GREEN, 0.05))
		viewport_control.draw_dashed_line(rect.position, rt, Color(Color.GREEN, 0.4), -1, 10)
		viewport_control.draw_dashed_line(rt, rect.end, Color(Color.GREEN, 0.4), -1, 10)
		viewport_control.draw_dashed_line(rect.end, lb, Color(Color.GREEN, 0.4), -1, 10)
		viewport_control.draw_dashed_line(lb, rect.position, Color(Color.GREEN, 0.4), -1, 10)
		
var _pressed = false
var _start_position := Vector2.ZERO
var _start_value:Variant

func _widget_generate_data():
	_widget_data = {}
	if not _object or not _object.is_inside_tree() or not _object.is_visible_in_tree():
		return
		
	var v_widget_size = Vector2(12,32)
	var h_widget_size = Vector2(32,12)
	var offset := 20
	_widget_data["class"] = _object.get_class()
	if _object is SplitContainer:
		_widget_data["rect"] = _object.get_drag_area_control().get_global_rect()
		
	elif _object is MarginContainer:
		var rect = _object.get_global_rect()
		var left_rect = Rect2(rect.position + Vector2(-offset, rect.size.y*0.5)-v_widget_size*0.5, v_widget_size)
		var right_rect = Rect2(rect.position + Vector2(rect.size.x+offset, rect.size.y*0.5)-v_widget_size*0.5, v_widget_size)
		var top_rect = Rect2(rect.position + Vector2(rect.size.x*0.5, -offset)-h_widget_size*0.5, h_widget_size)
		var bottom_rect = Rect2(rect.position + Vector2(rect.size.x*0.5, rect.size.y+offset)-h_widget_size*0.5, h_widget_size)
		_widget_data["rects"] = [left_rect, top_rect, right_rect, bottom_rect]
		
	elif _object is BoxContainer:
		var rect = _object.get_global_rect()
		var top_rect = Rect2(rect.position + Vector2(rect.size.x*0.5, -offset)-h_widget_size*0.5, h_widget_size)
		var left_rect = Rect2(rect.position + Vector2(-offset, rect.size.y*0.5)-v_widget_size*0.5, v_widget_size)
		_widget_data["rect"] = top_rect if _object.vertical else left_rect
		
	elif _object is GridContainer:
		var rect = _object.get_global_rect()
		var left_rect = Rect2(rect.position + Vector2(-offset, rect.size.y*0.5)-v_widget_size*0.5, v_widget_size)
		var top_rect = Rect2(rect.position + Vector2(rect.size.x*0.5, -offset)-h_widget_size*0.5, h_widget_size)
		_widget_data["rects"] = [left_rect, top_rect]
	
	elif _object is FlowContainer:
		var rect = _object.get_global_rect()
		var left_rect = Rect2(rect.position + Vector2(-offset, rect.size.y*0.5)-v_widget_size*0.5, v_widget_size)
		var top_rect = Rect2(rect.position + Vector2(rect.size.x*0.5, -offset)-h_widget_size*0.5, h_widget_size)
		_widget_data["rects"] = [left_rect, top_rect]
	
	elif _object is ItemList:
		var rect = _object.get_global_rect()
		var left_rect = Rect2(rect.position + Vector2(-offset, rect.size.y*0.5)-v_widget_size*0.5, v_widget_size)
		var top_rect = Rect2(rect.position + Vector2(rect.size.x*0.5, -offset)-h_widget_size*0.5, h_widget_size)
		_widget_data["rects"] = [left_rect, top_rect]
	
func _widget_gui_input(event: InputEvent) -> bool:
	if not _object:
		return false
	_widget_generate_data()
	var mp = _object.get_global_mouse_position()
	if _object is SplitContainer:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					if _widget_data["rect"].has_point(mp):
						_start_position = mp
						_start_value = _object.split_offset
						_pressed = true
						update_overlays()
						return true
				elif _pressed:
					_pressed = false
					return true
		if event is InputEventMouseMotion and _pressed:
			var dt = _object.get_global_mouse_position()-_start_position
			var dtp = dt.y if _object.vertical else dt.x
			_object.split_offset = _start_value+dtp
			return true
			
	elif _object is MarginContainer:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					for rect in _widget_data["rects"]:
						if rect.has_point(mp):
							_start_position = mp
							_start_value = _object.get_theme_constant("margin_left")
							_pressed = true
							update_overlays()
							return true
				elif _pressed:
					_pressed = false
					return true
		if event is InputEventMouseMotion and _pressed:
			var dt = _object.get_global_mouse_position()-_start_position
			_object.add_theme_constant_override("margin_left", _start_value+dt.x)
			_object.add_theme_constant_override("margin_top", _start_value+dt.x)
			_object.add_theme_constant_override("margin_right", _start_value+dt.x)
			_object.add_theme_constant_override("margin_bottom", _start_value+dt.x)
			return true
	elif _object is BoxContainer:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					if _widget_data["rect"].has_point(mp):
						_start_position = mp
						_start_value = _object.get_theme_constant("separation")
						_pressed = true
						update_overlays()
						return true
				elif _pressed:
					_pressed = false
					return true
		if event is InputEventMouseMotion and _pressed:
			var dt = _object.get_global_mouse_position()-_start_position
			var dtp = dt.y if _object.vertical else dt.x
			_object.add_theme_constant_override("separation", _start_value+dtp)
			return true
	
	elif _object is GridContainer:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					for rect in _widget_data["rects"]:
						if rect.has_point(mp):
							_start_position = mp
							_start_value = _object.get_theme_constant("h_separation")
							_pressed = true
							update_overlays()
							return true
				elif _pressed:
					_pressed = false
					return true
		if event is InputEventMouseMotion and _pressed:
			var dt = _object.get_global_mouse_position()-_start_position
			_object.add_theme_constant_override("h_separation", _start_value+dt.x)
			_object.add_theme_constant_override("v_separation", _start_value+dt.x)
			return true
	
	elif _object is FlowContainer:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					for rect in _widget_data["rects"]:
						if rect.has_point(mp):
							_start_position = mp
							_start_value = _object.get_theme_constant("h_separation")
							_pressed = true
							update_overlays()
							return true
				elif _pressed:
					_pressed = false
					return true
		if event is InputEventMouseMotion and _pressed:
			var dt = _object.get_global_mouse_position()-_start_position
			_object.add_theme_constant_override("h_separation", _start_value+dt.x)
			_object.add_theme_constant_override("v_separation", _start_value+dt.x)
			return true
	
	elif _object is ItemList:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					for rect in _widget_data["rects"]:
						if rect.has_point(mp):
							_start_position = mp
							_start_value = _object.get_theme_constant("h_separation")
							_pressed = true
							update_overlays()
							return true
				elif _pressed:
					_pressed = false
					return true
		if event is InputEventMouseMotion and _pressed:
			var dt = _object.get_global_mouse_position()-_start_position
			_object.add_theme_constant_override("h_separation", _start_value+dt.x)
			_object.add_theme_constant_override("v_separation", _start_value+dt.x)
			return true
	
	return false

func _widget_draw(viewport_control: Control):
	if not _widget_data:
		return 
	var active_color = Color.AQUA
	var normal_color = Color.CADET_BLUE
	var mp = _object.get_global_mouse_position()
	var _class = _widget_data["class"]
	if _class in ["SplitContainer", "HSplitContainer", "VSplitContainer"]:
		var rect = _widget_data["rect"]
		if rect.has_point(mp):
			viewport_control.draw_rect(viewport_transform*rect, active_color)
		else:
			viewport_control.draw_rect(viewport_transform*rect, normal_color)
			
	elif _class == "MarginContainer":
		for rect in _widget_data["rects"]:
			if rect.has_point(mp):
				viewport_control.draw_rect(viewport_transform*rect, active_color)
			else:
				viewport_control.draw_rect(viewport_transform*rect, normal_color)
				
	elif _class in ["BoxContainer", "HBoxContainer", "VBoxContainer"]:
		var rect = _widget_data["rect"]
		if rect.has_point(mp):
			viewport_control.draw_rect(viewport_transform*rect, active_color)
		else:
			viewport_control.draw_rect(viewport_transform*rect, normal_color)
			
	elif _class == "GridContainer":
		for rect in _widget_data["rects"]:
			if rect.has_point(mp):
				viewport_control.draw_rect(viewport_transform*rect, active_color)
			else:
				viewport_control.draw_rect(viewport_transform*rect, normal_color)
	elif _class == "FlowContainer":
		for rect in _widget_data["rects"]:
			if rect.has_point(mp):
				viewport_control.draw_rect(viewport_transform*rect, active_color)
			else:
				viewport_control.draw_rect(viewport_transform*rect, normal_color)	
	elif _class == "ItemList":
		for rect in _widget_data["rects"]:
			if rect.has_point(mp):
				viewport_control.draw_rect(viewport_transform*rect, active_color)
			else:
				viewport_control.draw_rect(viewport_transform*rect, normal_color)	
				
var text_edit_mode := false
var text_edit :TextEdit

func _handle_special_edit(event:InputEvent) -> bool:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var mp = _object.get_global_mouse_position()
		if text_edit_mode and not _object or not _object.get_global_rect().has_point(mp):
			text_edit_mode = false
			return false
		if event.double_click:
			_handle_double_click.call_deferred(event.shift_pressed)
	if event is InputEventKey and event.is_pressed() and text_edit_mode:
		if not _object:
			text_edit_mode = false
			disconnect_all_signal(text_edit, "text_changed")
			return false
		return true
	return false
		
func _handle_double_click(shift_pressed:bool=false):
	if not _object:
		return
	var _class = _object.get_class()
	if _class in ["Label", "RichTextLabel"]:
		_use_text_edit(_object.text, func():
			_object.text = text_edit.text
		)
	elif _class in ["LineEdit", "TextEdit"]:
		_use_text_edit(_object.placeholder_text, func():
			_object.placeholder_text = text_edit.text
		)
	elif _class in ["TextureRect"]:
		EditorInterface.popup_quick_open(func(t):
			if not FileAccess.file_exists(t):
				return 
			_object.texture = load(t)
			,
			["Texture2D"]
		)
	elif _class in ["Button", "CheckBox", "CheckButton","MenuButton"]:
		if shift_pressed:
			EditorInterface.popup_quick_open(func(t):
				if not FileAccess.file_exists(t):
					return 
				_object.icon = load(t)
				,
				["Texture2D"]
			)
		else:
			_use_text_edit(_object.text, func():
				_object.text = text_edit.text
			)
	
func _use_text_edit(text:String, text_changed_fn:Callable):
	text_edit_mode = true
	disconnect_all_signal(text_edit, "text_changed")
	text_edit.text_changed.connect(text_changed_fn)
	text_edit.text = text
	text_edit.grab_focus()
	text_edit.deselect()
	if not text:
		return
	text_edit.set_caret_line(text.split("\n").size())
	text_edit.set_caret_column(text.split("\n")[-1].length())
