class_name UndoRedoHelper

signal undoredo_changed

var undoredo: UndoRedo


func _init(max_steps:int=50):
	undoredo = UndoRedo.new()
	undoredo.max_steps = max_steps
	undoredo.version_changed.connect(func():
		undoredo_changed.emit()
		#print("undoredo_version:",undoredo.get_version())
	)

func undo():
	if undoredo.has_undo():
		undoredo.undo()
		
func redo():
	if undoredo.has_redo():
		undoredo.redo()

func clear():
	undoredo.clear_history()
	undoredo_changed.emit()

#---------------------------------------------------------------------------------------------------
func add_undoredo(fn:Callable):
	#add_undoredo(func(undoredo:UndoRedo):
		#undoredo.create_action("action_name", UndoRedo.MergeMode.MERGE_DISABLE, true)
		#undoredo.add_do_method(func():
			#pass
		#)
		#undoredo.add_undo_method(func():
			#pass
		#)
		#undoredo.commit_action(true)
	#)
	fn.call(undoredo)

func add_simple_undoredo(action_name:String, fn:Callable, backward_undo := false, execute:=false):
	undoredo.create_action(action_name, UndoRedo.MergeMode.MERGE_DISABLE, backward_undo)
	fn.call(undoredo)
	undoredo.commit_action(execute)

func add_mergends_action(action_name:String, fn:Callable, backward_undo := false, execute:=false):
	# WARNING: MERGE_ENDS 调用间隔超过1s就会被强制中断
	undoredo.create_action(action_name, UndoRedo.MergeMode.MERGE_ENDS, backward_undo)
	fn.call(undoredo)
	undoredo.commit_action(execute)
