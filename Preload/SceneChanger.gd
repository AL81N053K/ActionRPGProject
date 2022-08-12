extends Node

export var max_load_time = 10000

var main_scene = ""
signal loaded

func goto_scene(path, current_scene):
	var loader = ResourceLoader.load_interactive(path)
	
	if loader == null:
		print("Resource loader unable to load the resource path")
		return
	
	var loading_bar = load("res://Preload/ProgressBar.tscn").instance()
	
	get_tree().get_root().call_deferred('add_child',loading_bar)
	
	var t = OS.get_ticks_msec()
	
	while OS.get_ticks_msec() - t < max_load_time:
		var err = loader.poll()
		if err == ERR_FILE_EOF:
			# Loading Complete
			var rescource = loader.get_resource()
			var instance = rescource.instance()
			get_tree().get_root().call_deferred('add_child',instance)
			current_scene.queue_free()
			emit_signal("loaded")
			print(instance.name)
			if instance.name != "MainMenu":
				Music.SetGameState("Explore")
			if instance.name == "MainMenu":
				Music.SetGameState("MainMenu")
			break
		elif err == OK:
			# Still loading
			var progress = float(loader.get_stage())/loader.get_stage_count()
			loading_bar.get_node("ProgressBar").value = progress * 100 
		else:
			print("Error while loading file")
			break
		yield(get_tree(),"idle_frame")
