@tool
extends EditorPlugin

const QuickUiDock = preload("uid://0sro28e8cfga")
const QUICK_UI_DOCK = preload("uid://bp3f32ipxsi7x")

var quick_ui_doc : QuickUiDock

func _enter_tree() -> void:
	quick_ui_doc = QUICK_UI_DOCK.instantiate()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, quick_ui_doc)

func _exit_tree() -> void:
	remove_control_from_docks(quick_ui_doc)
	quick_ui_doc.queue_free()
