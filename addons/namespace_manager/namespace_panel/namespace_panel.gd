@tool
extends PanelContainer

@onready var add_button: Button = %AddButton
@onready var update_button: Button = %UpdateButton
@onready var package_data_v_box: VBoxContainer = %PackageDataVBox

const PackageDataPanel = preload("package_data_panel.gd")
const PACKAGE_DATA_PANEL = preload("package_data_panel.tscn")

const CodeGenerater = preload("../misc/code_generater.gd")
var code_generater := CodeGenerater.new()

var package_datas :Array[PackageData]= []


func _ready() -> void:
	update_button.pressed.connect(func():
		save_data()
		update_namespace()
	)
	
	add_button.pressed.connect(func():
		add_package("")
	)
	
	load_data()
	update_namespace()

func save_data():
	ProjectSettings.set_setting("namespace_manager/package_datas", serialize())


func load_data():
	var sk_package_datas = "namespace_manager/package_datas"
	if ProjectSettings.has_setting(sk_package_datas):
		deserialize(ProjectSettings.get_setting(sk_package_datas))
	update()
	
func serialize() -> Dictionary:
	return {
		"datas":package_datas.map(func(pd): return pd.serialize())
	}
	
func deserialize(data:Dictionary):
	package_datas.assign(data.get("datas",[]).map(func(d): return PackageData.create_with(d)))
	
func add_package(path:String):
	var package = PackageData.new()
	package.path = path
	package_datas.append(package)
	update()
	save_data()

func delete_package(id:int):
	for package_data in package_datas:
		if package_data.get_id() == id:
			package_datas.erase(package_data)
			update()
			save_data()
			return 

func update():
	for child in package_data_v_box.get_children():
		child.queue_free()
	
	for package_data:PackageData in package_datas:
		var panel : PackageDataPanel = PACKAGE_DATA_PANEL.instantiate()
		package_data_v_box.add_child(panel)
		panel.update(package_data.serialize())
		panel.data_changed.connect(func(key:String, value:Variant):
			package_data.set(key, value)
			if key == "enable":
				update_namespace()
			save_data()
		)
		panel.delete_requested.connect(func():
			delete_package(package_data.get_id())
		)
	update_namespace()


func update_namespace():
	var paths = package_datas.filter(func(pd): return pd.enable).map(func(pd): return pd.path)
	var files = code_generater.update(paths)
	if files:
		EditorInterface.get_resource_filesystem().scan.call_deferred()
	


class PackageData:
	var path:String
	var enable:bool=true
	
	func get_id() -> int:
		return get_instance_id()
	
	func serialize() -> Dictionary:
		return {
			"id":get_instance_id(),
			"path":path,
			"enable":enable
		}	
	func deserialize(data:Dictionary) -> void:
		path = data.get("path","")
		enable = data.get("enable",true)
	
	static func create_with(data:Dictionary) -> PackageData:
		var pd = PackageData.new()
		pd.deserialize(data)
		return pd
