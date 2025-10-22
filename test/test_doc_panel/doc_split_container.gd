# class DocSplitContainer
extends SplitContainer
	
func _process(_delta: float) -> void:
	var count = get_child_count()
	if count == 2:
		return 
	if count == 1:
		var child = get_child(0)
		remove_child(child)
		replace_by(child)
	queue_free()
