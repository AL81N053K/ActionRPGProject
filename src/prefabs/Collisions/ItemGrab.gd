extends RigidBody2D

onready var sprite = $Sprite
onready var particles = $CPUParticles2D
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

onready var audio = preload("res://src/prefabs/Player/PlayerPickUp.tscn")

onready var visibilityNotifier = $VisibilityNotifier2D

enum rarity {
	NONE, QUEST, COMMON, UNCOMMON, RARE, SUPER_RARE, EPIC, SUPER_EPIC, LEGENDARY, PLATINUM
}

export(String, "NONE", "QUEST", "COMMON", "UNCOMMON", "RARE", "SUPER_RARE", "EPIC", "SUPER_EPIC", "LEGENDARY", "PLATINUM") var type
export var id = "garlic"
export var quantity = 1
export(bool) var special = false
var pickable = false

const glow = Color(1.25,1.25,1.25)

func _ready():
	hide()
	visibilityNotifier.connect("screen_entered",self,"show")
	visibilityNotifier.connect("screen_exited",self,"hide")
	
	var file = File.new()
	var item_def = GDInv_ItemDB.get_item_by_id(id)
	if item_def != null:
		var item_texture_path = str("res://assets/sprites/items/",item_def.identifier,".png")
		var item_texture_check = file.file_exists(item_texture_path)
		if item_texture_check == true:
			$Sprite.texture = load(item_texture_path)
		else:
			$Sprite.texture = load("res://assets/sprites/items/dummy.png")
		if item_def == null: 
			type = "NONE"
		else:
			if special == false:
				type = item_def.attributes.rarity
		match_rarity(type)
	else:
		queue_free()
	

func match_rarity(rarity):
	var value = self.get(str(rarity.to_lower(),"_texture"))
	sprite.material.set_shader_param("outlineTexture", value)
	match rarity:
		"NONE":
			particles.color = Color(1,1,1)
			$Light2D.color = Color(1,1,1)
			particles.modulate = glow * 0
		"QUEST":
			particles.color = Color(1,0.15,0.15)
			$Light2D.color = Color(1,0.15,0.15)
			particles.modulate = glow
		"COMMON":
			particles.color = Color(1,1,1)
			$Light2D.color = Color(1,1,1)
			particles.modulate = glow
		"UNCOMMON":
			particles.color = Color(0.2,1,0.2)
			$Light2D.color = Color(0.2,1,0.2)
			particles.modulate = glow
		"RARE":
			particles.color = Color(0,1,1)
			$Light2D.color = Color(0,1,1)
			particles.modulate = glow
		"SUPER_RARE":
			particles.color = Color(0.1,1,.75)
			$Light2D.color = Color(0.1,1,.75)
			particles.modulate = glow * 1.15
		"EPIC":
			particles.color = Color(1,.1,.85)
			$Light2D.color = Color(1,.1,.85)
			particles.modulate = glow
		"SUPER_EPIC":
			particles.color = Color(1,.3,.7)
			$Light2D.color = Color(1,.3,.7)
			particles.modulate = glow * 1.15
		"LEGENDARY":
			particles.color = Color(0.9,0.75,0.05)
			$Light2D.color = Color(0.9,0.75,0.05)
			particles.modulate = glow * 1.15
		"PLATINUM":
			particles.color = Color(0.6,0.8,1.0)
			$Light2D.color = Color(0.6,0.8,1.0)
			particles.modulate = glow * 1.15

func _on_HitBox_area_entered(_area):
	if pickable == true:
		var start = 0
		if GDInv_ItemDB.get_item_by_id(id) == null: return
		var item_def = GDInv_ItemDB.get_item_by_id(id)
		var item_maxStack = item_def.attributes.maxStackSize
		while (quantity > 0):
			var find_item = Inventories.Main.find_item(item_def, start)
			if start > 29: return
			if find_item == -1:
				if quantity > item_maxStack:
					Inventories.Main.add_item(item_def, item_maxStack)
					quantity -= item_maxStack
				if quantity <= item_maxStack:
					Inventories.Main.add_item(item_def, quantity)
					quantity -= quantity
			if find_item != -1:
				var stackSize = Inventories.Main.at_slot(find_item).stackSize
				if stackSize >= item_maxStack: 
					start += 1
				else:
					var result = clamp(quantity - stackSize, 1, item_maxStack)
					Inventories.Main.add_item(item_def, result)
					quantity -= result
					start += 1
		var pickup = audio.instance()
		MainScene.main.add_child(pickup)
		queue_free()

func _on_PickUpDelay_timeout():
	pickable = true
	$CPUParticles2D.emitting = true
