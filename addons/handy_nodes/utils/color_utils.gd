class_name ColorUtils

static func avg_colors(colors:PackedColorArray):
	var avg = Vector3()
	for c in colors:
		avg.x += c.r
		avg.y += c.g
		avg.z += c.b
	var avgc = avg/float(colors.size())
	return Color(avgc.x, avgc.y, avgc.z, 1)

static func find_nearest_color(color:Color, colors:PackedColorArray) -> Color:
	var dis = INF
	var target_color := color
	for c in colors:
		#var td = Vector3((c.r-color.r),(c.g-color.g),(c.b-color.b))
		#var ls = td.length_squared()
		var ls = color_distance_squared(c, color)
		if ls < dis:
			dis = ls
			target_color = c
	return target_color

# 计算颜色中值
static func get_median_color(colors: Array) -> Color:
	var r = []
	var g = []
	var b = []
	
	for color in colors:
		r.append(color.r)
		g.append(color.g)
		b.append(color.b)
	
	r.sort()
	g.sort()
	b.sort()
	
	var mid = colors.size() / 2 
	return Color(r[mid], g[mid], b[mid])

static func color_distance_squared(c1: Color, c2: Color) -> float:
	return (
		(c1.r - c2.r)*(c1.r - c2.r) +
		(c1.g - c2.g)*(c1.g - c2.g) +
		(c1.b - c2.b)*(c1.b - c2.b)
	)

static func quantize_color(color: Color, step:float) -> Color:
	return Color(
		snapped(color.r, step),
		snapped(color.g, step),
		snapped(color.b, step)
	)

static func quantize_colors(colors: PackedColorArray, step: float) -> PackedColorArray:
	var res_colors := PackedColorArray()
	for color in colors:
		res_colors.append(quantize_color(color, step))
	return res_colors

static func quantize_color_hsv(color: Color, h_step: float, s_step:float, v_step:float) -> Color:
	return Color(
		snapped(color.r, h_step),
		snapped(color.g, s_step),
		snapped(color.b, v_step)
	)

static func quantize_colors_hsv(colors: PackedColorArray, h_step: float, s_step:float, v_step:float) -> PackedColorArray:
	var res_colors := PackedColorArray()
	for color in colors:
		res_colors.append(quantize_color_hsv(color, h_step, s_step, v_step))
	return res_colors

static func quantize_merge_colors(colors: PackedColorArray, h_step: float, s_step:float, v_step:float) -> PackedColorArray:
	var hsvs := {}
	for color in colors:
		var hsv = quantize_color_hsv(color, h_step, s_step, v_step)
		if not hsvs.has(hsv):
			hsvs[hsv] = {}
		hsvs[hsv].get_or_add(color, 0)
		hsvs[hsv][color] += 1
	var d_colors := {}
	for hsv in hsvs:
		var target_colors = hsvs[hsv].keys()
		var c = get_median_color(target_colors)
		var target_c = find_nearest_color(c, target_colors)
		d_colors[target_c] = true
	return PackedColorArray(d_colors.keys())

static func merge_similar_colors(original_colors: PackedColorArray, threshold: float=0.2) -> PackedColorArray:
	# 创建副本避免修改原始列表
	var colors = original_colors.duplicate()
	var merged = false
	
	var threshold_squared = threshold*threshold
	# 当列表长度大于1时持续尝试合并
	while len(colors) > 1 and not merged:
		merged = true  # 假设本轮无合并发生
		
		# 遍历所有颜色组合
		for i in range(len(colors)):
			for j in range(i + 1, len(colors)):
				var color1 = colors[i]
				var color2 = colors[j]
				
				# 检查颜色相似度
				if color_distance_squared(color1, color2) <= threshold_squared:
					# 随机选择保留的颜色（或根据需求修改选择逻辑）
					var keep_index = randi() % 2
					var remove_index = j if keep_index == 0 else i
					var keep_index_val = i if keep_index == 0 else j
					
					# 保留一个颜色并移除另一个
					colors.remove_at(remove_index)
					merged = false  # 发生合并，需要再次检查
					break  # 退出内层循环
			
			if not merged:  # 如果发生合并，重新开始外层循环
				break
	
	return colors

static func get_colors_from_image(image:Image, step:int=1) -> PackedColorArray:
	var colors := PackedColorArray()
	for x in range(0, image.get_width(), step):
		for y in range(0, image.get_height(), step):
			colors.append(image.get_pixel(x, y))
	return colors
