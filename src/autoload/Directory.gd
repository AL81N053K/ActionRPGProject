extends Node

var exe_path = OS.get_executable_path().get_base_dir()
var debug_path = ProjectSettings.globalize_path("res://")
var cur_dir = exe_path + "/" if OS.is_debug_build() == false else debug_path

func get_dirs(path:String)->Array:
	var folders:Array = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				folders.append(file_name)
			file_name = dir.get_next()
	return folders

func get_files(path, type)->Array:
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if not ".import" in file_name:
					if type in file_name:
						files.append(file_name)
			file_name = dir.get_next()
	return files
