extends Node

onready var Armor = $Armor
onready var Main = $Main

func _ready() -> void:
	pass

func clear_all():
	Armor.clear()
	Main.clear()
