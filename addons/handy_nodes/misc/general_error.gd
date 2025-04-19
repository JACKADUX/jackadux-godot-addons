class_name GeneralError

enum Type {
	OK,
	GENERAL_ERROR,
	JSON_ERROR,
}

var _error : String
var _type : int

func _init(error, type:=Type.GENERAL_ERROR):
	_type = type
	_error = str(error)

func _to_string():
	return _error

func get_type():
	return _type
