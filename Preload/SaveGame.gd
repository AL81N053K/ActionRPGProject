extends Node

var current_save_data_id = 0
var current_save_data = {
	"max_health": 20,
	"max_mana": 10,
	"max_stamina": 50,
	"max_temp_health": 5,
	"max_sp": 50,
	"health": 20,
	"mana": 20,
	"temp_health": 0,
	"sp": 50,
	"level": 1,
	"experience": 0,
	"base_damage": 4,
	"base_defence": 0,
	"attack_speed": 50,
	"default_speed": 110,
	"speed_add": 0,
	"money": 0,
	"equiped_sp": 0,
	"location": "TestingMap",
	"position": Vector2(0,0),
	"inventory": [],
	"armor_inventory": []
}
var save_file_data = ["","","",""]
var data_template = [
	"max_health",
	"max_mana",
	"max_stamina",
	"max_temp_health",
	"max_sp",
	"health",
	"mana",
	"temp_health",
	"sp",
	"level",
	"experience",
	"base_damage",
	"base_defence",
	"attack_speed",
	"default_speed",
	"speed_add",
	"money",
	"equiped_sp",
	"location",
	"position",
	"inventory",
	"armor_inventory"
]
var to_save = {
	"max_health": 20,
	"max_mana": 20,
	"max_stamina": 50,
	"max_temp_health": 5,
	"max_sp": 50,
	"health": 20,
	"mana": 20,
	"temp_health": 0,
	"sp": 50,
	"level": 1,
	"experience": 0,
	"base_damage": 5,
	"base_defence": 0,
	"attack_speed": 50,
	"default_speed": 110,
	"speed_add": 0,
	"money": 0,
	"equiped_sp": 0,
	"location": "TestingMap",
	"position": Vector2(0,0),
	"inventory": [[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null]],
	"armor_inventory": [[null,null],[null,null],[null,null],[null,null],[null,null]]
}

signal game_saved

func _ready():
	_dir()
	_read_files()

func _read_files():
	for s in range(0,4):
		var save_data = _get_file(s)
		if save_data == false:
			save_file_data[s] = "null"
		else:
			if SaveGame.check_data(s):
				save_file_data[s] = "corrupted"
			else: 
				save_file_data[s] = "working"

func _dir():
	var dir = Directory.new()
	if not dir.file_exists("user://saves/"): 
		dir.open("user://")
		dir.make_dir("saves")

func _get_file(id):
	var file = File.new()
	var result = true
	if not file.file_exists(str("user://saves/Save",id,".save")):
		result = false
	return result

func check_data(id):
	var file = File.new()
	var corrupted = false
	var path = str("user://saves/Save",id,".save")
	if file.file_exists(path):
		file.open(path, File.READ)
		if file.get_len() == 0:
			return true
		var file_save_data = file.get_var()
		for v in data_template.size():
			if file_save_data.has(data_template[v]) == false:
				corrupted = true
		file.close()
	else:
		corrupted = true
	return corrupted

func save_data(id):
	var file = File.new()
	file.open(str("user://saves/Save",id,".save"), File.WRITE)
	file.store_var(current_save_data)
	file.close()
	emit_signal("game_saved")

func load_data(id):
	var file = File.new()
	file.open(str("user://saves/Save",id,".save"), File.READ)
	var data = file.get_var()
	return data

func load_file(id):
	return save_file_data[id]

func create_file(slot):
	var file = File.new()
	file.open(str("user://saves/Save",slot,".save"), File.WRITE)
	file.store_var(to_save)
	file.close()
	_read_files()
