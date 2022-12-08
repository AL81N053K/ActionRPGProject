extends Control

onready var settings_menu = $CanvasLayer/Options
onready var anim_player = $CanvasLayer/AnimationPlayer
onready var buttons = $CanvasLayer/Buttons
onready var saves = $CanvasLayer/Saves

onready var save_nodes: Array
onready var SavePanel = preload("res://src/prefabs/UIs/MainMenu/Panel/MainMenuPanel.tscn")

func _ready():
	settings_menu.connect("closing",self,"_options_close")
	MainScene.setName(name)
	random_bg()
	$CanvasLayer/Version.text = $CanvasLayer/Version.text % ProjectSettings.get_setting("global/Version")
	start_anim()

func random_bg():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var number = rng.randi_range(1, 5)
	$Background.texture = load(str("res://assets/textures/backgrounds/menu_pattern_",number,".png"))

func start_anim():
	buttons.show()
	saves.hide()
	Transition.transition_backwards()
	yield(Transition,"animation_finished")
	anim_player.play("Init")
	yield(anim_player,"animation_finished")
	buttons.get_node("Play").grab_focus()

func _select_game(slot):
	Inventories.clear_all()
	release_focus()
	SaveGame.current_save = str(slot)
	var data = SaveGame.load_data(slot)
	print(data)
	for d in SaveGame.data_template.size():
		PlayerStats.set(SaveGame.data_template[d],data.get(SaveGame.data_template[d]))
	for i in range(0, Inventories.Main.MaxStacks):
		if data.get("inventory")[i] == [null,null] or data.get("inventory")[i] == null: 
			Inventories.Main.add_item_by_id("temp",1)
		else: Inventories.Main.add_item_by_id(data.get("inventory")[i][0], data.get("inventory")[i][1])
	for i in range(0, Inventories.Armor.MaxStacks):
		if data.get("armor_inventory")[i] == [null,null] or data.get("armor_inventory")[i] == null: 
			Inventories.Armor.add_item_by_id("temp",1)
		else: Inventories.Armor.add_item_by_id(data.get("armor_inventory")[i][0], data.get("armor_inventory")[i][1])
	for i in range(0, Inventories.Main.MaxStacks):
		var _item = Inventories.Main.at_slot(i)
		if _item.item.identifier == "temp": Inventories.Main.remove_item_by_id("temp")
	for i in range(0, Inventories.Armor.MaxStacks):
		var _item = Inventories.Armor.at_slot(i)
		if _item.item.identifier == "temp": Inventories.Armor.remove_item_by_id("temp")
	WorldTime.time = data.time
	PlayerStats.stamina = PlayerStats.max_stamina
	Transition.transition()
	yield(Transition,"animation_finished")
	SceneChanger.goto_scene(str("res://src/maps/",data.get("location"),".tscn"), self)
	Music.SetGameState("Loading")
	WorldTime.start()

func _grab_saves():
	var files = Dir.get_files("user://saves",".sav")
	save_nodes.clear()
	for n in $"%SavePanels".get_children():
		$"%SavePanels".remove_child(n)
		n.queue_free()
	for savefile in files:
		var s_name = savefile.replace(".sav","")
		save_nodes.push_back(s_name)
		var instance = SavePanel.instance()
		if SaveGame.check_data(s_name):
			SaveGame.fix_save(s_name)
		var data = SaveGame.load_data(s_name)
		var c_data_text = str("Level: ",data.get("level"),"\nLocation:\n",data.get("location"))
		instance.setup(s_name,c_data_text,"null",true)
		$"%SavePanels".add_child(instance)

func _on_Play_pressed():
	_grab_saves()
	buttons.get_node("Play").release_focus()
	saves.show()
	anim_player.play("ShowSaveSlots")
	yield(anim_player, "animation_finished")
	buttons.hide()
	saves.get_node("H/NewGame").grab_focus()

func _on_Options_pressed():
	settings_menu.popup_centered()
	settings_menu._animated_show()
	anim_player.play("ShowOptions")

func _options_close():
	anim_player.play_backwards("ShowOptions")

func _on_Quit_pressed():
	get_tree().quit()

func _input(event):
	if saves.is_visible() and event.is_action_pressed("accept"):
		if get_focus_owner() != null:
			var focused_on = get_focus_owner().get_name()
			print(focused_on)
			if focused_on == "NewGame": 
				SaveGame.create_file(str("Save ",save_nodes.size()))
				_grab_saves()
			elif focused_on.substr(0,4) == "Save":
				_select_game(focused_on)
		
	if saves.is_visible() and event.is_action_pressed("cancel"):
		var focus = saves.get_focus_owner()
		if focus != null: focus.release_focus()
		buttons.show()
		anim_player.play_backwards("ShowSaveSlots")
		yield(anim_player,"animation_finished")
		saves.hide()
		buttons.get_node("Play").grab_focus()
