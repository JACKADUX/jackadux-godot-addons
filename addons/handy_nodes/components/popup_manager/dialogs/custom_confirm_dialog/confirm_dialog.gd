#class_name CustomConfirmDialog 
extends PanelContainer

signal confirmed
signal canceled
signal optioned

signal any_selected

@onready var title_label: Label = %TitleLabel
@onready var content_label: Label = %ContentLabel
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton
@onready var option_button: Button = %OptionButton

enum State { NONE, CONFIRM, CANCEL, OPTION}
var state := State.NONE

func _ready() -> void:
	confirm_button.pressed.connect(func():
		state = State.CONFIRM
		confirmed.emit()
		any_selected.emit()
	)
	cancel_button.pressed.connect(func():
		state = State.CANCEL
		canceled.emit()
		any_selected.emit()
	)
	option_button.pressed.connect(func():
		state = State.OPTION
		optioned.emit()
		any_selected.emit()
	)

func init(title:String, content:String, option_text:String=""):
	title_label.text = title
	content_label.text = content
	if option_text:
		option_button.text = option_text
		option_button.show()
	else:
		option_button.hide()
	cancel_button.grab_focus.call_deferred()

func is_confirm() -> bool:
	return state == State.CONFIRM
