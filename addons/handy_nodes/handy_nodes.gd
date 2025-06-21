@tool
extends EditorPlugin


func _enter_tree() -> void:
	pass
	#var icon = EditorInterface.get_editor_theme().get_icon("Control","EditorIcons")
	#add_custom_type("CanvasViewer", "Control", preload("components/canvas_viewer/canvas_viewer.gd"), icon)

func _exit_tree() -> void:
	#remove_custom_type("CanvasViewer")
	pass
