class_name GeneralWidgetAPI

enum Type { CREATE, DELETE, UPDATE, POST, QUREY }

signal requested(type:Type, url:String, data:Dictionary)

static func type_string(value:Type) -> String:
	return Type.keys()[value]

func create(url:String, data:={}):
	requested.emit(Type.CREATE, url, data)

func delete(url:String, data:={}):
	requested.emit(Type.DELETE, url, data)

func update(url:String, data:={}):
	requested.emit(Type.UPDATE, url, data)

func post(url:String, data:={}):
	requested.emit(Type.POST, url, data)

func qurey(url:String, data:={}):
	requested.emit(Type.QUREY, url, data)
