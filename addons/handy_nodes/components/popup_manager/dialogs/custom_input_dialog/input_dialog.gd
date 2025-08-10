#class_name CustomInputDialog 
extends "../custom_confirm_dialog/confirm_dialog.gd"

@onready var line_edit: LineEdit = %LineEdit

func init(title:String, content:String, placeholder_text:String=""):
	super(title, content, "")
	title_label.text = title
	line_edit.text = content
	line_edit.placeholder_text = placeholder_text
	line_edit.grab_focus.call_deferred()
	
	line_edit.select_all()

func get_text() -> String:
	return line_edit.text
