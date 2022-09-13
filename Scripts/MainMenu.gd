extends Node2D

onready var settings_menu = $CanvasLayer/Options
onready var tween = $CanvasLayer/Tween
onready var buttons = $CanvasLayer/Buttons
onready var saves = $CanvasLayer/Saves

func _ready():
	saves.get_node("H/Slot0").connect("pressed", self, "_select_game",[0])
	saves.get_node("H/Slot1").connect("pressed", self, "_select_game",[1])
	saves.get_node("H/Slot2").connect("pressed", self, "_select_game",[2])
	saves.get_node("H/Slot3").connect("pressed", self, "_select_game",[3])
	settings_menu.connect("closing",self,"_options_close")
	MainScene.setName(name)
	buttons.show()
	saves.hide()
	SceneTransitionRect.transition_backwards()
	make_tween(buttons,"rect_position",Vector2(-50.0,10.0),Vector2(10.0,10.0),1.5,Tween.TRANS_QUAD,Tween.EASE_OUT,2)
	make_tween(buttons,"modulate",Color(1,1,1,0),Color(1,1,1,1),1,Tween.TRANS_SINE,Tween.EASE_IN_OUT,2.5)
	tween.start()
	yield(tween, "tween_all_completed")
	buttons.get_node("Play").grab_focus()

func _select_game(slot):
	if SaveGame.save_file_data[slot] == "null":  
		SaveGame.create_file(slot)
		_grab_saves()
	elif SaveGame.save_file_data[slot] == "working":
		PlayerInventory.clear()
		PlayerArmorInventory.clear()
		saves.get_focus_owner().release_focus()
		var data = SaveGame.load_data(slot)
		for d in SaveGame.data_template.size():
			PlayerStats.set(SaveGame.data_template[d],data.get(SaveGame.data_template[d]))
		for i in range(0, PlayerInventory.MaxStacks):
# warning-ignore:return_value_discarded
			if data.get("inventory")[i] == [null,null] or data.get("inventory")[i] == null: PlayerInventory.add_item_by_id("temp",1)
			else:
# warning-ignore:return_value_discarded
				PlayerInventory.add_item_by_id(data.get("inventory")[i][0], data.get("inventory")[i][1])
		for i in range(0, PlayerArmorInventory.MaxStacks):
# warning-ignore:return_value_discarded
			if data.get("armor_inventory")[i] == [null,null] or data.get("armor_inventory")[i] == null: PlayerArmorInventory.add_item_by_id("temp",1)
			else:
# warning-ignore:return_value_discarded
				PlayerArmorInventory.add_item_by_id(data.get("armor_inventory")[i][0], data.get("armor_inventory")[i][1])
		for i in range(0, PlayerInventory.MaxStacks):
			var _item = PlayerInventory.at_slot(i)
# warning-ignore:return_value_discarded
			if _item.item.identifier == "temp": PlayerInventory.remove_item_by_id("temp")
		for i in range(0, PlayerArmorInventory.MaxStacks):
			var _item = PlayerArmorInventory.at_slot(i)
# warning-ignore:return_value_discarded
			if _item.item.identifier == "temp": PlayerArmorInventory.remove_item_by_id("temp")
		
		PlayerStats.stamina = PlayerStats.max_stamina
		SaveGame.current_save_data_id = slot
		print(data)
		SceneTransitionRect.transition()
		yield(SceneTransitionRect,"animation_finished")
		SceneChanger.goto_scene(str("res://Maps/",data.get("location"),".tscn"), self)
		Music.SetGameState("Loading")

func _grab_saves():
	for s in range(0,4):
		var Slot = saves.get_node(str("H/Slot",s))
		var save_data = SaveGame._get_file(s)
		if save_data == false:
			Slot.c_data_text = "New Game"
		else:
			if SaveGame.check_data(s):
				Slot.c_data_text = "Corrupted save file"
				Slot.corrupted = true
			else: 
				var data = SaveGame.load_data(s)
				Slot.c_data_text = str("Level: ",data.get("level"),"\nLocation:\n",data.get("location"))
		Slot.set_names()

func _on_Play_pressed():
	_grab_saves()
	buttons.get_node("Play").release_focus()
	saves.show()
	make_tween(buttons, "rect_position", buttons.rect_position, Vector2(-50,10), .5, Tween.TRANS_QUAD, Tween.EASE_IN)
	make_tween(buttons, "modulate", buttons.modulate, Color(1,1,1,0), .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	make_tween(saves, "rect_position", saves.rect_position, Vector2(5,170), .9, Tween.TRANS_QUAD, Tween.EASE_OUT, .9)
	make_tween(saves, "modulate", saves.modulate, Color(1,1,1,1), .7, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 1)
	tween.start()
	yield(tween, "tween_all_completed")
	buttons.hide()
	saves.get_node("H/Slot0").grab_focus()

func _on_Options_pressed():
	make_tween(buttons, "rect_position", buttons.rect_position, Vector2(-50,10), .5, Tween.TRANS_QUAD, Tween.EASE_IN)
	make_tween(buttons, "modulate", buttons.modulate, Color(1,1,1,0), .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_all_completed")
	settings_menu._animated_show()
	settings_menu.popup_centered()

func _options_close():
	make_tween(buttons, "rect_position", buttons.rect_position, Vector2(10,10), .5, Tween.TRANS_QUAD, Tween.EASE_IN, .5)
	make_tween(buttons, "modulate", buttons.modulate, Color(1,1,1,1), .5, Tween.TRANS_SINE, Tween.EASE_IN_OUT, .5)
	tween.start()

func _on_Quit_pressed():
	get_tree().quit()

func make_tween(object, property: String, start, end, time, trans = Tween.TRANS_QUAD, _ease = Tween.EASE_IN, delay = 0):
	tween.interpolate_property(object, property, start, end, time, trans, _ease, delay)

func _input(event):
	if saves.is_visible() and event.is_action_pressed("cancel"):
		print("pressed")
		var focus = saves.get_focus_owner()
		if focus != null: focus.release_focus()
		buttons.show()
		make_tween(saves,"rect_position",saves.rect_position,Vector2(5,370),.9,Tween.TRANS_QUAD,Tween.EASE_OUT)
		make_tween(saves,"modulate",saves.modulate,Color(1,1,1,0),.9,Tween.TRANS_SINE,Tween.EASE_IN_OUT)
		make_tween(buttons,"rect_position",buttons.rect_position,Vector2(10,10),.5,Tween.TRANS_QUAD,Tween.EASE_IN,.9)
		make_tween(buttons,"modulate",buttons.modulate,Color(1,1,1,1),.5,Tween.TRANS_SINE,Tween.EASE_IN_OUT,.9)
		tween.start()
		yield(tween, "tween_all_completed")
		saves.hide()
		buttons.get_node("Play").grab_focus()
