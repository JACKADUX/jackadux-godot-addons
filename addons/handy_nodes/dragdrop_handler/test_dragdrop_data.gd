extends DragDropData

var texture: Texture2D

func init_with(drag_control:Control):
	make_preview(drag_control)
	texture = drag_control.texture.duplicate()

func can_drop(position:Vector2, drop_control:Control) -> bool:
	return drop_control is TextureRect

func drop(position:Vector2, drop_control:Control):
	drop_control.texture = texture
