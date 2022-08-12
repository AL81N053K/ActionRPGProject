extends KinematicBody2D

onready var sprite = $Sprite
onready var particles = $CPUParticles2D
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

onready var audio = preload("res://Nodes/Instances/PlayerPickUp.tscn")

onready var visibilityNotifier = $VisibilityNotifier2D

export(String, "NONE", "QUEST", "COMMON", "UNCOMMON", "RARE", "SUPER_RARE", "EPIC", "SUPER_EPIC", "LEGENDARY", "PLATINUM") var type
export var id = "garlic"
export var quantity = 1
export(bool) var special = false
var pickable = false

const glow = Color(2.25,2.25,2.25)

func _ready():
	hide()
	visibilityNotifier.connect("screen_entered",self,"show")
	visibilityNotifier.connect("screen_exited",self,"hide")
	
	var file = File.new()
	var item_def = GDInv_ItemDB.get_item_by_id(id)
	if item_def != null:
		var item_texture_path = str("res://Sprites/items/",item_def.identifier,".png")
		var item_texture_check = file.file_exists(item_texture_path)
		if item_texture_check == true:
			$Sprite.texture = load(item_texture_path)
		else:
			$Sprite.texture = load("res://Sprites/items/dummy.png")
		if item_def == null: 
			type = "NONE"
		else:
			if special == false:
				type = item_def.attributes.rarity
		match_rarity(type)
	else:
		queue_free()
	

func match_rarity(rarity):
	match rarity:
		"NONE":
			sprite.material.set_shader_param("outlineTexture", none_texture)
			particles.color = Color(1,1,1)
			particles.modulate = glow * 0
		"QUEST": 
			sprite.material.set_shader_param("outlineTexture", quest_texture)
			particles.color = Color(1,0.15,0.15)
			particles.modulate = glow
		"COMMON": 
			sprite.material.set_shader_param("outlineTexture", common_texture)
			particles.color = Color(1,1,1)
			particles.modulate = glow
		"UNCOMMON": 
			sprite.material.set_shader_param("outlineTexture", uncommon_texture)
			particles.color = Color(0.2,1,0.2)
			particles.modulate = glow
		"RARE": 
			sprite.material.set_shader_param("outlineTexture", rare_texture)
			particles.color = Color(0,1,1)
			particles.modulate = glow
		"SUPER_RARE":
			sprite.material.set_shader_param("outlineTexture", super_rare_texture)
			particles.color = Color(0.1,1,.75)
			particles.modulate = glow * 1.15
		"EPIC":
			sprite.material.set_shader_param("outlineTexture", epic_texture)
			particles.color = Color(1,.1,.85)
			particles.modulate = glow
		"SUPER_EPIC":
			sprite.material.set_shader_param("outlineTexture", super_epic_texture)
			particles.color = Color(1,.3,.7)
			particles.modulate = glow * 1.15
		"LEGENDARY":
			sprite.material.set_shader_param("outlineTexture", legendary_texture)
			particles.color = Color(0.9,0.75,0.05)
			particles.modulate = glow * 1.15
		"PLATINUM":
			sprite.material.set_shader_param("outlineTexture", platinum_texture)
			particles.color = Color(0.6,0.8,1.0)
			particles.modulate = glow * 1.15

func _on_HitBox_area_entered(_area):
	if pickable == true:
		var start = 0
		if GDInv_ItemDB.get_item_by_id(id) == null: return
		var item_def = GDInv_ItemDB.get_item_by_id(id)
		var item_maxStack = item_def.attributes.maxStackSize
		while (quantity > 0):
			var find_item = PlayerInventory.find_item(item_def, start)
			if start > 29: return
			if find_item == -1:
				if quantity > item_maxStack:
	# warning-ignore:return_value_discarded
					PlayerInventory.add_item(item_def, item_maxStack)
					quantity -= item_maxStack
				if quantity <= item_maxStack:
	# warning-ignore:return_value_discarded
					PlayerInventory.add_item(item_def, quantity)
					quantity -= quantity
			if find_item != -1:
				var stackSize = PlayerInventory.at_slot(find_item).stackSize
				if stackSize >= item_maxStack: 
					start += 1
				else:
					var result = clamp(quantity - stackSize, 1, item_maxStack)
	# warning-ignore:return_value_discarded
					PlayerInventory.add_item(item_def, result)
					quantity -= result
					start += 1
		var pickup = audio.instance()
		MainScene.main.add_child(pickup)
		queue_free()

func _on_PickUpDelay_timeout():
	pickable = true
	$CPUParticles2D.emitting = true
