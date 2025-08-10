class_name NS_Popup

# WARNING: Add 'popup_manager.tscn' to autoload before use

static func create_context_menu(popup_pos:Vector2, add_item_fn:Callable):
	"""
	var add_item_fn := func(popup:PopupMenu):
		popup.add_item("do something", 1, KEY_T)
		
	"""
	var popup := PopupMenu.new()
	var close_fn := func():
		if not popup.is_queued_for_deletion():
			popup.queue_free()
	popup.transparent_bg = true
	add_item_fn.call(popup)
	if popup.item_count == 0:
		close_fn.call()
		return 
	var block_layer = PopupManager.add_block_layer(Color(Color.BLACK, 0.2), true)
	block_layer.add_child(popup)
	popup.tree_exited.connect(func():
		block_layer.queue_free()
	)
	popup.id_pressed.connect(func(_id:int):
		close_fn.call()
	)
	popup.close_requested.connect(func():
		close_fn.call()
	)
	popup.popup_hide.connect(func():
		close_fn.call()
	)
	popup.position = popup_pos
	popup.size = Vector2(100,0)
	PopupManager.ensure_popup_on_valid_position(popup_pos, popup)
	return popup

##
const ConfirmDialog = preload("uid://dd1dgxkt2xyn4")
const CONFIRM_DIALOG = preload("uid://ggppic28bdfx")

static func create_confirm_dialog(title:String, text:String, option_text:="") -> ConfirmDialog:
	var confirm = CONFIRM_DIALOG.instantiate()
	var block = PopupManager.popup_control_with_block(confirm, false)
	PopupManager.quick_popup_tween(confirm)
	confirm.init(title, text, option_text)
	confirm.any_selected.connect(block.queue_free)
	await confirm.any_selected
	return confirm

##
const InputDialog = preload("uid://dw64iyq8uu5ly")
const INPUT_DIALOG = preload("uid://c1at74nvm4b4q")
static func create_input_dialog(title:String, text:String, placeholder_text:="") -> InputDialog:
	var input_dlg = INPUT_DIALOG.instantiate()
	var block = PopupManager.popup_control_with_block(input_dlg, false)
	PopupManager.quick_popup_tween(input_dlg)
	input_dlg.init(title, text, placeholder_text)
	input_dlg.any_selected.connect(block.queue_free)
	await input_dlg.any_selected
	return input_dlg

static func create_rename_dialog(default_title:String="", dlg_title:="", placeholder_text:="") -> String:
	if not dlg_title:
		dlg_title = TranslationServer.tr("Rename")
	if not placeholder_text:
		placeholder_text = TranslationServer.tr("Input text...")
	var input_dlg = await create_input_dialog(dlg_title, default_title, placeholder_text)
	if not input_dlg.is_confirm():
		return ""
	return input_dlg.get_text()


##
const MessageDialog = preload("uid://brt2lct2f3bw8")
const MESSAGE_DIALOG = preload("uid://cpjd37xmnbsju")

const GROUP_MESSAGE_BOX = "GROUP_MESSAGE_BOX"
const color_amber := Color("#FEB63D")
const color_notice := Color("#51CC56")
const color_error := Color("#FF5555")
const alpha = 1

const ICON_ALERT_TRIANGLE = preload("resource/alert_triangle.png")
const ICON_CIRCLE_EXCLAMATION = preload("resource/circle_exclamation.png")
const ICON_CIRCLE_CHECK = preload("resource/circle_check.png")
static func add_message_box(text:String, color:=Color.WHITE, texture:Texture2D=null) -> MessageDialog:
	var mb = MESSAGE_DIALOG.instantiate()
	PopupManager.add_child(mb)
	mb.set_text(text)
	mb.set_texture(texture)
	mb.set_color(color)
	mb.z_index = 10
	var off_y = mb.get_combined_minimum_size().y
	for _mb:Control in PopupManager.get_tree().get_nodes_in_group(GROUP_MESSAGE_BOX):
		_mb.position.y -= off_y+10
	mb.add_to_group(GROUP_MESSAGE_BOX)
	return mb

static func create_popup_error(message:Variant) -> MessageDialog:
	return add_message_box(str(message), Color(color_error, alpha), ICON_ALERT_TRIANGLE)
	
static func create_popup_warning(message:Variant) -> MessageDialog:
	return add_message_box(str(message), Color(color_amber, alpha), ICON_CIRCLE_EXCLAMATION)
	
static func create_popup_notice(message:Variant) -> MessageDialog:
	return add_message_box(str(message), Color(color_notice, alpha), ICON_CIRCLE_CHECK)
	
	
##
const ProcessDialog = preload("uid://orb70os4ae7r")
const PROCESS_DIALOG = preload("uid://b3aocsoqaoxfj")

static func new_process_dialog(context:String) -> ProcessDialog:
	var dlg = PROCESS_DIALOG.instantiate()
	PopupManager.popup_control_with_block(dlg, false)
	PopupManager.quick_popup_tween(dlg)
	dlg.init(context, 4, true)
	return dlg

static func create_with_in_process(context:String, process_fn:Callable):
	# process_fn -> func(dlg:ProcessDialog)
	var dlg := new_process_dialog(context)
	await process_fn.call(dlg)
	dlg.queue_free()
