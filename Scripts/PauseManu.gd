extends Control

onready var settings_menu = $Options
onready var tween = $Tween
onready var buttons = $Buttons

func _ready():
# warning-ignore:return_value_discarded
	SaveGame.connect("game_saved",self,"game_saved")
# warning-ignore:return_value_discarded
	GlobalSettings.connect("blur_effect",self,"set_blur")
	settings_menu.connect("closing",self,"_options_closing")

func _input(_event):
#	$DEBUG.set_visible(Save.game_data.experimental)
	var player = MainScene.main.get_node_or_null("YSort/Player")
	if player != null:
		$DEBUG.text = str("Enemy alerted: ",player.count_enemies())

func set_blur(value):
	$Blur.material.set_shader_param("amount", value * 0.25)

func _on_Resume_pressed():
	visible = false
	MainScene.main.get_node("CanvasLayer/InGameUI").visible = true
	get_tree().paused = false

func _on_Options_pressed():
	buttons.get_node("Options").release_focus()
	tween.stop_all()
	make_tween(buttons, "modulate", buttons.modulate, Color(1,1,1,0), .5)
	tween.start()
	yield(tween, "tween_all_completed")
	settings_menu._animated_show()
	settings_menu.popup_centered()
	buttons.hide()

func _options_closing():
	buttons.show()
	tween.stop_all()
	make_tween(buttons, "modulate", buttons.modulate, Color(1,1,1,1), .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT, .5)
	tween.start()
	yield(tween, "tween_all_completed")
	buttons.get_node("Options").grab_focus()
	

func _on_Main_Menu_pressed():
	get_tree().paused = false
	SceneTransitionRect.transition()
	yield(SceneTransitionRect,"animation_finished")
	SceneChanger.goto_scene("res://Maps/MainMenu.tscn", MainScene.main)
	Music.SetGameState("Loading")

func _on_Save_pressed():
	for d in SaveGame.data_template.size():
		SaveGame.current_save_data.max_health = PlayerStats.max_health
		SaveGame.current_save_data.max_mana = PlayerStats.max_mana
		SaveGame.current_save_data.max_stamina = PlayerStats.max_stamina
		SaveGame.current_save_data.max_temp_health = PlayerStats.max_temp_health
		SaveGame.current_save_data.max_sp = PlayerStats.max_sp
		SaveGame.current_save_data.health = PlayerStats.health
		SaveGame.current_save_data.mana = PlayerStats.mana
		SaveGame.current_save_data.temp_health = PlayerStats.temp_health
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
		SaveGame.current_save_data.location = PlayerStats.location
		SaveGame.current_save_data.position = PlayerStats.position
		for i in range(0, PlayerInventory.MaxStacks):
			var _item = PlayerInventory.at_slot(i)
			if _item != null: SaveGame.current_save_data.inventory[i] = [_item.item.identifier,_item.stackSize]
			if _item == null: SaveGame.current_save_data.inventory[i] = null
		for i in range(0, PlayerArmorInventory.MaxStacks):
			var _item = PlayerArmorInventory.at_slot(i)
			if _item != null: SaveGame.current_save_data.armor_inventory[i] = [_item.item.identifier,_item.stackSize]
			if _item == null: SaveGame.current_save_data.armor_inventory[i] = null
		SaveGame.save_data(SaveGame.current_save_data_id)

func game_saved():
	$Buttons/Save.text = "Saved"
	$Buttons/Save.disabled = true
	yield(get_tree().create_timer(1.5), "timeout")
	$Buttons/Save.text = "Save"
	$Buttons/Save.disabled = false

func make_tween(object, property: String, start, end, time, trans = Tween.TRANS_QUAD, _ease = Tween.EASE_IN, delay = 0):
	tween.interpolate_property(object, property, start, end, time, trans, _ease, delay)
