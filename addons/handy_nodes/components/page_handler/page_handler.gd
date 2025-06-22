class_name PageHandler extends PanelContainer

signal first_page_requested
signal prev_page_requested
signal next_page_requested
signal last_page_requested

@onready var first_button: Button = %FirstButton
@onready var prev_button: Button = %PrevButton
@onready var info_label: Label = %InfoLabel
@onready var next_button: Button = %NextButton
@onready var last_button: Button = %LastButton

@export var info := "第 %d 页  |  总共 %d 页"


func debug():
	var _debug_count = 0
	update(_debug_count, 20)
	prev_page_requested.connect(func():
		_debug_count -= 1
		update(_debug_count, 20)
	)
	next_page_requested.connect(func():
		_debug_count += 1
		update(_debug_count, 20)
	)
	first_page_requested.connect(func():
		_debug_count = 0
		update(_debug_count, 20)
	)
	last_page_requested.connect(func():
		_debug_count = 20
		update(_debug_count, 20)
	)
	
func _ready() -> void:
	first_button.pressed.connect(func():
		first_page_requested.emit()
	)
	prev_button.pressed.connect(func():
		prev_page_requested.emit()
	)
	next_button.pressed.connect(func():
		next_page_requested.emit()
	)
	last_button.pressed.connect(func():
		last_page_requested.emit()
	)
	
func update(current_page:int, total_page:int):
	if total_page <= 1:
		hide()
	else:
		show()
	# current_page 可以为 0
	total_page = max(1, total_page)
	current_page = clamp(current_page+1, 1, total_page)
	info_label.text = info%[current_page, total_page]
	first_button.disabled = current_page == 1
	prev_button.disabled = current_page == 1
	next_button.disabled = current_page == total_page
	last_button.disabled = current_page == total_page


static func get_page_content(arr:Array, page:int, page_content_number:int) -> Array:
	if page_content_number > 0:
		var begin = page*page_content_number
		var end = begin + page_content_number
		arr = arr.slice(begin, end)
	return arr
	
static func get_page_count(content_total_count:int, page_content_number:int) -> int:
	if page_content_number > 0:
		return int(ceil(content_total_count/float(page_content_number)))
	return 1
	
