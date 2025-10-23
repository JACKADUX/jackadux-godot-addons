# class_name PropertyPromoter
@tool
extends Node
const NAME := "PropertyPromoter"
const SEP := "____"  # <PROP>_<NODE>
const BACKSLASH := "___"  # /

var parent : Node
func _ready() -> void:
	if not Engine.is_editor_hint():
		parent = owner
		for property in parent.get_meta_list():
			if SEP not in property:
				continue
			update_meta_property(parent, "metadata/"+property)
			parent.set_meta(property, null)
		queue_free()

func _process(delta: float) -> void:
	if Engine.get_process_frames()%30 == 0:
		parent = owner
		name = NAME
		unique_name_in_owner = true
		var count = 0
		for property in parent.get_meta_list():
			if SEP not in property:
				continue
			update_meta_property(parent, "metadata/"+property)
			count += 1
		if not count:
			queue_free()

static func create_meta(object:Node, prop_path:String):
	if not object or not object.unique_name_in_owner:
		push_warning("node must be unique in scene (Access as Unique Name enabled)")
		return 
	if not prop_path:
		push_warning("Select a property in Inspector first!")
		return 
	var root_object :Node= object.owner
	var prop = "%s____%s"%[prop_path, object.name]
	var value = object.get(prop_path)
	if value == null:
		# NOTE: 作为Resource类型不能为null, 否则无法在父级场景显示属性栏
		for p in object.get_property_list():
			if p.name == prop_path and p.class_name:
				value = ClassDB.instantiate(p.class_name)
				break
				
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
		
		

static func update_meta_property(object:Node, meta_property:String):
	if not meta_property.begins_with("metadata/"):
		return 
	var rel_property = meta_property.trim_prefix("metadata/")
	var list = rel_property.split(SEP)
	if list.size() != 2:
		return 
	var value = object.get(meta_property) 
	var node_prop =list[0]
	var node_name =list[1]
	var node = object.get_node("%"+node_name)
	if not node:
		return 
	if BACKSLASH in node_prop:
		var theme_pair = node_prop.split(BACKSLASH)
		match theme_pair[0]:
			"theme_override_colors": node.add_theme_color_override(theme_pair[1], value)
			"theme_override_icons": node.add_theme_icon_override(theme_pair[1], value)
			"theme_override_constants": node.add_theme_constant_override(theme_pair[1], value)
			"theme_override_fonts": node.add_theme_font_override(theme_pair[1], value)
			"theme_override_font_sizes": node.add_theme_font_size_override(theme_pair[1], value)
			"theme_override_styles": node.add_theme_stylebox_override(theme_pair[1], value)
	else:
		node.set(node_prop, value)
