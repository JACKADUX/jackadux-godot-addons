class_name GeneralWidgetAPIHandler

func handle_api_requste(type:GeneralWidgetAPI.Type, url:String, data:Dictionary):
	prints(GeneralWidgetAPI.type_string(type), url, data)
	match type:
		GeneralWidgetAPI.Type.CREATE:
			create(url, data)
		GeneralWidgetAPI.Type.DELETE:
			delete(url, data)
		GeneralWidgetAPI.Type.UPDATE:
			update(url, data)
		GeneralWidgetAPI.Type.QUREY:
			qurey(url, data)
		GeneralWidgetAPI.Type.POST:
			post(url, data)

func create(url:String, data:Dictionary):
	match url:
		pass
			
func delete(url:String, data:Dictionary):
	match url:
		pass

func update(url:String, data:Dictionary):
	match url:
		pass
			
func post(url:String, data:Dictionary):
	match url:
		pass
		
func qurey(url:String, data:Dictionary):
	match url:
		pass
