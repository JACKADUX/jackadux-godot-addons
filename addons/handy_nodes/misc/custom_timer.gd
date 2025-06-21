class_name CustomTimer

signal timeout

static var scene_tree = Engine.get_main_loop()

var _dt :float
var _wait_time:float=1
var _is_stop := true
var _one_shot := true
var _ignore_time_scale := true

func start(wait_time:float=-1):
	if wait_time <= 0:
		wait_time = _wait_time
	_wait_time = wait_time
	_dt = 0
	_is_stop = false
	
func stop():
	_dt = 0
	_is_stop = true

func _update():
	if _is_stop:
		return 
	var delta = scene_tree.root.get_physics_process_delta_time()
	if _ignore_time_scale:
		delta /= Engine.time_scale
	_dt += delta
	if _dt > _wait_time:
		_dt = wrap(_dt, 0, _wait_time)
		timeout.emit()
		if _one_shot:
			_is_stop = true

func queue_free():
	if scene_tree.physics_frame.is_connected(_update):
		scene_tree.physics_frame.disconnect(_update)
	
static func create(wait_time:float=1, one_shot:=true) -> CustomTimer:
	var timer = CustomTimer.new()
	timer._wait_time = wait_time
	timer._one_shot = one_shot
	scene_tree.physics_frame.connect(timer._update)
	return timer
