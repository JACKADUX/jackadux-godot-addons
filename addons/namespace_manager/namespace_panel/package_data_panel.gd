@tool
extends HBoxContainer

signal data_changed(key:String, value:Variant)
signal delete_requested

@onready var check_box: CheckBox = %CheckBox
@onready var line_edit: LineEdit = %LineEdit
@onready var close_button: Button = %CloseButton

const META_MODEL_DATA := "META_MODEL_DATA"

func _ready() -> void:
	check_box.pressed.connect(func():
		data_changed.emit("enable", check_box.button_pressed)
	)
	line_edit.text_changed.connect(func(value):
		data_changed.emit("path", value)
	)
	close_button.pressed.connect(func():
		delete_requested.emit()
	)
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data is not Dictionary or not data.has('files'):
		return false
	if data.files.size() != 1:
		return false
	return data.files[0].get_extension() == ""

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var file :String = data.files[0]
	file = file.trim_suffix("/")
	line_edit.text = file
	data_changed.emit("path", file)

func update(package_data:Dictionary):
	set_meta(META_MODEL_DATA, package_data)
	
	check_box.set_pressed_no_signal(package_data.get("enable", true))
	line_edit.text = package_data.get("path", "")
