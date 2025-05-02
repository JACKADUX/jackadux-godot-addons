class_name ViewAdapter extends Node

signal value_changed(value:Variant)

@export var view : Node

func _ready() -> void:
	if not view:
		view = get_parent()
	adapt_view()

func adapt_view():  # OVERRIDE
	#view.some_signal.connect(func(v):
		#value_changed.emit(get_value())
	#)
	pass

func get_value() -> Variant: # OVERRIDE
	return 

func set_value(value:Variant): # OVERRIDE
	pass
