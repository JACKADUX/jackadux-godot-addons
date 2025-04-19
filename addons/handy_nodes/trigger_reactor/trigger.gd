class_name Trigger extends Node

signal triggered(data:Dictionary)

enum TriggerType {
				NONE, 
				MOUSE_IN, MOUSE_OUT, MOUSE_IN_OUT, 
				PRESSED, RELEASED, PRESSED_RELEASED,
				DOUBLE_CLICKED,
				READY, VISIBLITY_CHANGED
				}

@export var trigger_control:Control
@export var trigger_type:TriggerType
@export var trigger_on_ready := false

func _ready() -> void:
	if not trigger_control:
		trigger_control = get_parent()
	
	connect_trigger()
	if not get_tree().root.is_node_ready():
		await get_tree().root.ready
	if trigger_on_ready:
		raise_trigger()

func raise_trigger(data:Dictionary={}):
	triggered.emit(data)
	
func connect_trigger():
	match trigger_type:
		TriggerType.MOUSE_IN:
			trigger_control.mouse_entered.connect(func():
				raise_trigger()
			)
			
		TriggerType.MOUSE_OUT:
			trigger_control.mouse_exited.connect(func():
				raise_trigger()
			)
			
		TriggerType.MOUSE_IN_OUT:
			trigger_control.mouse_entered.connect(func():
				raise_trigger({"is_entered":true})
			)
			trigger_control.mouse_exited.connect(func():
				raise_trigger({"is_entered":false})
			)
		
		TriggerType.PRESSED:
			trigger_control.gui_input.connect(func(event:InputEvent):
				if event is InputEventMouseButton and event.is_pressed():
					if event.button_index == MOUSE_BUTTON_LEFT :
						raise_trigger()
			)	
		TriggerType.RELEASED:
			trigger_control.gui_input.connect(func(event:InputEvent):
				if event is InputEventMouseButton and event.is_released():
					if event.button_index == MOUSE_BUTTON_LEFT :
						raise_trigger()
			)	
			
		TriggerType.PRESSED_RELEASED:
			trigger_control.gui_input.connect(func(event:InputEvent):
				if event is InputEventMouseButton :
					if event.button_index == MOUSE_BUTTON_LEFT :
						if event.is_pressed():
							raise_trigger({"is_pressed":true})
						else:
							raise_trigger({"is_pressed":false})
			)	
		
		TriggerType.DOUBLE_CLICKED:
			trigger_control.gui_input.connect(func(event:InputEvent):
				if event is InputEventMouseButton :
					if event.double_click:
						raise_trigger()
			)	
		TriggerType.VISIBLITY_CHANGED:
			trigger_control.visibility_changed.connect(func():
				raise_trigger({"visible":trigger_control.is_visible_in_tree()})
			)
		TriggerType.READY:
			trigger_control.ready.connect(func():
				raise_trigger()
			)
