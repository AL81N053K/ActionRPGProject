extends Node2D

export var level_name = ""

func _ready():
	MainScene.setName(name)
	PlayerStats.location = level_name

func _input(_event):
	if Input.is_action_just_pressed("debug_show_dialog"):
		var dialog = Dialogic.start("Test")
		self.add_child(dialog)
