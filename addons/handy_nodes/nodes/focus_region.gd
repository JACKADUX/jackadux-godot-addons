class_name FocusRegion extends Node

signal focus_changed

@export var main_contorl :Control

var _focus := false

func _ready():
	if not main_contorl:
		main_contorl = get_parent()
	
	get_viewport().gui_focus_changed.connect(func(node:Control):
		if main_contorl == node or main_contorl.is_ancestor_of(node):
			if _focus:
				return 
			_focus = true
			focus_changed.emit()
		elif _focus:
			_focus = false
			focus_changed.emit()
	)

func is_main_focused() -> bool:
	return _focus
	
static func install_to(parent:Node) -> FocusRegion:
	var agent = FocusRegion.new()
	parent.add_child(agent)
	return agent


static func focus_is_inside(node:Control) -> bool:
	var focus_node = node.get_viewport().gui_get_focus_owner()
	if not focus_node:
		return false
	if focus_node == node:
		return true
	return node.is_ancestor_of(focus_node)