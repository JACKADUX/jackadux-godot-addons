class_name ContainerAgent extends Node

@export var container:Node

func get_container() -> Node:
	return container

func add_item(value:Node):
	container.add_child(value)

func get_items() -> Array:
	return container.get_children()

func get_item_count() -> int:
	return container.get_child_count()

func move_item(value:Node, to_index:int):
	container.move_child(value, to_index)

func get_item(index:int) -> Node:
	return container.get_child(index)

func clear():
	for child in container.get_children():
		remove_item(child)

func remove_item(value:Node):
	container.remove_child(value)
	value.queue_free()

func set_container(parent:Node, p_container:Node):
	if parent:
		parent.add_child(self)
	container = p_container
