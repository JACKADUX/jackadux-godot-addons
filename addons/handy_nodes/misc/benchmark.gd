class_name Benchmark

static func convert_bit_to(value: int):
	var G = value / (1024.0 * 1024.0 * 1024.0)
	var MB = value / (1024.0 * 1024.0)
	var KB = value / 1024.0
	var B = value
	var key = ["G", "MB", "KB", "B"]
	var values = [G, MB, KB, B]
	for i in values.size():
		if values[i] > 1:
			return "%.02f %s" % [values[i], key[i]]
	return 0

static func get_memory():
	return Performance.get_monitor(Performance.MEMORY_STATIC)
	
static func get_ticks_msec():
	return Time.get_ticks_msec()

static func print_memory(before: float = 0):
	var b = get_memory() - before
	print(convert_bit_to(b))

static func print_ticks_msec(before: float = 0):
	var b = get_ticks_msec() - before
	print(b, " ms")

static func start():
	return Vector2(Time.get_ticks_msec(), get_memory())

static func end(bs):
	# bs -> start_benchmark
	print("time_cost: ", get_ticks_msec() - bs[0], " ms | size: ", convert_bit_to(get_memory() - bs[1]))
