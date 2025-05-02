extends RefCounted

static func set_label_text(control:Label, args:=[], kwargs:={}):
	if not kwargs.has("value"):
		control.text = ""
	else:
		control.text = args[0]%kwargs.value
