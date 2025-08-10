# class_name MessageDialog
extends PanelContainer

@onready var close_button = %CloseButton
@onready var label = %Label
@onready var timer = %Timer
@onready var texture_rect = %TextureRect


func _ready():
	close_button.pressed.connect(func():
		out_scene()
	)
	timer.timeout.connect(func():
		out_scene()
	)
	set_align()
	in_scene.call_deferred()

func set_text(value:String):
	label.text = value

func set_color(value:Color):
	self_modulate = value

func set_timer(value:float):
	timer.wait_time = value

func set_texture(value:Texture2D):
	if not value:
		texture_rect.hide()
	else:
		texture_rect.show()
	texture_rect.texture = value

func _input(event):
	if event is InputEventMouseMotion and timer.time_left != 0:
		timer.paused = get_rect().has_point(get_global_mouse_position())

func in_scene():
	var tween: = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	var offset = Vector2(0, 32)
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", global_position, 0.2).from(global_position +offset)
	tween.tween_property(self, "modulate:a", 1., 0.2).from(0.)
	
func out_scene():
	var tween: = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	var offset = Vector2(0, 32)
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", global_position -offset, 0.2).from(global_position)
	tween.tween_property(self, "modulate:a", 0., 0.2).from(1.)
	tween.chain()
	tween.tween_callback(queue_free)
	#queue_free()


func set_align(type:int=0):
	match type:
		0:
			size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			size_flags_vertical = Control.SIZE_SHRINK_CENTER
			grow_horizontal = Control.GROW_DIRECTION_BEGIN
			grow_vertical = Control.GROW_DIRECTION_BEGIN
			anchor_left = 1
			anchor_top = 1
			offset_bottom = -64
			offset_right = -64
