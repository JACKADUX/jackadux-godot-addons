@tool
extends Control
@onready var button_update = %ButtonUpdate
@onready var button_web = %ButtonWeb
@onready var button_web_2: Button = %ButtonWeb2
@onready var color_picker_button = %ColorPickerButton
@onready var button_save = %ButtonSave

@onready var text_edit = %TextEdit
@onready var line_edit_path = %LineEditPath
@onready var line_edit_name: LineEdit = %LineEditName
@onready var button_create_folder = %ButtonCreateFolder

@onready var texture_rect_ori = %TextureRectOri
@onready var size_buttons: HBoxContainer = %SizeButtons
@onready var size_spin_box: SpinBox = %SizeSpinBox
@onready var option_button_extension: OptionButton = %OptionButtonExtension


var save_path = ""
var file_name := ""
var file_extension := ""
var svg_text := ""

var icon_size := 24
var icon_color = Color.WHITE

var file_system : EditorFileSystem:
	get():
		if OS.has_feature("editor"):
			return EditorInterface.get_resource_filesystem()
		else:
			return null

func _ready():
	
	option_button_extension.item_selected.connect(func(index):
		_file_path_updated()
	)
	
	size_spin_box.value_changed.connect(func(v):
		icon_size = v
		update_texture()
	)
	
	for button:Button in size_buttons.get_children():
		button.pressed.connect(func():
			icon_size = int(button.name.replace("Button",""))
			update_texture()
		)
	
	button_web.pressed.connect(func():
		OS.shell_open("https://tabler.io/icons")
	)
	button_web_2.pressed.connect(func():
		OS.shell_open("https://fonts.google.com/icons?selected=Material+Symbols+Outlined:search:FILL@0;wght@400;GRAD@0;opsz@24&icon.size=24&icon.color=%23FFFFFF")
	)
	
	line_edit_path.text_changed.connect(func(t):
		_file_path_updated()
	)
	line_edit_name.text_changed.connect(func(t):
		_file_path_updated()
	)
	
	text_edit.text_changed.connect(func():
		svg_text = text_edit.text
		update_texture()
	)
	button_update.pressed.connect(func():
		_file_path_updated()
		update_texture()
	)
	color_picker_button.color_changed.connect(func(c):
		icon_color = color_picker_button.color
		update_texture()
	)


	button_save.pressed.connect(func():
		var file_path = save_path.path_join(file_name+"."+file_extension)
		var image = get_image()
		match file_extension:
			"png":
				image.save_png(file_path)
			"svg":
				var file = FileAccess.open(file_path, FileAccess.WRITE)
				file.store_string(svg_text)
		_file_path_updated()
		if file_system:
			file_system.scan()
			file_system.scan_sources()
	)
	button_create_folder.pressed.connect(func():
		DirAccess.make_dir_recursive_absolute(save_path)
		if file_system:
			file_system.scan()
	)
	save_path = line_edit_path.text
	button_create_folder.visible = not DirAccess.dir_exists_absolute(save_path)
	svg_text = text_edit.text
	_file_path_updated()
	update_texture()


func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	# check that the data is a Dictionary and has a files key
	return data is Dictionary and data.has('files')


func _drop_data(at_position: Vector2, data: Variant) -> void:
	# Get the dropped files, filter by extension tscn
	var files = (data.get("files", []) as Array).filter(func(file:String): return file.get_extension() == "svg")
	if not files:
		return 
	var file :String = files.front()
	line_edit_name.text = file.get_file().get_basename()
	option_button_extension.select(0)
	svg_text = FileAccess.get_file_as_string(file)
	update_texture()


func _file_path_updated():
	save_path = line_edit_path.text
	file_name = line_edit_name.text
	file_extension = option_button_extension.get_item_text(option_button_extension.selected)
	
	var file_path = save_path.path_join(file_name+"."+file_extension)
	button_create_folder.visible = not DirAccess.dir_exists_absolute(save_path)
	button_save.disabled = not file_name or not DirAccess.dir_exists_absolute(save_path)
	var text = "Save"
	if FileAccess.file_exists(file_path):
		text = "Override"
	button_save.text = text

	
func update_text():
	if not svg_text:
		return 
	var svg_helper = SVGHelper.new(svg_text)
	var color = icon_color.to_html(false)
	svg_helper.modify_svg_parameter("svg", "fill", "#"+color)
	svg_helper.modify_svg_parameter("svg", "stroke", "#"+color)
	svg_helper.modify_svg_parameter("svg", "width", str(icon_size))
	svg_helper.modify_svg_parameter("svg", "height", str(icon_size))
	svg_helper.modify_svg_parameter("path", "fill", "#"+color)
	svg_helper.modify_svg_parameter("path", "stroke", "#"+color)
	svg_text = svg_helper.get_text()
	text_edit.text = svg_text

func get_image(scale_svg:float =1) ->Image:
	var image = Image.new()
	image.load_svg_from_string(svg_text, scale_svg)
	return image
	
func update_texture():
	update_text()
	if not svg_text:
		texture_rect_ori.texture = null
		return 
	var image = get_image()
	var texture = ImageTexture.create_from_image(image)
	texture_rect_ori.texture = texture



class SVGHelper extends XMLParser:
	var _buffer:PackedByteArray
	var _text:String
	func _init(svg_text: String) -> void:
		set_text(svg_text)
	
	func set_text(svg_text: String):
		_text = svg_text
		_buffer = _text.to_utf8_buffer()
	
	func get_svg_parameter(key: String):
		open_buffer(_buffer)
		while read() == OK:
			match get_node_type():
				XMLParser.NODE_ELEMENT:
					# 处理开始标签和属性
					var tag = get_node_name()
					var attrs = {}
					for i in get_attribute_count():
						var attr_name = get_attribute_name(i)
						var attr_value = get_attribute_value(i)
						if attr_name == key:
							return attr_value
		return null
	
	func get_text() -> String:
		return _text
		
	func _debug():
		open_buffer(_buffer)
		while read() == OK:
			match get_node_type():
				XMLParser.NODE_ELEMENT:
					# 处理开始标签和属性
					var tag = get_node_name()
					var attrs = {}
					for i in get_attribute_count():
						var attr_name = get_attribute_name(i)
						var attr_value = get_attribute_value(i)
						prints(tag, attr_name, attr_value)
				
							
	func modify_svg_parameter(svg_tag:String, key: String, value: String) -> String:
		open_buffer(_buffer)
		var output := PackedStringArray()
		var _any_changed = false
		while read() == OK:
			match get_node_type():
				XMLParser.NODE_ELEMENT:
					# 处理开始标签和属性
					var tag = get_node_name()
					var attrs = {}
					for i in get_attribute_count():
						var attr_name = get_attribute_name(i)
						var attr_value = get_attribute_value(i)
						if svg_tag != tag or attr_name != key or attr_value == "none":
							attrs[attr_name] = attr_value 
						else:
							attrs[attr_name] = value
							_any_changed = true
					# 构建属性字符串
					var attr_str = ""
					for attr in attrs:
						attr_str += ' %s="%s"' % [attr, attrs[attr]]
					# 自闭合标签处理
					if is_empty():
						output.append("<%s%s/>" % [tag, attr_str])
					else:
						output.append("<%s%s>" % [tag, attr_str])
				XMLParser.NODE_TEXT:
					# 保留文本内容
					output.append(get_node_data())
				XMLParser.NODE_ELEMENT_END:
					# 闭合标签
					output.append("</%s>" % get_node_name())
		if _any_changed:
			_text = "".join(output)
			_buffer = _text.to_utf8_buffer()
		return _text

	
