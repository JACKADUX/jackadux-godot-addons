class_name CursorHelper extends Resource

@export var POINTING_HAND :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0137.png")
@export var CAN_DROP :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0160.png")
@export var FORBIDDEN :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0015.png")
@export var VSPLIT :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0204.png")
@export var HSPLIT :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0184.png")
@export var IBEAM :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0140.png")
@export var HELP :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0180.png")

@export var ARROW :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0028.png")
@export var BDIAGSIZE :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0002.png")
@export var FDIAGSIZE :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0003.png")
@export var HSIZE :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0001.png")
@export var MOVE :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0135.png")
@export var DRAG :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0136.png")
@export var VSIZE :Texture2D = preload("res://addons/handy_nodes/cursor_helper/resource/tile_0000.png")

var CURSOR_TEXTURE_LIST  := [FDIAGSIZE, VSIZE, BDIAGSIZE, HSIZE]
var CURSOR_LIST  := [DisplayServer.CURSOR_FDIAGSIZE, DisplayServer.CURSOR_VSIZE, DisplayServer.CURSOR_BDIAGSIZE, DisplayServer.CURSOR_HSIZE]


func init():
	DisplayServer.cursor_set_shape(DisplayServer.CURSOR_ARROW)
	DisplayServer.cursor_set_custom_image(ARROW, DisplayServer.CURSOR_ARROW)
	DisplayServer.cursor_set_custom_image(IBEAM, DisplayServer.CURSOR_IBEAM)
	DisplayServer.cursor_set_custom_image(CAN_DROP, DisplayServer.CURSOR_CAN_DROP)
	DisplayServer.cursor_set_custom_image(FORBIDDEN, DisplayServer.CURSOR_FORBIDDEN)
	
	DisplayServer.cursor_set_custom_image(BDIAGSIZE, DisplayServer.CURSOR_BDIAGSIZE, Vector2(9,9))
	DisplayServer.cursor_set_custom_image(FDIAGSIZE, DisplayServer.CURSOR_FDIAGSIZE, Vector2(9,9))
	DisplayServer.cursor_set_custom_image(HSIZE, DisplayServer.CURSOR_HSIZE, Vector2(9,9))
	DisplayServer.cursor_set_custom_image(VSIZE, DisplayServer.CURSOR_VSIZE, Vector2(9,9))
	
	DisplayServer.cursor_set_custom_image(POINTING_HAND, DisplayServer.CURSOR_POINTING_HAND, Vector2(9, 3))
	DisplayServer.cursor_set_custom_image(MOVE, DisplayServer.CURSOR_MOVE, Vector2(9,9))
	
	DisplayServer.cursor_set_custom_image(DRAG, DisplayServer.CURSOR_DRAG, Vector2(9,9))
	
	DisplayServer.cursor_set_custom_image(VSPLIT, DisplayServer.CURSOR_VSPLIT, Vector2(9,9))
	DisplayServer.cursor_set_custom_image(HSPLIT, DisplayServer.CURSOR_HSPLIT, Vector2(9,9))
	DisplayServer.cursor_set_custom_image(HELP, DisplayServer.CURSOR_HELP)
	
		
func auto_cursor(index:int, rotation:float, control:Control):
	# FIXME: 进一步优化交互，可以根据旋转设置图标的旋转值
	# 自动根据transform设置鼠标图标
	if index == 0:
		control.mouse_default_cursor_shape = Control.CURSOR_ARROW
	elif index == 5:
		control.mouse_default_cursor_shape = Control.CURSOR_MOVE
	elif index <= 9:
		var ang = rad_to_deg(rotation)
		var offset_index = round(ang/45)
		var _cursor_index
		if index < 5:
			_cursor_index = index-1+offset_index
		else:
			_cursor_index = 9-index+offset_index
		_cursor_index = wrapi(_cursor_index, 0, 4)
		control.mouse_default_cursor_shape = CURSOR_LIST[_cursor_index]
		
	else:
		control.mouse_default_cursor_shape = Control.CURSOR_DRAG
