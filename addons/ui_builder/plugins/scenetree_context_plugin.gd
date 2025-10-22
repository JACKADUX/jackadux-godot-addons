#class SceneTreeContextPlugin 
extends EditorContextMenuPlugin

func toaster_push_warning(text):
	EditorInterface.get_editor_toaster().push_toast(str(text), EditorToaster.SEVERITY_WARNING)
	
func _popup_menu(paths:PackedStringArray):
	var theme = EditorInterface.get_base_control()
	var promote_icon = theme.get_theme_icon("MemberProperty", "EditorIcons")
	if paths.size() != 1:
		return
	var inspector = EditorInterface.get_inspector()
	var scene_root = EditorInterface.get_edited_scene_root()
	var object :Node= scene_root.get_node(paths[0])
	if inspector.get_edited_object() == object:
		var prop_path = inspector.get_selected_path()
		var title = "Promote Property: <no select>" if not prop_path else "Promote Property: %s"%prop_path
		add_context_menu_item(title, func(_obj): 
			create_meta(object, prop_path)
			, promote_icon
		)
	#quick select
	var popup_menu = PopupMenu.new()
	var id_map:={}
	var id_start = 200
	var index = 0
	var name_class = object.get_class()
	while name_class:
		var list = ClassDB.class_get_property_list(name_class, true)
		if list:
			popup_menu.add_separator(name_class)
			for prop in list:
				if not (prop.usage & PROPERTY_USAGE_EDITOR):
					continue
				index += 1
				var id = id_start + index
				popup_menu.add_item(prop.name, id)
				id_map[id] = prop
		name_class = ClassDB.get_parent_class(name_class)
	
	var sep := false
	for prop in object.get_property_list():
		index += 1
		if not prop.name.begins_with("theme_override_") or "/" not in prop.name:
			continue
		if not sep:
			sep = true
			popup_menu.add_separator("Theme Override")
		var id = id_start + index
		popup_menu.add_item(prop.name, id)
		id_map[id] = prop
		
	popup_menu.id_pressed.connect(func(id):
		create_meta(object, id_map[id].name)
	)
	add_context_submenu_item("Select Promote Property", popup_menu, promote_icon)

func create_meta(object, prop_path:String):
	if not object or not object.unique_name_in_owner:
		toaster_push_warning("node must be unique in scene (Access as Unique Name enabled)")
		return 
	if not prop_path:
		toaster_push_warning("Select a property in Inspector first!")
		return 
	var root_object :Node= object.owner
	var prop = "%s____%s"%[prop_path, object.name]
	var value = object.get(prop_path)
	if "/" in prop_path:
		prop = prop.replace("/", "___") 
		var theme_pair = prop_path.split("/")
		match theme_pair[0]:
			"theme_override_colors": value = object.get_theme_color(theme_pair[1])
			"theme_override_icons": value = object.get_theme_icon(theme_pair[1])
			"theme_override_constants": value = object.get_theme_constant(theme_pair[1])
			"theme_override_fonts": value = object.get_theme_font(theme_pair[1])
			"theme_override_font_sizes": value = object.get_theme_font_size(theme_pair[1])
			"theme_override_styles": value = object.get_theme_stylebox(theme_pair[1])
	root_object.set_meta(prop, value)
	

func _on_property_edited(property:String):
	if property.begins_with("metadata/"):
		var inspector = EditorInterface.get_inspector()
		var object :Control= inspector.get_edited_object()
		var rel_property = property.trim_prefix("metadata/")
		var value = object.get(property)
		var list = rel_property.split("____")
		if list.size() != 2:
			return 
		var node_prop =list[0]
		var node_name =list[1]
		var node = object.get_node("%"+node_name)
		if not node:
			return 
		if "___" in node_prop:
			var theme_pair = node_prop.split("___")
			match theme_pair[0]:
				"theme_override_colors": node.add_theme_color_override(theme_pair[1], value)
				"theme_override_icons": node.add_theme_icon_override(theme_pair[1], value)
				"theme_override_constants": node.add_theme_constant_override(theme_pair[1], value)
				"theme_override_fonts": node.add_theme_font_override(theme_pair[1], value)
				"theme_override_font_sizes": node.add_theme_font_size_override(theme_pair[1], value)
				"theme_override_styles": node.add_theme_stylebox_override(theme_pair[1], value)
		else:
			node.set(node_prop, value)
