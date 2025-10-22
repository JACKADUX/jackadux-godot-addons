# class_name UIBuilderPanel
extends PanelContainer

@onready var button: Button = %Button

func _ready() -> void: 
	button.pressed.connect(func(): pass)
	button.gui_input.connect(func(event: InputEvent): pass)

func _process(_dt:float) -> void: pass
