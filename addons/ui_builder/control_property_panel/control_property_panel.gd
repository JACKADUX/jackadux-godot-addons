@tool
# class ControlPropertyPanel
extends PanelContainer

const NodeUtils = preload("uid://d1narqgeaet86")

const ICON_FOCUS = preload("uid://cv8c0wy8syils")
const ICON_MOUSE_IGNORE = preload("uid://boxqllmbmmpmd")
const ICON_MOUSE_PASS = preload("uid://d188s5ih2heck")
const ICON_MOUSE_STOP = preload("uid://ccjkt567mkj6h")
const ICON_UNFOCUS = preload("uid://cn5qb1xnraf28")

const ICON_ARROW = preload("uid://dm71s74l1bu8t")
const ICON_BDIAGSIZE = preload("uid://dr8okma7lqcll")
const ICON_CAN_DROP = preload("uid://sm082kcylafn")
const ICON_DRAG = preload("uid://qphe0hvl7ase")
const ICON_FDIAGSIZE = preload("uid://4pe0g5xcoi2m")
const ICON_FORBIDDEN = preload("uid://0oc5s5vedhoy")
const ICON_HELP = preload("uid://cajim1164kgm")
const ICON_HSIZE = preload("uid://bhis62xnttsl7")
const ICON_HSPLIT = preload("uid://s4r3ipma15jk")
const ICON_IBEAM = preload("uid://bccm1bi5s13yw")
const ICON_MOVE = preload("uid://c1lcnaa2aisul")
const ICON_POINTING_HAND = preload("uid://bhaof06hcgoag")
const ICON_VSIZE = preload("uid://cshghpl6prkab")
const ICON_VSPLIT = preload("uid://d00as2t7jygbk")


@onready var filter_button: Button = %FilterButton
@onready var focus_button: Button = %FocusButton
@onready var cursor_button: Button = %CursorButton
@onready var align_left_button: Button = %AlignLeftButton
@onready var align_h_center_button: Button = %AlignHCenterButton
@onready var align_right_button: Button = %AlignRightButton
@onready var h_fill_button: Button = %HFillButton
@onready var h_expand_button := %HExpandButton
@onready var align_top_button: Button = %AlignTopButton
@onready var align_v_center_button: Button = %AlignVCenterButton
@onready var align_bottom_button: Button = %AlignBottomButton
@onready var v_fill_button: Button = %VFillButton
@onready var v_expand_button := %VExpandButton
 
@onready var nodes_panel_button: Button = %NodesPanelButton

const FILTER_TEXT := ["Stop", "Pass", "Ignore"]
const FILTER_ICON := [ICON_MOUSE_STOP, ICON_MOUSE_PASS, ICON_MOUSE_IGNORE]

func _ready() -> void:
	var inspector := EditorInterface.get_inspector()
	inspector.edited_object_changed.connect(func():
		update()
	)
	

	filter_button.pressed.connect(func():
		var objects = NodeUtils.get_selected_nodes()
		for o in objects:
			match o.mouse_filter:
				MOUSE_FILTER_STOP:
					o.set("mouse_filter", MOUSE_FILTER_PASS)
				MOUSE_FILTER_PASS:
					o.set("mouse_filter", MOUSE_FILTER_IGNORE)
				MOUSE_FILTER_IGNORE:
					o.set("mouse_filter", MOUSE_FILTER_STOP)
		update()
	)

	focus_button.pressed.connect(func():
		var objects = NodeUtils.get_selected_nodes()
		for o in objects:
			match o.focus_mode:
				FOCUS_NONE:
					o.set("focus_mode", FOCUS_ALL)
				FOCUS_ALL:
					o.set("focus_mode", FOCUS_NONE)
		update()
	)

	cursor_button.pressed.connect(func():
		var popup = PopupMenu.new()
		popup.visibility_changed.connect(func():
			if not popup.visible:
				popup.queue_free()
		)

		
		popup.add_icon_item(ICON_ARROW, "Arrow", CURSOR_ARROW)
		popup.add_icon_item(ICON_IBEAM, "IBeam", CURSOR_IBEAM)
		popup.add_icon_item(ICON_POINTING_HAND, "Pointing Hand", CURSOR_POINTING_HAND)

		var pos = cursor_button.global_position + Vector2(0, 18)
		popup.position = Vector2(pos.x, pos.y + cursor_button.size.y + 8)
		popup.popup_exclusive(self)
		
		popup.id_pressed.connect(func(id):
			var objects = NodeUtils.get_selected_nodes()
			for o in objects:
				o.set("mouse_default_cursor_shape", id)
			update()
		)
	)


	_set_align_icon(align_left_button, "ControlAlignCenterLeft")
	_set_align_icon(align_h_center_button, "ControlAlignCenter")
	_set_align_icon(align_right_button, "ControlAlignCenterRight")
	_set_align_icon(align_top_button, "ControlAlignCenterTop")
	_set_align_icon(align_v_center_button, "ControlAlignCenter")
	_set_align_icon(align_bottom_button, "ControlAlignCenterBottom")
	_set_align_icon(h_fill_button, "ControlAlignHCenterWide")
	_set_align_icon(v_fill_button, "ControlAlignVCenterWide")
	
	var _fn = func(flag: SizeFlags):
		var objects = NodeUtils.get_selected_nodes()
		if not objects:
			return
		var v = (objects[0].get("size_flags_horizontal") & SizeFlags.SIZE_EXPAND) | flag
		for o in objects:
			o.set("size_flags_horizontal", v)
		update()
	align_left_button.pressed.connect(_fn.bind(SizeFlags.SIZE_SHRINK_BEGIN))
	align_h_center_button.pressed.connect(_fn.bind(SizeFlags.SIZE_SHRINK_CENTER))
	align_right_button.pressed.connect(_fn.bind(SizeFlags.SIZE_SHRINK_END))
	h_fill_button.pressed.connect(_fn.bind(SizeFlags.SIZE_FILL))
	h_expand_button.toggled.connect(func(_tv):
		var objects = NodeUtils.get_selected_nodes()
		if not objects:
			return
		var v
		if not _tv:
			v = objects[0].get("size_flags_horizontal") & ~SizeFlags.SIZE_EXPAND
		else:
			v = objects[0].get("size_flags_horizontal") | SizeFlags.SIZE_EXPAND
		for o in objects:
			o.set("size_flags_horizontal", v)
	)
	
	var _fnv = func(flag: SizeFlags):
		var objects = NodeUtils.get_selected_nodes()
		if not objects:
			return
		var v = (objects[0].get("size_flags_vertical") & SizeFlags.SIZE_EXPAND) | flag
		for o in objects:
			o.set("size_flags_vertical", v)
		update()
	align_top_button.pressed.connect(_fnv.bind(SizeFlags.SIZE_SHRINK_BEGIN))
	align_v_center_button.pressed.connect(_fnv.bind(SizeFlags.SIZE_SHRINK_CENTER))
	align_bottom_button.pressed.connect(_fnv.bind(SizeFlags.SIZE_SHRINK_END))
	v_fill_button.pressed.connect(_fnv.bind(SizeFlags.SIZE_FILL))
	v_expand_button.toggled.connect(func(_tv):
		var objects = NodeUtils.get_selected_nodes()
		if not objects:
			return
		var v
		if not _tv:
			v = objects[0].get("size_flags_vertical") & (~SizeFlags.SIZE_EXPAND)
		else:
			v = objects[0].get("size_flags_vertical") | SizeFlags.SIZE_EXPAND
		for o in objects:
			o.set("size_flags_vertical", v)
		update()
	)
	
	update()
	
func _set_align_icon(node: Button, type: String):
	var theme = EditorInterface.get_base_control()
	node.text = ""
	node.icon = theme.get_theme_icon(type, "EditorIcons")
	node.tooltip_text = type


func update():
	var objects = NodeUtils.get_selected_nodes()
	if not objects:
		hide()
		return
	else:
		show()
	#
	var object: Control = objects[0]
	filter_button.text = FILTER_TEXT[object.mouse_filter]
	filter_button.icon = FILTER_ICON[object.mouse_filter]
	h_expand_button.button_pressed = object.size_flags_horizontal & SIZE_EXPAND
	v_expand_button.button_pressed = object.size_flags_vertical & SIZE_EXPAND
	
	
	for b in align_left_button.button_group.get_buttons():
		b.set_pressed_no_signal(false)
	for b in align_top_button.button_group.get_buttons():
		b.set_pressed_no_signal(false)
	
	if object.size_flags_horizontal & SIZE_SHRINK_BEGIN:
		align_left_button.set_pressed_no_signal(true)
	elif object.size_flags_horizontal & SIZE_SHRINK_CENTER:
		align_h_center_button.set_pressed_no_signal(true)
	elif object.size_flags_horizontal & SIZE_SHRINK_END:
		align_right_button.set_pressed_no_signal(true)
	elif object.size_flags_horizontal & SIZE_FILL:
		h_fill_button.set_pressed_no_signal(true)

		
	if object.size_flags_vertical & SIZE_SHRINK_BEGIN:
		align_top_button.set_pressed_no_signal(true)
	elif object.size_flags_vertical & SIZE_SHRINK_CENTER:
		align_v_center_button.set_pressed_no_signal(true)
	elif object.size_flags_vertical & SIZE_SHRINK_END:
		align_bottom_button.set_pressed_no_signal(true)
	elif object.size_flags_vertical & SIZE_FILL:
		v_fill_button.set_pressed_no_signal(true)


	if object.focus_mode == FOCUS_NONE:
		focus_button.icon = ICON_UNFOCUS
	else:
		focus_button.icon = ICON_FOCUS
	
	match object.mouse_default_cursor_shape:
		CURSOR_ARROW:
			cursor_button.icon = ICON_ARROW
		CURSOR_IBEAM:
			cursor_button.icon = ICON_IBEAM
		CURSOR_CAN_DROP:
			cursor_button.icon = ICON_CAN_DROP
		CURSOR_FORBIDDEN:
			cursor_button.icon = ICON_FORBIDDEN
		CURSOR_BDIAGSIZE:
			cursor_button.icon = ICON_BDIAGSIZE
		CURSOR_FDIAGSIZE:
			cursor_button.icon = ICON_FDIAGSIZE
		CURSOR_HSIZE:
			cursor_button.icon = ICON_HSIZE
		CURSOR_VSIZE:
			cursor_button.icon = ICON_VSIZE
		CURSOR_POINTING_HAND:
			cursor_button.icon = ICON_POINTING_HAND
		CURSOR_MOVE:
			cursor_button.icon = ICON_MOVE
		CURSOR_DRAG:
			cursor_button.icon = ICON_DRAG
		CURSOR_VSPLIT:
			cursor_button.icon = ICON_VSPLIT
		CURSOR_HSPLIT:
			cursor_button.icon = ICON_HSPLIT
		CURSOR_HELP:
			cursor_button.icon = ICON_HELP
