@tool 
extends EditorScript


func _ruxn() -> void:
	var POINTING_HAND :Texture2D = preload("resource/tile_0137.png")
	var CAN_DROP :Texture2D = preload("resource/tile_0160.png")
	var FORBIDDEN :Texture2D = preload("resource/tile_0015.png")
	var VSPLIT :Texture2D = preload("resource/tile_0204.png")
	var HSPLIT :Texture2D = preload("resource/tile_0184.png")
	var IBEAM :Texture2D = preload("resource/tile_0140.png")
	var HELP :Texture2D = preload("resource/tile_0180.png")

	var ARROW :Texture2D = preload("resource/tile_0028.png")
	var BDIAGSIZE :Texture2D = preload("resource/tile_0002.png")
	var FDIAGSIZE :Texture2D = preload("resource/tile_0003.png")
	var HSIZE :Texture2D = preload("resource/tile_0001.png")
	var MOVE :Texture2D = preload("resource/tile_0135.png")
	var DRAG :Texture2D = preload("resource/tile_0136.png")
	var VSIZE :Texture2D = preload("resource/tile_0000.png")
	
	var icons = [ POINTING_HAND, CAN_DROP, FORBIDDEN, VSPLIT, HSPLIT, IBEAM, HELP, ARROW, BDIAGSIZE, FDIAGSIZE, HSIZE, MOVE, DRAG, VSIZE]
	var icons_n = [ "POINTING_HAND", "CAN_DROP", "FORBIDDEN", "VSPLIT", "HSPLIT", "IBEAM", "HELP", "ARROW", "BDIAGSIZE", "FDIAGSIZE", "HSIZE", "MOVE", "DRAG", "VSIZE"]
	
	for i in icons.size():
		icons[i].get_image().save_png("res://addons/quick_contextmenu/icons/cursor/%s.png"%icons_n[i].to_lower())
