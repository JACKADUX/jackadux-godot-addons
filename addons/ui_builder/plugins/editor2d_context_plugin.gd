#class Editor2DContextPlugin 
extends EditorContextMenuPlugin

const NodePopupUtils = preload("uid://d1narqgeaet86")
 
func _popup_menu(paths:PackedStringArray):
	return 
	NodePopupUtils.add_control_sub_nodes(self)
