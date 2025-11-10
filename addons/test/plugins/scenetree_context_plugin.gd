#class SceneTreeContextPlugin 
extends EditorContextMenuPlugin

const PropertyPromote = preload("uid://bhaxmspj4f1fy")


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
			PropertyPromote.create_meta(object, prop_path)
			_add_promoter(object)
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
		PropertyPromote.create_meta(object, id_map[id].name)
		_add_promoter(object)
	)
	add_context_submenu_item("Select Promote Property", popup_menu, promote_icon)


func _on_property_edited(property:String):
	if not property.begins_with("metadata/"):
		return 
	var inspector = EditorInterface.get_inspector()
	var object :Control= inspector.get_edited_object()
	PropertyPromote.update_meta_property(object, property)

func _add_promoter(object):
	if not object.owner.get_node_or_null("%"+PropertyPromote.NAME):
		var pp = PropertyPromote.new()
		pp.parent = object.owner
		pp.name = PropertyPromote.NAME
		object.owner.add_child(pp)
		pp.owner = object.owner
