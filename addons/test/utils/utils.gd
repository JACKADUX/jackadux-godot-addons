# class Utils
extends RefCounted

static func iter_nodes(node:Node, fn:Callable):
	if not node:
		return 
	fn.call(node)
	if node != EditorInterface.get_edited_scene_root() and node.scene_file_path != "":
		return 
	for child in node.get_children():
		iter_nodes(child, fn)
		
static func iter_hover_control_nodes(node:Node, fn:Callable):
	if not node:
		return false
	if node is Control and not node.is_visible_in_tree():
		return false
	var count = node.get_child_count()
	for index in count:
		var child = node.get_child(count-1-index)
		if iter_hover_control_nodes(child, fn):
			break
	if node is not Control:
		return false
	var rect = node.get_global_rect()
	if not rect.has_point(node.get_global_mouse_position()):
		return false
	fn.call(node)
	if node != EditorInterface.get_edited_scene_root() and node.scene_file_path != "":
		return false
	return true
