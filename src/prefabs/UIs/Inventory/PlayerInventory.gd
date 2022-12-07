extends Control

onready var selectedItem = $SelectedItem
onready var statsLabel = $StatsLabel
onready var slots = $Tabs/Items/V/Container/Slots
onready var armor_slots = $Tabs/Armor/V/Slots
onready var mainInv = Inventories.Main
onready var armorInv = Inventories.Armor
const stats = PlayerStats

onready var item_base = preload("res://src/prefabs/UIs/Inventory/Item.tscn")
onready var itemp_slot_prefab = preload("res://src/prefabs/UIs/Inventory/ItemSlot.tscn")

onready var none_texture = preload("res://assets/textures/item_no_category.png")
onready var quest_texture = preload("res://assets/textures/item_quest.png")
onready var common_texture = preload("res://assets/textures/item_common.png")
onready var uncommon_texture = preload("res://assets/textures/item_uncommon.png")
onready var rare_texture = preload("res://assets/textures/item_rare.png")
onready var super_rare_texture = preload("res://assets/textures/item_super_rare.tres")
onready var epic_texture = preload("res://assets/textures/item_epic.png")
onready var super_epic_texture = preload("res://assets/textures/item_super_epic.tres")
onready var legendary_texture = preload("res://assets/textures/item_legendary.png")
onready var platinum_texture = preload("res://assets/textures/item_platinum.png")

onready var file = File.new()

var rng = RandomNumberGenerator.new()
var index = 0
var armor_index = 0
var hold_cooldown = 0

func _ready():
	if EventBus.connect("blur_effect",self,"set_blur") == OK: pass
	creats_slots()

func set_blur(value):
	$Blur.material.set_shader_param("amount", value * 0.15)

func creats_slots():
	for s in range(0, mainInv.MaxStacks):
		var slot = itemp_slot_prefab.instance()
		slot.name = "Slot%s" % s
		slots.add_child(slot)

func _process(_delta):
	var speed_stat = stats.default_speed + stats.speed_add
	statsLabel.text = str("Level: ",stats.level,"\n",stats.damage,"(",stats.base_damage,") Damage\n",speed_stat," (", speed_stat*1.4,") Speed\n",stats.defence,"(",stats.base_defence,")"," Defence\n", stats.attack_speed, " Attack Speed")
	if slots.get_child_count() > 0: set_slots()
	set_armor_slots()
	set_armor_stats()
	show_item()
	
	if visible and not get_parent().get_node("Console").visible and $Tabs.current_tab == 0:
		if Input.is_action_pressed("accept"):
				hold_cooldown += 1
				if hold_cooldown == 2 or hold_cooldown > 60:
					var item = mainInv.at_slot(index)
					if item != null:
						use_item(item)
				if hold_cooldown > 60: hold_cooldown -= 3
		if Input.is_action_just_released("accept"):
			hold_cooldown = 0

func _input(event: InputEvent) -> void:
	if visible and not get_parent().get_node("Console").visible: 
		if $Tabs.current_tab == 0:
			if event.is_action_pressed("ui_up") and index > 0:
				index -= 6
				if index < 0:
					index = 0
				$AudioStreamPlayer.play(0.0)
			if event.is_action_pressed("ui_down") and index < 29:
				index += 6
				if index > 29:
					index = 29
				$AudioStreamPlayer.play(0.0)
			if event.is_action_pressed("ui_left") and index > 0:
				index -= 1
				$AudioStreamPlayer.play(0.0)
			if event.is_action_pressed("ui_right") and index < 29:
				index += 1
				$AudioStreamPlayer.play(0.0)
		if $Tabs.current_tab == 1:
			if event.is_action_pressed("ui_up") and armor_index > 0:
				armor_index -= 1
				$AudioStreamPlayer.play(0.0)
			if event.is_action_pressed("ui_down") and armor_index < 4:
				armor_index += 1
				$AudioStreamPlayer.play(0.0)
			if event.is_action_pressed("accept"):
				var item = armorInv.at_slot(armor_index)
				if item != null:
					take_off_item(item)
		
		print($Tabs.current_tab)
		
		if event.is_action_pressed("change_btab") and $Tabs.current_tab > 0:
			$Tabs.current_tab -= 1
		if event.is_action_pressed("change_tab") and $Tabs.current_tab < $Tabs.get_tab_count() - 1:
			$Tabs.current_tab += 1

func use_item(item):
	var attributes = item.item.attributes
	match attributes.type:
		"consumable":
			if attributes.on_consume.heal > 0: stats.heal(attributes.on_consume.heal)
			if attributes.on_consume.mana > 0: stats.set_mana(stats.mana + attributes.on_consume.mana)
			if attributes.on_consume.stamina > 0: stats.set_stamina(stats.stamina + attributes.on_consume.stamina)
			if attributes.on_consume.temp_heal > 0: stats.set_temp_health(stats.temp_health + attributes.on_consume.temp_heal)
			mainInv.dec_in_slot(index)
		"xp_gain":
			rng.randomize()
			if attributes.on_consume.insta_level_up == true:
				stats.experience += stats.max_exp
			stats.experience += rng.randi_range(attributes.on_consume.min_xp, attributes.on_consume.max_xp)
			mainInv.dec_in_slot(index)
		"kit":
			var kit = attributes.kit
			mainInv.dec_in_slot(index)
			for i in kit.size():
				var values = kit.pop_front()
				give_item(values.id,values.quantity)
				kit.push_back(values)
		"melee_weapon":
			_item_check(4,index,item)
		"armor":
			var placement = attributes.placement
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

func take_off_item(item):
	armorInv.dec_in_slot(armor_index)
	give_item(item.item.identifier,1)

func _item_check(a_index, i_index, item):
	var slot = armorInv.at_slot(a_index)
	var a_item
	mainInv.dec_in_slot(i_index)
	if slot != null:
		a_item = slot.item.identifier
		give_item(a_item, 1)
	armorInv.dec_in_slot(a_index)
	_temps(a_index)
	armorInv.add_item_by_id(item.item.identifier,1)
	_remove_temps(a_index)

func _temps(_max):
	for i in range(0,_max):
		if armorInv.at_slot(i) == null: armorInv.add_item_by_id("temp",1)

func _remove_temps(_max):
	for i in range(0,_max):
		if armorInv.at_slot(i).item.identifier == "temp": armorInv.dec_in_slot(i)

func show_item():
	var item
	match $Tabs.current_tab:
		0:
			item = mainInv.at_slot(index)
			if not selectedItem.visible: selectedItem.show()
		1:
			item = armorInv.at_slot(armor_index)
			if not selectedItem.visible: selectedItem.show()
		_:
			item = null
			if selectedItem.visible: selectedItem.hide()
	if item != null:
		var attributes = item.item.attributes
		selectedItem.text = str(attributes.name, "\n---------------")
		var desc = str(attributes.description)
		if desc.length() > 0: selectedItem.text += "\n" + desc + "\n---------------"
		else: selectedItem.text += "\n???\n---------------"
		match attributes.type:
			"consumable":
				check_value(attributes.on_consume.heal, "\n+HP ", "int")
				check_value(attributes.on_consume.mana, "\n+MP ", "int")
				check_value(attributes.on_consume.stamina, "\n+Stamina ", "int")
				check_value(attributes.on_consume.temp_heal, "\n+Temporary HP ", "int")
			"xp_gain":
				check_value(attributes.on_consume.insta_level_up, "\n+Level Up","bool")
				check_value([attributes.on_consume.min_xp,attributes.on_consume.max_xp], ["\n+XP ", "-"], "array")
			"kit":
				selectedItem.text += str("\nmainInv in a bag:")
				var kit = attributes.kit
				for o in kit.size():
					var value = kit[o]
					selectedItem.text += str("\n",value.name," ",value.quantity,"x")
			_:
				selectedItem.text += "\n???"
	else: selectedItem.text = ""

func set_slots():
	for i in range (0, mainInv.MaxStacks):
		var test = mainInv.at_slot(i)
		var slot = str("Slot",i)
		var item_sprite = slots.get_node(slot).get_node("Texture")
		var item_stack = slots.get_node(slot).get_node("Stack")
		if test != null:
			var attributes = test.item.attributes
			item_sprite.texture = load(find_texture(test.item.identifier))
			match_rarity(item_sprite, attributes.rarity)
			
			if test.stackSize > 1: item_stack.text = str(test.stackSize)
			else: item_stack.text = ""
			
			if i == index:
				slots.get_node(slot)._set_texture("slot_sel")
			else:
				slots.get_node(slot)._set_texture("slot_unsel")
		else:
			item_stack.text = ""
			item_sprite.texture = null
			if i == index:
				slots.get_node(slot)._set_texture("slot_empty_sel")
			else:
				slots.get_node(slot)._set_texture("slot_empty_unsel")

func set_armor_slots():
	for i in range (0, armorInv.MaxStacks):
		var test = armorInv.at_slot(i)
		var slot = str("Slot",i+1)
		var item_sprite = armor_slots.get_node(slot).get_node("Texture")
		var item_stack = armor_slots.get_node(slot).get_node("Stack")
		if test != null:
			var attributes = test.item.attributes
			item_sprite.texture = load(find_texture(test.item.identifier))
			match_rarity(item_sprite, attributes.rarity)
			
			if test.stackSize > 1: item_stack.text = str(test.stackSize)
			else: item_stack.text = ""
			
			if i == armor_index:
				armor_slots.get_node(slot)._set_texture("slot_sel")
			else:
				armor_slots.get_node(slot)._set_texture("slot_unsel")
		else:
			item_stack.text = ""
			item_sprite.texture = null
			if i == armor_index:
				armor_slots.get_node(slot)._set_texture("slot_empty_sel")
			else:
				armor_slots.get_node(slot)._set_texture("slot_empty_unsel")

func set_armor_stats():
	var _armor = [0,0,0,0,0]
	for i in range (0, armorInv.MaxStacks):
		var test = armorInv.at_slot(i)
		if test != null:
			if test.item.identifier != "temp":
				if i != 4: _armor[i] = test.item.attributes.defence
				if i == 4: _armor[4] = test.item.attributes.meleeDamage.max
	PlayerStats.armor_defence = _armor[0] + _armor[1] + _armor[2] + _armor[3]
	PlayerStats.weapon_damage = _armor[4]

func match_rarity(sprite, rarity):
	var value = self.get(str(rarity.to_lower(),"_texture"))
	sprite.material.set_shader_param("outlineTexture", value)

func find_texture(texture_name):
	var path = str("res://assets/sprites/items/",texture_name,".png")
	if file.file_exists(path) == true: return path
	else: return "res://assets/sprites/items/dummy.png"

func give_item(id, quantity:int):
	var start = 0
	var item_def = GDInv_ItemDB.get_item_by_id(id)
	var item_maxStack = item_def.attributes.maxStackSize
	while (quantity > 0):
		if start > 29:
			spawn_item(id, quantity)
			break
		var slot = mainInv.find_item(item_def, start)
		if slot == -1:
			for i in mainInv.MaxStacks:
				if mainInv.at_slot(i) == null: break
				if i >= 29 and mainInv.at_slot(i) != null:
					spawn_item(id, quantity)
			if quantity >= item_maxStack:
				mainInv.add_item(item_def, item_maxStack)
				quantity -= item_maxStack
			elif quantity < item_maxStack and quantity > 0:
				mainInv.add_item(item_def, quantity)
				quantity -= quantity
			start += 1
		if slot != -1:
			var stackSize = mainInv.at_slot(start).stackSize
			if stackSize >= item_maxStack: 
				start += 1
			else:
				var result = clamp(quantity - stackSize, 1, item_maxStack)
				mainInv.add_item(item_def, result)
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
	MainScene.main.get_node("YSort/mainInv").add_child(item_instance)
	item_instance.position.x = MainScene.main.get_node("YSort/Player").position.x + rng.randi_range(-16, 16)
	item_instance.position.y = MainScene.main.get_node("YSort/Player").position.y + rng.randi_range(-16, 16)
