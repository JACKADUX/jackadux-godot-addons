class_name Result

signal finished

enum ResultType {
	OK,
	FAILED,
}

var _type := ResultType.OK
var _data :={}
var _msg := ""

func _to_string() -> String:
	var type = ResultType.keys()[_type]
	var data = "::"+JSON.stringify(_data) if _data else ""
	var msg = "::"+_msg if _msg else ""
	return "Result::%s%s%s"%[type, msg, data]

func get_result() -> Dictionary:
	return {"code":_type, "data":_data, "msg":_msg}

func set_type(type:ResultType) -> Result:
	_type = type
	return self

func set_data(data:={}) -> Result:
	_data.assign(data)
	return self

func get_data() -> Dictionary:
	return _data

func set_message(msg:String)  -> Result:
	_msg = msg
	return self
	
func get_message() -> String:
	return _msg

func is_ok() -> bool:
	return _type == ResultType.OK

func raise_finished():
	finished.emit()

static func OK(data:Dictionary, msg:="") -> Result:
	return Result.new().set_type(ResultType.OK).set_data(data).set_message(msg)

static func FAILED(msg:="", data:Dictionary={})-> Result:
	return Result.new().set_type(ResultType.FAILED).set_message(msg).set_data(data)
