#class ResourcePathHelper:
extends RefCounted

var gds_pattern = r'load\(["\'].*.gd["\']\)'
var gd_path_pattern = r'["\'].*.gd["\']'
var tscn_pattern = r'load\(["\'].*.tscn["\']\)'
var tscn_path_pattern = r'["\'].*.tscn["\']'

var regex = RegEx.new()

func _trim_edge(str:String)->String:
	str = str.strip_edges()
	str = str.trim_prefix("\'")
	str = str.trim_prefix("\"")
	str = str.trim_suffix("\'")
	str = str.trim_suffix("\"")
	return str

func is_gd_load(code:String) -> bool:
	# NOTE: load 和 preload都能识别
	regex.compile(gds_pattern)
	var result = regex.search(code)
	if not result:
		return false
	return true
	
func get_gd_path(code:String) -> String:
	regex.compile(gd_path_pattern)
	var result = regex.search(code)
	if not result:
		return ""
	return _trim_edge(result.get_string())

func is_tscn_load(code:String) -> bool:
	regex.compile(tscn_pattern)
	var result = regex.search(code)
	if not result:
		return false
	return true
	
func get_tscn_path(code:String) -> String:
	regex.compile(tscn_path_pattern)
	var result = regex.search(code)
	if not result:
		return ""
	return _trim_edge(result.get_string())
