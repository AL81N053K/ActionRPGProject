extends Node2D

onready var _transition_rect := $CanvasLayer/SceneTransitionRect
onready var _debug = preload("res://src/prefabs/UIs/Console/debug_interface.tscn")

func _ready():
	get_tree().paused = false
	$CanvasLayer/VBoxContainer/SaveAndContinue.grab_focus()
	PlayerStats.sp_on = false
	Music.SetGameState("Loading")
	WorldTime.reset()

func _on_SaveAndContinue_pressed():
	SaveGame._save()
	_transition_rect.transition()
	yield(_transition_rect,"animation_finished")
	SceneChanger.goto_scene(str("res://src/maps/",SaveGame.c_save_data.location,".tscn"), self)

func _on_SaveAndQuit_pressed():
	SaveGame._save()
	_transition_rect.transition()
	yield(_transition_rect,"animation_finished")
	SceneChanger.goto_scene(SceneChanger.MainMenu, self)

func _on_JustQuit_pressed():
	_transition_rect.transition()
	yield(_transition_rect,"animation_finished")
	SceneChanger.goto_scene(SceneChanger.MainMenu, self)

