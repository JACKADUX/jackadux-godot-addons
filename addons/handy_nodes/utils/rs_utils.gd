class_name RSUtils  # RenderingServer 

enum TextureFitType {
	FREE,
	AUTO,
	COVERED,
	HEIGHT,
	WIDTH,
}

enum LableWarpMode {
	NONE,
	LETTER,
	WORD,
}

enum HorizontalAlignment {
	LEFT,
	CENTER,
	RIGHT,
	FILL,
}

enum VerticalAlignment {
	TOP,
	CENTER,
	BOTTOM,
	FILL,
}

static var style_box_flat := StyleBoxFlat.new()
static var font := FontVariation.new()

static func draw_rect(item:RID, rect:Rect2, color:Color, filled:= true, width:float=-1, antialiased: bool = false):
	if filled:
		RenderingServer.canvas_item_add_rect(item, rect, color, antialiased)
		return
	var points :PackedVector2Array = []
	points.append(rect.position)
	points.append(Vector2(rect.end.x, rect.position.y))
	points.append(rect.end)
	points.append(Vector2(rect.position.x, rect.end.y))
	points.append(points[0])
	var colors = PackedColorArray()
	colors.resize(4)
	colors.fill(color)
	RenderingServer.canvas_item_add_polyline(item, points, colors, width, antialiased)

#---------------------------------------------------------------------------------------------------
static func draw_polyline(item:RID, points:PackedVector2Array, color:Color, width:float=-1, antialiased:bool=false):
	var colors = PackedColorArray()
	colors.resize(points.size()-1)
	colors.fill(color)
	RenderingServer.canvas_item_add_polyline(item, points, colors, width, antialiased)

#---------------------------------------------------------------------------------------------------
static func draw_texture_frame(rid:RID, texture:Texture2D, frame_size:Vector2, fit_type:=TextureFitType.AUTO, clip:=false, regin:=[0,0,1,1], tile:= false, alpha:=1.0, flip_h:=false, flip_v:=false):
	if not texture:
		return 
	
	var texture_size := texture.get_size()
	var rect := Rect2(Vector2.ZERO, frame_size)
	var src_rect := Rect2(Vector2.ZERO, texture_size)
	
	# debug
	#clip = true
	#regin = [0.1, 0.2, 0.4, 0.4]
	#regin = [0.7,0.8, 1, 1]
	#fit_type = TextureFitType.HEIGHT
	
	if tile:
		texture.draw_rect(rid, rect, true)
		return 
			
	var rect_aspect = frame_size.aspect()
	var texture_aspect =  texture_size.aspect()
	# 应用 regin 后的贴图比例
	var texture_regin_aspect = (texture_size.x*(regin[2]-regin[0])) / (texture_size.y*(regin[3]-regin[1]))
	
	rect.size.x = frame_size.x/(regin[2]-regin[0]) if regin[2] != regin[0] else 0
	rect.size.y = frame_size.y/(regin[3]-regin[1]) if regin[3] != regin[1] else 0
	
	rect.position.x = -rect.size.x*regin[0]
	rect.position.y = -rect.size.y*regin[1]
	
	match fit_type :
		TextureFitType.FREE: # 自由缩放
			pass
		
		TextureFitType.AUTO, TextureFitType.COVERED: # 自适应缩放
			#clip = false # 不需要
			var type = texture_regin_aspect < rect_aspect if fit_type == TextureFitType.AUTO else texture_regin_aspect > rect_aspect
			if type:
				rect.size.x = rect.size.y*texture_aspect
				var off = 0.5 -(regin[0]+regin[2])*0.5
				rect.position.x = (frame_size.x-rect.size.x)*0.5 + rect.size.x*off
			else:
				rect.size.y = rect.size.x/texture_aspect
				var off = 0.5 -(regin[1]+regin[3])*0.5
				rect.position.y = (frame_size.y-rect.size.y)*0.5 + rect.size.y*off
				
		TextureFitType.HEIGHT: # 高度适配
			rect.size.x = rect.size.y*texture_aspect
			var off = 0.5 -(regin[0]+regin[2])*0.5
			rect.position.x = (frame_size.x-rect.size.x)*0.5 + rect.size.x*off

		TextureFitType.WIDTH: # 宽度适配
			rect.size.y = rect.size.x/texture_aspect
			var off = 0.5 -(regin[1]+regin[3])*0.5
			rect.position.y = (frame_size.y-rect.size.y)*0.5 + rect.size.y*off
			
		
	#texture.draw_rect_region(rid, rect, src_rect, Color(1,1,1,0.4))
	
	var src_real_rect = Rect2()
	if clip:
		src_real_rect.position.x = rect.position.x + rect.size.x*regin[0]
		src_real_rect.position.y = rect.position.y + rect.size.y*regin[1]
		src_real_rect.size.x = rect.size.x*(regin[2]-regin[0])
		src_real_rect.size.y = rect.size.y*(regin[3]-regin[1])
		
		src_real_rect = src_real_rect.intersection(Rect2(Vector2.ZERO, frame_size))
		
		# 如果比reing小则需要缩小范围
		var rx1 = (src_real_rect.position.x-rect.position.x)/ rect.size.x
		var ry1 = (src_real_rect.position.y-rect.position.y)/ rect.size.y
		var rx2 = (src_real_rect.end.x-rect.position.x)/ rect.size.x
		var ry2 = (src_real_rect.end.y-rect.position.y)/ rect.size.y
		
		rx1 = max(regin[0], rx1)
		ry1 = max(regin[1], ry1)
		rx2 = min(regin[2], rx2)
		ry2 = min(regin[3], ry2)
		
		src_rect.position.x = texture_size.x*rx1
		src_rect.position.y = texture_size.y*ry1
		src_rect.size.x = texture_size.x*(rx2-rx1)
		src_rect.size.y = texture_size.y*(ry2-ry1)
		
		rect = src_real_rect
	if flip_h:
		rect.size.x = -rect.size.x
	if flip_v:
		rect.size.y = -rect.size.y
	texture.draw_rect_region(rid, rect, src_rect, Color(1,1,1,alpha))
	#if clip:
	#	draw_debug_frame(rid, src_real_rect, Color.RED)
	
#---------------------------------------------------------------------------------------------------
static func draw_label_frame(rid:RID, text, font_data:Dictionary, rect:Rect2):
	font.base_font = font_data.get("font", null)
	var font_size = max(1, font_data.font_size)
	var ascent = font.get_ascent(font_size)
	
	var width = max(rect.size.x, 0) 

	font.set_variation_embolden(1.2 if font_data.embolden else 0.0)
	font.set_spacing(TextServer.SpacingType.SPACING_GLYPH, font_data.letter_spacing)
	font.set_spacing(TextServer.SpacingType.SPACING_BOTTOM, font_data.line_separation)
	
	var horizontal_alignment = font_data.horizontal_alignment

	var warp = TextServer.BREAK_NONE | TextServer.BREAK_MANDATORY
	match font_data.warp_mode:
		LableWarpMode.LETTER: warp = TextServer.BREAK_GRAPHEME_BOUND | TextServer.BREAK_MANDATORY
		LableWarpMode.WORD: warp = TextServer.BREAK_WORD_BOUND | TextServer.BREAK_MANDATORY
	
	# FIXME: horizontal_alignment fill 无法正常工作，因为未知原因会造成文字闪烁消失
	var justify = TextServer.JUSTIFICATION_KASHIDA | TextServer.JUSTIFICATION_WORD_BOUND 
	var max_lines = -1
	#var max_lines = int(rect.size.y / font.get_height(font_size))+1
	var real_size = font.get_multiline_string_size(text, horizontal_alignment, width, font_size, max_lines, warp, justify)
	match font_data.vertical_alignment:
		VerticalAlignment.CENTER: rect.position.y -= (real_size.y - rect.size.y -font_data.line_separation)*0.5
		VerticalAlignment.BOTTOM: rect.position.y -= (real_size.y - rect.size.y -font_data.line_separation)
	
	# debug_rect:
	# draw_rect(rid, rect, Color.BLACK, false, 2)
		
	if font_data.outline_size != 0:
		font.draw_multiline_string_outline(rid, rect.position +  Vector2(0, ascent), text, 
								horizontal_alignment, width, font_size, max_lines, font_data.outline_size, font_data.outline_color, warp, justify)
	
	font.draw_multiline_string(rid, rect.position +  Vector2(0, ascent), text, 
								horizontal_alignment, width, font_size, max_lines, font_data.color, warp, justify)
