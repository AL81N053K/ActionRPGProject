extends Node

const SAVEFILE = "user://config.save"

var game_data = {}

func _ready():
	load_data()

func load_data():
	var file = File.new()
	if not file.file_exists(SAVEFILE):
		game_data = {
			"window_mode": 0,
			"window_size": 0,
			"antialising": 2,
			"vsync": true,
			"bloom": true,
			"blur": 2,
			"display_fps": false,
			"limit_fps": 0,
			"master_vol": 0,
			"music_vol": 0,
			"sfx_vol": 0,
			"colorblind_mode": 0,
			"glitch_effect": true,
			"stamina_bar": 0,
			"debug_console": false,
			"experimental": false
		}
		save_data()
	file.open(SAVEFILE, File.READ)
	game_data = file.get_var()
	file.close()

func save_data():
	var file = File.new()
	file.open(SAVEFILE, File.WRITE)
	file.store_var(game_data)
	file.close()
