#class FileSystemContextPlugin 
extends EditorContextMenuPlugin


func _popup_menu(paths:PackedStringArray):
	if paths.size() == 1:
		var path = paths[0]
		if path.ends_with(".tscn"):
			add_context_menu_item("Play This Scene", func(_scene:Array):
				EditorInterface.play_custom_scene(path)
				, 
				EditorInterface.get_base_control().get_theme_icon("Play", "EditorIcons")
			)
		if DirAccess.dir_exists_absolute(path):
			var theme = EditorInterface.get_base_control()
			var popup_menu = PopupMenu.new()
			popup_menu.add_icon_item(theme.get_theme_icon("Node", "EditorIcons"), "Node", 100)
			popup_menu.add_icon_item(theme.get_theme_icon("Node2D", "EditorIcons"), "Node2D", 101)
			popup_menu.add_icon_item(theme.get_theme_icon("Control", "EditorIcons"), "Control", 102)
			popup_menu.add_icon_item(theme.get_theme_icon("PanelContainer", "EditorIcons"), "PanelContainer", 103)
			popup_menu.id_pressed.connect(func(id:int):
				var code :String= """"""
				var node:Node
				match id:
					100:
						node = Node.new()
						code = """extends Node\n\nfunc _ready(): pass"""
					101:
						node = Node2D.new()
						code = """extends Node2D\n\nfunc _ready(): pass"""
					102:
						node = Control.new()
						code = """extends Control\n\nfunc _ready(): pass"""
					103:
						node = PanelContainer.new()
						code = """extends PanelContainer\n\nfunc _ready(): pass"""
				DisplayServer.dialog_input_text("Create Scene:", "cancel by return empty", "", func(text:String):
					create_scene(text, path, node, code)
				)
			)
			add_context_submenu_item("Quick Create Scene", popup_menu, theme.get_theme_icon("PackedScene", "EditorIcons"))

			
static func create_scene(scene_name:String, scene_dir:String, node:Node, script_code:String):
	if not scene_name:
		return 
	scene_dir = scene_dir.path_join(scene_name)
	var scene_path = scene_dir.path_join(scene_name+".tscn")
	var script_path = scene_dir.path_join(scene_name+".gd")
	if FileAccess.file_exists(scene_path):
		EditorInterface.get_editor_toaster().push_toast("无法新建场景:场景'%s'已经存在"%scene_name, 1)
		return 
	var scene = PackedScene.new()
	node.name = scene_name.to_pascal_case()
	DirAccess.make_dir_recursive_absolute(scene_dir)
	var gdscript = GDScript.new()
	gdscript.source_code=script_code
	gdscript.resource_path = script_path
	node.set_script(gdscript)
	scene.pack(node)
	ResourceSaver.save(gdscript, script_path)
	ResourceSaver.save(scene, scene_path)
	EditorInterface.open_scene_from_path(scene_path)
	EditorInterface.get_resource_filesystem().scan()
