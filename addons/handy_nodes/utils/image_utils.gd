class_name ImageUtils

const IMAGE_EXTENSION = ["png", "jpg", "jpeg", "webp", "svg"]
const IMAGE_FILETER_EXTENSION = ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.svg"]

static func is_image_file(path:String) -> bool:
	return path.get_extension() in IMAGE_EXTENSION

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
		if file.get_extension() not in IMAGE_EXTENSION:
			continue
		image_paths.append(dir_path.path_join(file))
	return image_paths

static func export_image(image:Image, file_path:String):
	match file_path.get_extension():
		"png": image.save_png(file_path)
		"jpg","jpeg": image.save_jpg(file_path)
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

static func file_dialog(title:String="Files", filter=[], mode=DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, current_directory: String="", filename: String="") -> Array:
	var files = []
	var blocker = AwaitBloker.new()
	var _on_folder_selected = func(status:bool, selected_paths:PackedStringArray, selected_filter_index:int):
		if not status:
			return
		files.append_array(selected_paths)
		blocker.go_on_deferred()
	
	DisplayServer.file_dialog_show(title, current_directory, filename,false,
								mode,
								filter,
								_on_folder_selected)
	await blocker.continued
	return files

static func open_image_dialog(muilty_files:=false) -> Array:
	var _dialog_title := "选择图片"
	var files := []
	if not muilty_files:
		files = await file_dialog(_dialog_title, [",".join(IMAGE_FILETER_EXTENSION)], DisplayServer.FILE_DIALOG_MODE_OPEN_FILE)
	else:
		files = await file_dialog(_dialog_title, [",".join(IMAGE_FILETER_EXTENSION)], DisplayServer.FILE_DIALOG_MODE_OPEN_FILES)
	return files

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
