extends RefCounted

const code := """
extends Control

func _ready():
	pass

"""

static func get_icon_string() -> String:
	return "GDScript"

static func get_title() -> String:
	return "CreateTestScene"

static func execute():
	DisplayServer.dialog_input_text("创建测试场景:", "如果想取消返回空名称", "", func(text:String):
		create_test_scene(text, "res://test")
	)

static func create_test_scene(scene_name:String, scene_dir:String):
	if not scene_name:
		return 
	var test_scene_name = "test_"+scene_name
	scene_dir = scene_dir.path_join(test_scene_name)
	var scene_path = scene_dir.path_join(test_scene_name+".tscn")
	var script_path = scene_dir.path_join(test_scene_name+".gd")
	if FileAccess.file_exists(scene_path):
		EditorInterface.get_editor_toaster().push_toast("无法新建场景:场景'%s'已经存在"%test_scene_name, 1)
		return 
	var scene = PackedScene.new()
	var node = Control.new()
	node.name = test_scene_name.to_pascal_case()
	node.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	node.size_flags_vertical = Control.SIZE_EXPAND_FILL
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	DirAccess.make_dir_recursive_absolute(scene_dir)
	var gdscript = GDScript.new()
	gdscript.source_code=code
	gdscript.resource_path = script_path
	node.set_script(gdscript)
	scene.pack(node)
	ResourceSaver.save(gdscript, script_path)
	ResourceSaver.save(scene, scene_path)
	EditorInterface.open_scene_from_path(scene_path)
	EditorInterface.get_resource_filesystem().scan()

#static func input_dialog() -> PopupPanel:
	#var popop_panel = PopupPanel.new()
	#var control = PanelContainer.new()
	#popop_panel.add_child(control)
	#control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE)
	#var hbox = HBoxContainer.new()
	#control.add_child(hbox)
	#hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#var label = Label.new()
	#hbox.add_child(label)
	#label.text = "测试场景名称:"
	#var line_edit = LineEdit.new()
	#hbox.add_child(line_edit)
	#line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#return popop_panel
