extends Node

const SAVEFILE = "user://config.save"

var game_data = {}
onready var file = File.new()
var default = {
	"window_mode": 0,
	"window_size": 1,
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
	"timer": 0,
	"debug_console": false,
	"experimental": false
}

func _ready():
	load_data()
	game_data.merge(default, false)

func load_data():
	if not file.file_exists(SAVEFILE):
		game_data = default
		save_data()
	file.open(SAVEFILE, File.READ)
	game_data = file.get_var()
	file.close()

func save_data():
	file.open(SAVEFILE, File.WRITE)
	file.store_var(game_data)
	file.close()
