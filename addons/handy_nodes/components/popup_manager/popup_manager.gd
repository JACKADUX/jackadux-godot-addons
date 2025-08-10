extends CanvasLayer

const PopupRegisterHelper = preload("uid://wyuummmakaqc")

func _enter_tree() -> void:
	for child in get_children():
		if child is PopupRegisterHelper:
			register_popup_panel_plugin(child.plugin_name, child.scene)
			remove_child(child)
			child.queue_free()
	

func add_block_layer(color:=Color.BLACK, free_on_click:=true) -> ColorRect:
	var color_rect = ColorRect.new()
	color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	color_rect.color = color
	add_child(color_rect)
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	color_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	color_rect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if free_on_click:
		color_rect.gui_input.connect(func(event: InputEvent):
			if event is InputEventMouseButton and event.is_pressed():
				color_rect.queue_free()
		)
	return color_rect
	
func add_panel_container(control:Control, margin:=24):
	var contanier = PanelContainer.new()
	var margin_container = MarginContainer.new()
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)
	contanier.add_child(margin_container)
	margin_container.add_child(control)
	return contanier

func popup_control_with_block(control:Control, free_on_click:=true):
	var block_layer = add_block_layer(Color(Color.BLACK, 0.2), free_on_click)
	block_layer.add_child(control)
	return block_layer

func add_node_before_popup_manager(node:Node):
	get_tree().root.add_child(node)
	get_tree().root.move_child(node, get_index())

func ensure_popup_on_valid_position(popup_position:Vector2, popup:Window):
	var rect = Rect2(popup_position, popup.get_contents_minimum_size())
	var view_rect = get_viewport().get_visible_rect()
	if not view_rect.encloses(rect):
		var offset_end = view_rect.end - rect.end
		if offset_end.x <= 0:
			rect.position.x += offset_end.x - 10
		if offset_end.y <= 0:
			rect.position.y += offset_end.y- 10
	popup.popup(rect)

func quick_popup_tween(control:Control, type:=0):
	match type:
		0:
			control.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
			control.pivot_offset = control.size*0.5
			var tween = create_tween()
			tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
			tween.tween_property(control, "scale", Vector2.ONE, 0.2).from(Vector2.ZERO)


## Plugin
var _plugins := {}
func register_popup_panel_plugin(plugin_name:String, packed_scene:PackedScene):
	_plugins[plugin_name] = packed_scene
		
func call_popup_panel_plugin(plugin_name:String) -> Control:
	var packed_scene = _plugins.get(plugin_name)
	if not packed_scene:
		printerr("call_popup_panel_plugin失败 plugin_name: '%s' 不存在"%plugin_name)
		return 
	var panel :Control= packed_scene.instantiate()
	var block_layer = add_block_layer(Color(Color.BLACK, 0.2), true)
	var panel_container = add_panel_container(panel)
	block_layer.add_child(panel_container)
	
	panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	panel_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel_container.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	panel.tree_exited.connect(func():
		block_layer.queue_free()
	)
	return panel
