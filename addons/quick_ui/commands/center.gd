extends RefCounted

static func get_icon_string() -> String:
	return "ControlAlignCenter"

static func get_title() -> String:
	return ""

static func execute():
	var nodes = EditorInterface.get_selection().get_selected_nodes()
	for node :Node in nodes:
		if node is not Control:
			continue
		node.size = Vector2.ZERO
		node.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
		node.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
