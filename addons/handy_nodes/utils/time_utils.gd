class_name TimeUtils

static func get_time_stemp() -> String:
	return Time.get_datetime_string_from_system(false, true)

static func get_time_stemp_for_name() -> String:
	return get_time_stemp().replace("-","").replace(":","").replace(" ","")
