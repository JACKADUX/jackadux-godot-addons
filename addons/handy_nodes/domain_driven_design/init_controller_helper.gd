extends Node

@export var enable := true

func _ready() -> void:
	if not enable:
		queue_free()
		return
	get_tree().auto_accept_quit = false
	await get_tree().root.ready
	var controller = YourController.instance()
	
	if get_parent().has_method("init_with_controller"):
		get_parent().init_with_controller(controller)
		controller.load_data()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		YourController.instance().save_data()
		get_tree().quit()
