class_name ImageUtils

const IMAGE_EXTENSION = ["png", "jpg", "jpeg", "webp", "svg"]
const IMAGE_FILETER_EXTENSION = ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg"]


static func is_image_file(path:String) -> bool:
	return path.get_extension().to_lower()  in IMAGE_EXTENSION

static func image_to_64(value:Image) -> String:
	return Marshalls.raw_to_base64(value.save_png_to_buffer())

static func image_from_64(value:String) -> Image:
	var image = Image.new()
	image.load_png_from_buffer(Marshalls.base64_to_raw(value))
	return image
	
static func shrink_image(image:Image, max_size:=1024) -> Image:
	# NOTE: 该方法只会缩小 不会放大
	# 让所有图片的最长边等于max_size，并等比缩放
	var image_size = image.get_size() 
	var aspect :float= image_size.aspect()
	var new_x:float
	var new_y:float
	var small_image :Image = image.duplicate(true)
	if image_size[image_size.max_axis_index()] > max_size:
		if aspect > 1:  # x>y
			new_x = max_size
			new_y = new_x/aspect
		else:
			new_y = max_size
			new_x = new_y*aspect
		small_image.resize(int(new_x), int(new_y))
	return small_image
	
static func shrink_images(images:Array[Image], max_size:=1024) -> Array[Image]:
	# 让所有图片的最长边等于max_size，并等比缩放
	var small_images :Array[Image]= [] 
	for image:Image in images:
		small_images.append(shrink_image(image, max_size))
	return small_images

static func get_all_image_path_from(dir_path:String):
	var image_paths = []
	for file :String in DirAccess.get_files_at(dir_path):
		if file.get_extension().to_lower()  not in IMAGE_EXTENSION:
			continue
		image_paths.append(dir_path.path_join(file))
	return image_paths

static func export_image(image:Image, file_path:String, option_data:={}):
	match file_path.get_extension().to_lower():
		"png": image.save_png(file_path)
		"jpg","jpeg": image.save_jpg(file_path, option_data.get("quality", 0.93)) # 0.93是保存原来尺寸的值
		"webp": image.save_webp(file_path)

static func get_image_data_hash(value:Image):
	return str(hash(value.get_data()))

static func is_same_texture(a:Texture2D, b:Texture2D) -> bool:
	return get_image_data_hash(a.get_image()) == get_image_data_hash(b.get_image())

static func is_same_image(a:Image, b:Image) -> bool:
	return get_image_data_hash(a) == get_image_data_hash(b)

static func create_image_from_file(path:String, max_size:=-1) -> Image:
	var image = Image.load_from_file(path)
	if not image:
		# NOTE: 这里是为了处理一小部分后缀不匹配的图像的
		#		经验上基本只有png和jpg会出现类似问题 所以只处理两种情况
		# WARNING : 此方法会将储存文件以正确格式重新保存
		var buffer = FileAccess.get_file_as_bytes(path)
		image = create_image_from_buffer(buffer)
		if not image:
			return 
		export_image(image, path)
		
	if max_size != -1:
		image = shrink_image(image, max_size)
	return image

static func create_texture_from_file(path:String, max_size:=-1) -> Texture2D:
	var image = create_image_from_file(path, max_size)
	if not image:
		return null
	return ImageTexture.create_from_image(image)

static func create_image_from_buffer(byte_array:PackedByteArray, extension:String="") -> Image:
	# NOTE: 如果 extension 为空则自动尝试所有类型
	var image = Image.new()
	extension = extension.to_lower().strip_edges()
	if extension:
		match extension:
			"png":
				image.load_png_from_buffer(byte_array)
			"jpg","jpeg":
				image.load_jpg_from_buffer(byte_array)
			"webp":
				image.load_webp_from_buffer(byte_array)
			"svg":
				image.load_svg_from_buffer(byte_array)
			_:
				assert(false, "unknown_extension: %s"%extension)
				return 
	else:
		var err = FAILED
		for ext in IMAGE_EXTENSION:
			match ext:
				"png":
					err = image.load_png_from_buffer(byte_array)
				"jpg","jpeg":
					err = image.load_jpg_from_buffer(byte_array)
				"webp":
					err = image.load_webp_from_buffer(byte_array)
				"svg":
					err = image.load_svg_from_buffer(byte_array)
			if err == OK:
				break
		if err == FAILED:
			return 
	return image

static func create_texture_from_buffer(byte_array:PackedByteArray, extension:String) -> Texture2D:
	var image = create_image_from_buffer(byte_array, extension)
	if not image:
		return null
	return ImageTexture.create_from_image(image)

static func open_image_dialog(callback :Callable, muilty_files:=false, dialog_title:="选择图片") :
	if not muilty_files:
		FileUtils.open_file_dialog(callback, dialog_title, [",".join(IMAGE_FILETER_EXTENSION)])
	else:
		FileUtils.open_files_dialog(callback, dialog_title, [",".join(IMAGE_FILETER_EXTENSION)])

## ADVANCE ----------------------------------------------------------------------------------------
static func clip_aspect_image(image:Image, aspect_ratio:float) -> Image:
	# NOTE: 将 image 按照 aspect_rat 裁切
	var image_size = image.get_size()
	var image_aspect = image_size.aspect()
	var w = image_size.x
	var h = image_size.y
	if aspect_ratio > image_aspect:
		h = w/aspect_ratio
	else:
		w = h*aspect_ratio
	var x = (image_size.x-w)*0.5
	var y = (image_size.y-h)*0.5
	return image.get_region(Rect2i(x,y,w,h))

static func image_sequences_merged(images:Array[Image], x_count:int) -> Image:
	# NOTE: 将图片序列整合为一张图
	# WARNING: 所有图片应该有相同的尺寸，默认会使用第一张的尺寸作为基础尺寸
	var image_size:Vector2 = images[0].get_size()
	var total_count = images.size()
	var rect = Rect2(Vector2.ZERO, image_size)
	var image = Image.create_empty(x_count*image_size.x, ceil(total_count/x_count)*image_size.y, false, Image.FORMAT_RGBA8)
	var dst = Vector2.ZERO
	var index = -1
	for src in images:
		index += 1
		dst = Vector2((index % x_count)*image_size.x, (index / x_count)*image_size.y)
		image.blit_rect(src, rect, dst)
	return image

static func hash_image(image:Image) -> String:
	var ctx = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(image.get_data())
	return ctx.finish().hex_encode()

enum BlitMode {BLIT, BLEND}
static func extend_blit_image(base:Image, src:Image, mask:Image, src_rect:Rect2i, dst:Vector2i, mode:=BlitMode.BLIT) -> Dictionary:
	# NOTE: 将两个图整合为一张，可以自动扩展超出的部分
	# NOTE: mask 可以为 null, 为 null 时会调用 blit_rect 方法
	if not base:
		base = Image.create_empty(1, 1, false, Image.FORMAT_RGBA8)
	var base_rect = Rect2i(Vector2i.ZERO, base.get_size())
	var rect = Rect2i(dst, src_rect.size).merge(base_rect)
	if not rect.has_area():
		return {}
	var image = Image.create_empty(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
	image.blit_rect(base, base_rect, -rect.position)
	match mode:
		BlitMode.BLIT:
			if mask == null:
				image.blit_rect(src, src_rect, dst-rect.position)
			else:
				image.blit_rect_mask(src, mask, src_rect, dst-rect.position)
		BlitMode.BLEND:
			if mask == null:
				image.blend_rect(src, src_rect, dst-rect.position)
			else:
				image.blend_rect_mask(src, mask, src_rect, dst-rect.position)
	return {"offset": rect.position, "image":image}
