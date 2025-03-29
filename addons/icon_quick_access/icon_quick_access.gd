@tool
extends EditorPlugin

const ICON_TABLER_QUICK_ACCESS_PANEL = preload("res://addons/icon_quick_access/icon_tabler_quick_access_panel.tscn")
var pannel 

func _enter_tree():
	pannel = ICON_TABLER_QUICK_ACCESS_PANEL.instantiate()
	add_control_to_bottom_panel(pannel, "IconQuickAccess")

func _exit_tree():
	remove_control_from_bottom_panel(pannel)
	pannel.queue_free()
