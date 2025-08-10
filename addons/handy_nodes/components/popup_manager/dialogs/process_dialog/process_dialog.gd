extends HBoxContainer

@onready var loop: TextureRect = %Loop
@onready var label: Label = %Label

var _max_dot_count = 5
var _auto_dotting = true
var _count = 1
var _context = "Processing"

func _process(_delta: float) -> void:
	if not _auto_dotting:
		return 
	if Engine.get_process_frames()%60==0:
		_count = wrapi(_count+1, 1, _max_dot_count)
		label.text = _context + ".".repeat(_count)

func init(context:String, max_dot_count:=5, auto_dotting:=true):
	_context = context
	_auto_dotting = auto_dotting
	_max_dot_count = max_dot_count
	label.text = context

func set_text(text:String):
	_context = text
