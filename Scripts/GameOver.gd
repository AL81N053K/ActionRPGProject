extends Node2D

onready var _transition_rect := $CanvasLayer/SceneTransitionRect

func _ready():
	get_tree().paused = false
	$CanvasLayer/VBoxContainer/SaveAndContinue.grab_focus()
# warning-ignore:return_value_discarded
	load("res://Preload/debug_interface.tscn")
	PlayerStats.sp_on = false
	Music.SetGameState("Loading")
	PlayerStats.already_signaled = false

func _on_SaveAndContinue_pressed():
	_save()
	_transition_rect.transition()
	yield(_transition_rect,"animation_finished")
	SceneChanger.goto_scene(str("res://Maps/",SaveGame.current_save_data.location,".tscn"), self)

func _on_SaveAndQuit_pressed():
	_save()
	_transition_rect.transition()
	yield(_transition_rect,"animation_finished")
	SceneChanger.goto_scene("res://Maps/MainMenu.tscn", self)

func _on_JustQuit_pressed():
	_transition_rect.transition()
	yield(_transition_rect,"animation_finished")
	SceneChanger.goto_scene("res://Maps/MainMenu.tscn", self)

func _save():
	SaveGame.current_save_data.max_health = PlayerStats.max_health
	SaveGame.current_save_data.max_mana = PlayerStats.max_mana
	SaveGame.current_save_data.max_stamina = PlayerStats.max_stamina
	SaveGame.current_save_data.max_temp_health = PlayerStats.max_temp_health
	SaveGame.current_save_data.max_sp = PlayerStats.max_sp
	SaveGame.current_save_data.sp = PlayerStats.sp
	SaveGame.current_save_data.level = PlayerStats.level
	SaveGame.current_save_data.experience = PlayerStats.experience
	SaveGame.current_save_data.damage = PlayerStats.damage
	SaveGame.current_save_data.defence = PlayerStats.defence
	SaveGame.current_save_data.attack_speed = PlayerStats.attack_speed
	SaveGame.current_save_data.default_speed = PlayerStats.default_speed
	SaveGame.current_save_data.speed_add = PlayerStats.speed_add
	SaveGame.current_save_data.money = PlayerStats.money
	SaveGame.current_save_data.equiped_sp = PlayerStats.equiped_sp
	SaveGame.save_data(SaveGame.current_save_data_id)
	PlayerStats.set_health(SaveGame.current_save_data.health)
	PlayerStats.set_mana(SaveGame.current_save_data.mana)
	PlayerStats.set_sp(SaveGame.current_save_data.sp)
	PlayerStats.stamina = PlayerStats.max_stamina
