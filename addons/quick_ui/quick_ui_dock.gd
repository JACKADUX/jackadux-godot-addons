@tool
extends PanelContainer

@onready var cmd_container: HFlowContainer = %CmdContainer
@onready var item_container: HFlowContainer = %ItemContainer

@onready var refresh_button: Button = %RefreshButton

var _control_disable_any_buttons :Array[Button]= []

var editor_theme := EditorInterface.get_editor_theme()

func _ready() -> void:
	var selection = EditorInterface.get_selection()
	selection.selection_changed.connect(func():
		var nodes = get_selected_controls()
		var any_selection = nodes.size() > 0
		item_container.visible = bool(nodes.size() == 1)
	)

	refresh_button.pressed.connect(func():
		update()
	)
	update.call_deferred()

func _set_icon(node:Button, key:String, tooltip:=""):
	if not tooltip:
		tooltip = key
	node.icon =editor_theme.get_icon(key,"EditorIcons")
	node.text = ""
	node.tooltip_text = tooltip

func update():
	for child in cmd_container.get_children():
		child.queue_free()
	for child in item_container.get_children():
		child.queue_free()
	var dir = scene_file_path.get_base_dir()
	update_commands(dir.path_join("commands"))
	update_scenes(dir.path_join("scenes"))
	update_scripts(dir.path_join("scripts"))

func update_commands(commands_dir:String):
	for command_name:String in DirAccess.get_files_at(commands_dir):
		if command_name.begins_with("_") or command_name.get_extension() != "gd":
			continue
		var script :Script = load(commands_dir.path_join(command_name))
		var button = Button.new()
		button.tooltip_text = command_name
		button.text = "" if not script.has_method("get_title") else script.get_title() 
		cmd_container.add_child(button)
		var icon_string = "GDScript" if not script.has_method("get_icon_string") else script.get_icon_string()
		button.icon = editor_theme.get_icon(icon_string,"EditorIcons") 
		button.pressed.connect(func():
			# EditorInterface.get_selection().get_selected_nodes()
			script.execute()
		)
func update_scenes(scenes_dir:String):
	var scene_icon = editor_theme.get_icon("PackedScene","EditorIcons")
	for scene_name:String in DirAccess.get_files_at(scenes_dir):
		if scene_name.begins_with("_") or scene_name.get_extension() != "tscn":
			continue
		var scene :PackedScene = load(scenes_dir.path_join(scene_name))
		var button = Button.new()
		button.text = scene_name.get_basename()
		item_container.add_child(button)
		button.icon = scene_icon
		button.pressed.connect(func():
			var node = scene.instantiate()
			var root = EditorInterface.get_edited_scene_root()
			var nodes = EditorInterface.get_selection().get_selected_nodes()
			if nodes.size() != 1:
				return 
			var parent = nodes[0]
			node.scene_file_path = ""
			parent.add_child(node)
			recursive_own_children_to_scene(node, root)
		)

func update_scripts(script_dir:String):
	var script_icon = editor_theme.get_icon("Script","EditorIcons")
	for script_name:String in DirAccess.get_files_at(script_dir):
		if script_name.begins_with("_") or script_name.get_extension() != "gd":
			continue
		var script :Script = load(script_dir.path_join(script_name))
		var button = Button.new()
		button.text = script_name.get_basename()
		item_container.add_child(button)
		button.icon = script_icon
		button.pressed.connect(func():
			var node = script.new()
			var root = EditorInterface.get_edited_scene_root()
			var nodes = EditorInterface.get_selection().get_selected_nodes()
			if nodes.size() != 1:
				return 
			var parent = nodes[0]
			parent.add_child(node)
			recursive_own_children_to_scene(node, root)
		)


func recursive_own_children_to_scene(node, scene_owner):
	node.owner = scene_owner
	for child in node.get_children():
		recursive_own_children_to_scene(child, scene_owner)

func get_selected_controls() -> Array[Control]:
	var nodes = EditorInterface.get_selection().get_selected_nodes()
	var controls :Array[Control]
	controls.assign(nodes.filter(func(node): return node is Control))
	return controls
