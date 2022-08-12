extends Node

enum {
	ARG_INT,
	ARG_STRING,
	ARG_BOOL,
	ARG_FLOAT
}

const valid_cmd = [
	["", [], "[]"],
	["help", [], "[]"],
	["set_stat", [ARG_STRING, ARG_FLOAT], "[stat_name, value]"],
	["heal", [], "[]"],
	["goto", [ARG_STRING], "[level_name]"],
	["tp", [ARG_FLOAT, ARG_FLOAT], "[pos_x, pos_y]"],
	["toggle_camera_limit", [], "[]"],
	["give_item", [ARG_STRING, ARG_INT], "[item_name, count]"],
	["clear_inventory", [], "[]"],
	["spawn_item", [ARG_STRING, ARG_INT], "[item_name, count]"],
	["get_item_list", [ARG_STRING], "[search] [^all] [^simple]"],
	["shake_screen",[ARG_FLOAT, ARG_INT, ARG_INT, ARG_INT], "[duration, frequency, amplitude, priority]"],
	["spawn_projectile",[ARG_FLOAT, ARG_FLOAT, ARG_FLOAT, ARG_INT, ARG_INT, ARG_INT], "[pos_x, pos_y, time_stamp, health, damage, speed]"],
	["set_dummy_frames",[ARG_FLOAT], "[time]"],
	["set_rune",[ARG_INT], "[id]"],
	["challenge", [ARG_STRING], "[challenge]"],
]

onready var item_base = preload("res://Nodes/Instances/Item.tscn")

func _ready():
	valid_cmd[0].sort()

func commands():
	var temp:String = "\n"
	for i in valid_cmd.size():
		temp += str(valid_cmd[i][0]," ",valid_cmd[i][2],"\n")
	return temp

func set_stat(stat, value):
	value = float(value)
	match stat:
		"speed","spd":
			PlayerStats.default_speed = value
			return str("Speed changed to ", value,".")
		"max_hp","maxhp","max_health","maxhealth":
			PlayerStats.max_health = value
			PlayerStats.health = PlayerStats.max_health
			return str("Max health changed to ", value,".")
		"max_mp","maxmp","max_mana","maxmana":
			PlayerStats.max_mana = value
			PlayerStats.mana = PlayerStats.max_mana
			return str("Max mana changed to ", value,".")
		"max_stamina","maxstamina":
			PlayerStats.max_stamina = value
			PlayerStats.stamina = PlayerStats.max_stamina
			return str("Max stamina changed to ", value,".")
		"max_sp","maxsp":
			PlayerStats.max_sp = value
			PlayerStats.sp = PlayerStats.max_sp
			return str("Max Special Power changed to ", value,".")
		"hp","health":
			PlayerStats.health = value
			return str("Health changed to ", value,".")
		"mp","mana":
			PlayerStats.mana = value
			return str("Mana changed to ", value,".")
		"stamina":
			PlayerStats.stamina = value
			return str("Stamina changed to ", value,".")
		"sp":
			PlayerStats.sp = value
			return str("Special Power changed to ", value,".")
		"def","defence":
			PlayerStats.defence = value
			return str("Defence changed to ", value,".")
		"dmg","damage":
			PlayerStats.damage = value
			return str("Damage changed to ", value,".")
		"attack_speed","attackspeed","attspd":
			PlayerStats.attack_speed = value
			return str("Attack speed changed to ", value,".")
		"exp","experience":
			PlayerStats.experience = value
			return str("Level experience changed to ", value,".")
		"temphp","temp_hp","temphealth","temp_health":
			PlayerStats.temp_health = value
			return str("Temporary health changed to ", value,".")
		"maxtemphp","max_temp_hp","maxtemphealth","max_temp_health","tempmaxhealth","temp_max_health":
			PlayerStats.temp_health = value
			return str("Max temporary health changed to ", value,".")
		_:
			return str("Stat \"",stat, "\"doesn't exist.")

func heal():
	PlayerStats.health = PlayerStats.max_health
	PlayerStats.mana = PlayerStats.max_mana
	PlayerStats.stamina = PlayerStats.max_stamina
	return str("Player has been healed.")

func goto(place):
	var file = File.new()
	var level_path = str("res://Maps/",place,".tscn")
	var level_path_check = file.file_exists(level_path)
	if level_path_check == true:
		var Teleport = load("res://Nodes/Instances/Teleport.tscn")
		var teleport = Teleport.instance()
		teleport.mute_music = true
		teleport.destination = level_path
		teleport.position = Vector2(MainScene.main.get_node("YSort/Player").position.x,MainScene.main.get_node("YSort/Player").position.y)
		MainScene.main.get_node("YSort").add_child(teleport)
		return str("Teleporting to map \"", place, "\" initiated. Press ESC to proceed.")
	else:
		return str("Map \"", place, "\"doesn't exist.")

func tp(x, y):
	x = float(x)
	y = float(y)
	MainScene.main.get_node("YSort/Player").position.x = x
	MainScene.main.get_node("YSort/Player").position.y = y
	return str("Teleport to ", x, ", " , y)

func toggle_camera_limit():
	PlayerStats.camera_limit = not PlayerStats.camera_limit
	return str("Camera limit is set to ", PlayerStats.camera_limit)

func give_item(id, quantity):
	var input_quantity = int(quantity)
	var start = 0
	if GDInv_ItemDB.get_item_by_id(id) == null:
		return str("There's no item called \"", id, "\"")
	quantity = int(quantity)
	var item_def = GDInv_ItemDB.get_item_by_id(id)
	var item_maxStack = item_def.attributes.maxStackSize
	while (quantity > 0):
		if start > 29: 
			spawn_item(id, quantity)
			return str("Added ", input_quantity - quantity , " of ", id, ", dropped ", quantity)
		var slot = PlayerInventory.find_item(item_def, start)
		if slot == -1:
			for i in PlayerInventory.MaxStacks:
				if PlayerInventory.at_slot(i) == null: break
				if i >= 29 and PlayerInventory.at_slot(i) != null:
					spawn_item(id, quantity)
			if quantity >= item_maxStack:
# warning-ignore:return_value_discarded
				PlayerInventory.add_item(item_def, item_maxStack)
				quantity -= item_maxStack
			elif quantity < item_maxStack and quantity > 0:
# warning-ignore:return_value_discarded
				PlayerInventory.add_item(item_def, quantity)
				quantity -= quantity
			start += 1
		if slot != -1:
			var stackSize = PlayerInventory.at_slot(start).stackSize
			if stackSize >= item_maxStack: 
				start += 1
			else:
				var result = clamp(quantity - stackSize, 1, item_maxStack)
# warning-ignore:return_value_discarded
				PlayerInventory.add_item(item_def, result)
				quantity -= result
				start += 1
		
	return str("Added ", input_quantity , " of ", id)

func clear_inventory():
	PlayerInventory.clear()
	return "Player's inventory has been cleared"

func spawn_item(id, quantity):
	var item_instance = item_base.instance()
	var item_def = GDInv_ItemDB.get_item_by_id(id)
	if item_def == null: return str('Item of an id "',id,'" doesn\'t exist')
	item_instance.id = id
	item_instance.quantity = int(quantity)
	MainScene.main.get_node("YSort/Items").add_child(item_instance)
	item_instance.position.x = MainScene.main.get_node("YSort/Player").position.x
	item_instance.position.y = MainScene.main.get_node("YSort/Player").position.y

func get_item_list(search):
	var registry = GDInv_ItemDB.REGISTRY
	var keys = registry.keys()
	var values = registry.values()
	var text: String = ""
	if search.begins_with("^") == true:
		var property = search.substr(1)
		match property:
			"all":
				for i in registry.size():
					text += str(keys[i], values[i].attributes, "\n")
			"simple", _:
				for i in registry.size():
					text += str(keys[i], ",")
					if i % 8 == 0 and i != 0:
						text += "\n"
	else:
		text += str("Result for \"",search,"\"\n")
		for i in registry.size():
			if search in values[i].attributes:
				text += str(keys[i],": ", values[i].attributes.get(search), "\n")
	return str(text)

func shake_screen(duration = 0.2, frequency = 15, amplitude = 16, priority = 0):
	MainScene.main.get_node("Camera2D/ScreenShake").start(float(duration), int(frequency), int(amplitude), int(priority))
	return str("Shaking screen (",priority,") with frequency - ",frequency,", amplitude - ",amplitude, "for ",duration,"s")

func spawn_projectile(pos_x, pos_y, time_stamp, health, damage, speed):
	var Projectile = load("res://Nodes/Instances/Enemies/DummyProjectile.tscn")
	var projectile = Projectile.instance()
	projectile.get_node("Stats").life_stamp = float(time_stamp)
	projectile.get_node("Stats").max_health = int(health)
	projectile.get_node("HitBox").damage = int(damage)
	projectile.DEFAULT_SPEED = float(speed)
	var player = MainScene.main.get_node("YSort/Player")
	pos_x = float(pos_x)
	pos_y = float(pos_y)
	projectile.position = Vector2(pos_x, pos_y) + player.global_position
	MainScene.main.get_node("YSort/Enemies").add_child(projectile)
	return str("Spawned projectile at (", pos_x, ",", pos_y, ").")

func set_dummy_frames(time):
	PlayerStats.dummy_frames = time
	return str("Invurnability frames of a dummy changed to ",PlayerStats.dummy_frames, "s")

func set_rune(id):
	id = int(id)
	PlayerStats.sp_on = false
	var size = PlayerStats.special_powers.size() - 1
	if id > size: id = size
	if id < 0: id = 0
	PlayerStats.equiped_sp = id
	return str("Equiped: ", PlayerStats.special_powers[id][0])

# [hp, mp, stamina, sp, max_temp] 
var saved_stats = [0,0,0,0,0]

func challenge(challenge):
	if challenge == "none" and PlayerStats.challenge == "none": return str("You don't have any challenge turned on right now.")
	if challenge != "none" and PlayerStats.challenge != "none": return str("You have to disable challenge first. Type \"challenge none\" to disable challenge.")
	match challenge:
		"none":
			PlayerStats.challenge = challenge
			PlayerStats.max_health = saved_stats[0]
			PlayerStats.health = saved_stats[0]
			PlayerStats.max_mana = saved_stats[1]
			PlayerStats.mana = saved_stats[1]
			PlayerStats.max_stamina = saved_stats[2]
			PlayerStats.stamina = saved_stats[2]
			PlayerStats.max_sp = saved_stats[3]
			PlayerStats.sp = saved_stats[3]
			PlayerStats.max_temp_health = saved_stats[4]
			PlayerStats.temp_health = saved_stats[4]
			return str("Challenge disabled.")
		"1_hp":
			saved_stats = [PlayerStats.max_health,PlayerStats.max_mana,PlayerStats.max_stamina,PlayerStats.max_sp,PlayerStats.max_temp_health]
			PlayerStats.challenge = challenge
			return str("Challenge 1 HP started.")
		_:
			return str("Challenge \"",challenge,"\" doesn't exist.")
