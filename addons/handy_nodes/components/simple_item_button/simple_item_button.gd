class_name SimpleItemButton extends Button

signal double_clicked

@export var item_button_group:SimpleItemButtonGroup:
	set(v):
		if item_button_group:
			item_button_group.remove_item_button_from_group(self)
		item_button_group = v
		if item_button_group:
			item_button_group.add_item_button_to_group(self)

func _ready() -> void:
	toggle_mode = true
	focus_mode = Control.FOCUS_NONE

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.double_click:
			double_clicked.emit()
