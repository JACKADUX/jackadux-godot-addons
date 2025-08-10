extends DragDropData

var texture: Texture2D

func get_drag(position:Vector2, drag_control:Control) -> bool:
	make_preview(drag_control)
	texture = drag_control.texture.duplicate()
	return true

func can_drop(position:Vector2, drop_control:Control) -> bool:
	if get_token() == "N" and drop_control is Panel:
		return true
	return drop_control is TextureRect

func drop(position:Vector2, drop_control:Control):
	print(position)
	if get_token() == "N" and drop_control is Panel:
		for child in drop_control.get_children():
			if child is not TextureRect:
				continue
			if Rect2(child.position, child.size).has_point(position):
				child.texture = texture
	else:
		drop_control.texture = texture
