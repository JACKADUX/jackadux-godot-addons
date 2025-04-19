extends ColorRect

enum Type {LEFT, TOP, RIGHT, BOTTOM}

@export var scroll_container: ScrollContainer
# TODO: 当需要的时候补充横向的支持
@export var type := Type.LEFT

var scroll_bar: ScrollBar:
	get(): return scroll_container.get_v_scroll_bar() 

func _ready() -> void:
	scroll_bar.value_changed.connect(func(v):
		update(v)
	)
	scroll_container.sort_children.connect(func():
		update(scroll_container.scroll_vertical)
	)
	
func update(v):
	match type:
		Type.LEFT, Type.TOP: 
			color.a = clamp(remap(v, 0, size.y, 0, 1), 0, 1)
		
		Type.RIGHT, Type.BOTTOM:
			var leng = scroll_bar.max_value - scroll_container.size.y
			color.a = clamp(remap(v, leng-size.y, leng, 1, 0), 0, 1)
