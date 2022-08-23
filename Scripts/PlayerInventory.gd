extends Control

onready var selectedItem = $TabContainer/Inventory/VBoxContainer/Container/SelectedItem
onready var selectedArmorItem = $TabContainer/Armor/VBoxContainer/SelectedItem
onready var statsLabel = $StatsLabel
onready var slots = $TabContainer/Inventory/VBoxContainer/Container/Slots
onready var armor_slots = $TabContainer/Armor/VBoxContainer/Slots
onready var playerInventory = PlayerInventory
onready var playerArmorInventory = PlayerArmorInventory
const stats = PlayerStats

onready var item_base = preload("res://Nodes/Instances/Item.tscn")
onready var slot_unsel_tex = preload("res://Sprites/inventory/slot.png")
onready var slot_sel_tex = preload("res://Sprites/inventory/slot_selected.png")
onready var slot_empty_unsel_tex = preload("res://Sprites/inventory/slot_empty.png")
onready var slot_empty_sel_tex = preload("res://Sprites/inventory/slot_empty_selected.png")

onready var none_texture = preload("res://Textures/item_no_category.png")
onready var quest_texture = preload("res://Textures/item_quest.png")
onready var common_texture = preload("res://Textures/item_common.png")
onready var uncommon_texture = preload("res://Textures/item_uncommon.png")
onready var rare_texture = preload("res://Textures/item_rare.png")
onready var super_rare_texture = preload("res://Textures/item_super_rare.tres")
onready var epic_texture = preload("res://Textures/item_epic.png")
onready var super_epic_texture = preload("res://Textures/item_super_epic.tres")
onready var legendary_texture = preload("res://Textures/item_legendary.png")
onready var platinum_texture = preload("res://Textures/item_platinum.png")

var slot_unsel: StyleBoxTexture = null
var slot_sel: StyleBoxTexture = null
var slot_empty_unsel: StyleBoxTexture = null
var slot_empty_sel: StyleBoxTexture = null

var rng = RandomNumberGenerator.new()
var index = 0
var armor_index = 0
var hold_cooldown = 0

func _ready():
	slot_unsel = StyleBoxTexture.new()
	slot_sel = StyleBoxTexture.new()
	slot_empty_unsel = StyleBoxTexture.new()
	slot_empty_sel = StyleBoxTexture.new()
	slot_unsel.texture = slot_unsel_tex
	slot_sel.texture = slot_sel_tex
	slot_empty_unsel.texture = slot_empty_unsel_tex
	slot_empty_sel.texture = slot_empty_sel_tex
# warning-ignore:return_value_discarded
	GlobalSettings.connect("blur_effect",self,"set_blur")

func set_blur(value):
	$Blur.material.set_shader_param("amount", value * 0.15)

func _process(_delta):
	var speed_stat = stats.default_speed + stats.speed_add
	statsLabel.text = str("Level: ",stats.level,"\n",stats.base_damage+stats.weapon_damage,"(",stats.base_damage,") Damage\n",speed_stat," (", speed_stat*1.4,") Speed\n",stats.defence," Defence\n", stats.attack_speed, " Attack Speed")
	set_text()
	set_armor_text()
	set_armor_stats()
	
	if visible == true and get_parent().get_node("Console").visible == false: 
		if $TabContainer.current_tab == 0:
			if Input.is_action_just_pressed("ui_up") and index > 0:
				index -= 6
				if index < 0:
					index = 0
				$AudioStreamPlayer.play(0.0)
			if Input.is_action_just_pressed("ui_down") and index < 29:
				index += 6
				if index > 29:
					index = 29
				$AudioStreamPlayer.play(0.0)
			if Input.is_action_just_pressed("ui_left") and index > 0:
				index -= 1
				$AudioStreamPlayer.play(0.0)
			if Input.is_action_just_pressed("ui_right") and index < 29:
				index += 1
				$AudioStreamPlayer.play(0.0)
			if Input.is_action_pressed("accept"):
				hold_cooldown += 1
				if hold_cooldown == 2 or hold_cooldown > 60:
					var item = playerInventory.at_slot(index)
					if item != null:
						use_item(item)
				if hold_cooldown > 60: hold_cooldown -= 3
			if Input.is_action_just_released("accept"):
				hold_cooldown = 0
		if $TabContainer.current_tab == 1:
			if Input.is_action_just_pressed("ui_up") and armor_index > 0:
				armor_index -= 1
				$AudioStreamPlayer.play(0.0)
			if Input.is_action_just_pressed("ui_down") and armor_index < 4:
				armor_index += 1
				$AudioStreamPlayer.play(0.0)
		
		if Input.is_action_just_pressed("change_btab") and $TabContainer.current_tab > 0:
			$TabContainer.current_tab -= 1
		if Input.is_action_just_pressed("change_tab") and $TabContainer.current_tab < $TabContainer.get_tab_count() - 1:
			$TabContainer.current_tab += 1

func use_item(item):
	match item.item.attributes.type:
		"consumable":
			var heal = item.item.attributes.on_consume.heal
			var mana = item.item.attributes.on_consume.mana
			var stamina = item.item.attributes.on_consume.stamina
			stats.set_health(stats.health + heal)
			stats.mana += mana
			stats.stamina += stamina
			playerInventory.dec_in_slot(index)
		"xp_gain":
			rng.randomize()
			if item.item.attributes.on_consume.insta_level_up == true:
				stats.experience += stats.max_exp
			stats.experience += rng.randi_range(item.item.attributes.on_consume.min_xp, item.item.attributes.on_consume.max_xp)
			playerInventory.dec_in_slot(index)
		"kit":
			var kit = item.item.attributes.kit
			playerInventory.dec_in_slot(index)
			for i in kit.size():
				var values = kit.pop_front()
				give_item(values.id,values.quantity)
				kit.push_back(values)
		"melee_weapon":
			_item_check(4,index,item)
		"armor":
			var placement = item.item.attributes.placement
			match placement:
				"head":
					_item_check(0,index, item)
				"chest":
					_item_check(1,index, item)
				"legs":
					_item_check(2,index, item)
				"feet":
					_item_check(3,index, item)
		_:
			pass

func _item_check(a_index, i_index, item):
	var slot = playerArmorInventory.at_slot(a_index)
	var a_item
	playerInventory.dec_in_slot(i_index)
	if slot != null:
		a_item = slot.item.identifier
		give_item(a_item, 1)
	playerArmorInventory.dec_in_slot(a_index)
	_temps(a_index)
	playerArmorInventory.add_item_by_id(item.item.identifier,1)
	_remove_temps(a_index)

func _temps(_max):
	for i in range(0,_max):
		if playerArmorInventory.at_slot(i) == null: playerArmorInventory.add_item_by_id("temp",1)

func _remove_temps(_max):
	for i in range(0,_max):
		if playerArmorInventory.at_slot(i).item.identifier == "temp": playerArmorInventory.dec_in_slot(i)

func set_text():
	for i in range (0, playerInventory.MaxStacks):
		var test = playerInventory.at_slot(i)
		var file = File.new()
		var slot = str("Slot",i+1)
		var item_sprite = slots.get_node(slot).get_node("Texture")
		var item_stack = slots.get_node(slot).get_node("Stack")
		if test != null:
			var item_texture_path = str("res://Sprites/items/",test.item.identifier,".png")
			var item_texture_check = file.file_exists(item_texture_path)
			if item_texture_check == true: item_sprite.texture = load(item_texture_path)
			else: item_sprite.texture = load("res://Sprites/items/dummy.png")
			match_rarity(item_sprite, test.item.attributes.rarity)
			if test.stackSize > 1: item_stack.text = str(test.stackSize)
			else: item_stack.text = ""
			if i == index:
				slots.get_node(slot).set('custom_styles/panel',slot_sel)
				selectedItem.text = str(test.item.attributes.name, "\n---------------")
				var desc = str(test.item.attributes.description)
				if desc.length() > 0:
					selectedItem.text += "\n" + desc + "\n---------------"
				else:
					selectedItem.text += "\n???\n---------------"
				match test.item.attributes.type:
					"consumable":
						check_value(test.item.attributes.on_consume.heal, "\n+HP ", "int")
						check_value(test.item.attributes.on_consume.mana, "\n+MP ", "int")
						check_value(test.item.attributes.on_consume.stamina, "\n+Stamina ", "int")
					"xp_gain":
						check_value(test.item.attributes.on_consume.insta_level_up, "\n+Level Up","bool")
						check_value([test.item.attributes.on_consume.min_xp,test.item.attributes.on_consume.max_xp], ["\n+XP ", "-"], "array")
					"kit":
						selectedItem.text += str("\nItems in a bag:")
						var kit = test.item.attributes.kit
						for o in kit.size():
							var value = kit[o]
							selectedItem.text += str("\n",value.name," ",value.quantity,"x")
					_:
						selectedItem.text += "\n???"
			else:
				slots.get_node(slot).set('custom_styles/panel',slot_unsel)
		else:
			item_stack.text = ""
			item_sprite.texture = null
			if i == index:
				slots.get_node(slot).set('custom_styles/panel',slot_empty_sel)
				selectedItem.text = ""
			else:
				slots.get_node(slot).set('custom_styles/panel',slot_empty_unsel)

func set_armor_text():
	for i in range (0, playerArmorInventory.MaxStacks):
		var test = playerArmorInventory.at_slot(i)
		var file = File.new()
		var slot = str("Slot",i+1)
		var item_sprite = armor_slots.get_node(slot).get_node("Texture")
		var item_stack = armor_slots.get_node(slot).get_node("Stack")
		if test != null:
			var item_texture_path = str("res://Sprites/items/",test.item.identifier,".png")
			var item_texture_check = file.file_exists(item_texture_path)
			if item_texture_check == true:
				item_sprite.texture = load(item_texture_path)
			else:
				item_sprite.texture = load("res://Sprites/items/dummy.png")
			match_rarity(item_sprite, test.item.attributes.rarity)
			if test.stackSize > 1:
				item_stack.text = str(test.stackSize)
			else:
				item_stack.text = ""
			if i == armor_index:
				armor_slots.get_node(slot).set('custom_styles/panel',slot_sel)
				selectedArmorItem.text = str(test.item.attributes.name, "\n---------------")
				var desc = str(test.item.attributes.description)
				if desc.length() > 0:
					selectedArmorItem.text += "\n" + desc + "\n---------------"
				else:
					selectedArmorItem.text += "\n???\n---------------"
				match test.item.attributes.type:
					_:
						selectedArmorItem.text += "\n???"
			else:
				armor_slots.get_node(slot).set('custom_styles/panel',slot_unsel)
		else:
			item_stack.text = ""
			item_sprite.texture = null
			if i == armor_index:
				armor_slots.get_node(slot).set('custom_styles/panel',slot_empty_sel)
				selectedArmorItem.text = ""
			else:
				armor_slots.get_node(slot).set('custom_styles/panel',slot_empty_unsel)

func set_armor_stats():
	var _armor = [0,0,0,0,0]
	for i in range (0, playerArmorInventory.MaxStacks):
		var test = playerArmorInventory.at_slot(i)
		if test != null:
			if test.item.identifier != "temp":
				if i != 4: _armor[i] = test.item.attributes.defence
				if i == 4: _armor[4] = test.item.attributes.meleeDamage.max
	PlayerStats.armor_defence = _armor[0] + _armor[1] + _armor[2] + _armor[3]
	PlayerStats.weapon_damage = _armor[4]

func match_rarity(sprite, rarity):
	match rarity:
		"NONE":
			sprite.material.set_shader_param("outlineTexture", none_texture)
		"QUEST": 
			sprite.material.set_shader_param("outlineTexture", quest_texture)
		"COMMON": 
			sprite.material.set_shader_param("outlineTexture", common_texture)
		"UNCOMMON": 
			sprite.material.set_shader_param("outlineTexture", uncommon_texture)
		"RARE": 
			sprite.material.set_shader_param("outlineTexture", rare_texture)
		"SUPER_RARE":
			sprite.material.set_shader_param("outlineTexture", super_rare_texture)
		"EPIC":
			sprite.material.set_shader_param("outlineTexture", epic_texture)
		"SUPER_EPIC":
			sprite.material.set_shader_param("outlineTexture", super_epic_texture)
		"LEGENDARY":
			sprite.material.set_shader_param("outlineTexture", legendary_texture)
		"PLATINUM":
			sprite.material.set_shader_param("outlineTexture", platinum_texture)

func give_item(id, quantity):
# warning-ignore:unused_variable
	var input_quantity = int(quantity)
	var start = 0
	quantity = int(quantity)
	var item_def = GDInv_ItemDB.get_item_by_id(id)
	var item_maxStack = item_def.attributes.maxStackSize
	while (quantity > 0):
		if start > 29:
			spawn_item(id, quantity)
			break
		var slot = PlayerInventory.find_item(item_def, start)
		if slot == -1:
			for i in playerInventory.MaxStacks:
				if playerInventory.at_slot(i) == null: break
				if i >= 29 and playerInventory.at_slot(i) != null:
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

func check_value(temp, text, mode):
	match mode:
		"int":
			if temp > 0: selectedItem.text += str(text, temp)
		"bool":
			if temp == true: selectedItem.text += str(text)
		"array":
			var size = temp.size()
			for n in size:
				if temp[n] > 0: selectedItem.text += str(text[n], temp[n])

func spawn_item(id, quantity):
	var item_instance = item_base.instance()
	item_instance.id = id
	item_instance.quantity = quantity
	MainScene.main.get_node("YSort/Items").add_child(item_instance)
	item_instance.position.x = MainScene.main.get_node("YSort/Player").position.x + rng.randi_range(-16, 16)
	item_instance.position.y = MainScene.main.get_node("YSort/Player").position.y + rng.randi_range(-16, 16)
