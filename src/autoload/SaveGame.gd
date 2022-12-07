extends Node

var current_save:String = ""
var c_save_data = {
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
	"time": 6.0,
	"inventory": [[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null]],
	"armor_inventory": [[null,null],[null,null],[null,null],[null,null],[null,null]]
}
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
	"time",
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
	"time": 6.0,
	"inventory": [[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null],[null,null]],
	"armor_inventory": [[null,null],[null,null],[null,null],[null,null],[null,null]]
}

onready var dir = Directory.new()
onready var file = File.new()

func _ready():
	_dir()

func _dir():
	if not dir.file_exists("user://saves/"): 
		dir.open("user://")
		dir.make_dir("saves")

func _get_file(id):
	var result = true
	if not file.file_exists(str("user://saves/",id,".sav")):
		result = false
	return result

func check_data(id):
	var corrupted = false
	var path = "user://saves/%s.sav" % id
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

func fix_save(save):
	c_save_data = to_save
	var path = "user://saves/%s.sav" % save
	if file.file_exists(path):
		file.open(path, File.READ)
		var file_save_data = file.get_var()
		for v in data_template.size():
			if file_save_data.has(data_template[v]) == true:
				c_save_data[data_template[v]] = file_save_data[data_template[v]]
		save_data(save)

func save_data(id):
	file.open(str("user://saves/",id,".sav"), File.WRITE)
	file.store_var(c_save_data)
	file.close()
	EventBus.emit_signal("game_saved")

func load_data(id):
	file.open(str("user://saves/",id,".sav"), File.READ)
	var data = file.get_var()
	return data

func create_file(slot):
	file.open(str("user://saves/",slot,".sav"), File.WRITE)
	file.store_var(to_save)
	file.close()

func _save():
	c_save_data.max_health = PlayerStats.max_health
	c_save_data.max_mana = PlayerStats.max_mana
	c_save_data.max_stamina = PlayerStats.max_stamina
	c_save_data.max_temp_health = PlayerStats.max_temp_health
	c_save_data.max_sp = PlayerStats.max_sp
	c_save_data.health = PlayerStats.max_health
	c_save_data.mana = PlayerStats.max_mana
	c_save_data.temp_health = PlayerStats.temp_health
	c_save_data.sp = PlayerStats.sp
	c_save_data.level = PlayerStats.level
	c_save_data.experience = PlayerStats.experience
	c_save_data.damage = PlayerStats.damage
	c_save_data.defence = PlayerStats.defence
	c_save_data.attack_speed = PlayerStats.attack_speed
	c_save_data.default_speed = PlayerStats.default_speed
	c_save_data.speed_add = PlayerStats.speed_add
	c_save_data.money = PlayerStats.money
	c_save_data.equiped_sp = PlayerStats.equiped_sp
	c_save_data.location = PlayerStats.location
	c_save_data.position = PlayerStats.position
	c_save_data.time = WorldTime.time
	for i in range(0, Inventories.Main.MaxStacks):
		var _item = Inventories.Main.at_slot(i)
		if _item != null: c_save_data.inventory[i] = [_item.item.identifier,_item.stackSize]
		if _item == null: c_save_data.inventory[i] = null
	for i in range(0, Inventories.Armor.MaxStacks):
		var _item = Inventories.Armor.at_slot(i)
		if _item != null: c_save_data.armor_inventory[i] = [_item.item.identifier,_item.stackSize]
		if _item == null: c_save_data.armor_inventory[i] = null
	save_data(current_save)
