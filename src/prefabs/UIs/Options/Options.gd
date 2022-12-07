extends Popup

var tab_changed = false
var tab_count = [0,[]]

signal closing

# Video
onready var display_options = $TabContainer/Graphics/Container/Grid/DisplayModelButton
onready var display_size = $TabContainer/Graphics/Container/Grid/DisplaySizeButton
onready var antialising = $TabContainer/Graphics/Container/Grid/AntiAlisingButton
onready var blur = $TabContainer/Graphics/Container/Grid/BlurEffectButton
onready var vsync = $TabContainer/Graphics/Container/Grid/VsyncSwitch
onready var bloom = $TabContainer/Graphics/Container/Grid/BloomSwitch
onready var fps_slider_txt = $TabContainer/Graphics/Container/Grid/MaxFPS/Label
onready var fps_slider = $TabContainer/Graphics/Container/Grid/MaxFPS/Slider

# Audio
onready var master_vol_slider = $TabContainer/Audio/Container/Grid/Master/Slider
onready var master_vol_txt = $TabContainer/Audio/Container/Grid/Master/Label
onready var music_vol_slider = $TabContainer/Audio/Container/Grid/Music/Slider
onready var music_vol_txt = $TabContainer/Audio/Container/Grid/Music/Label
onready var sfx_vol_slider = $TabContainer/Audio/Container/Grid/SFX/Slider
onready var sfx_vol_txt = $TabContainer/Audio/Container/Grid/SFX/Label

# Accesibility
onready var colorblind_options = $TabContainer/Accesbility/Container/Grid/ColorblindMode
onready var glitch_effect_btn = $TabContainer/Accesbility/Container/Grid/GlitchEffect
onready var stamina_bar = $TabContainer/Accesbility/Container/Grid/StaminaBar
onready var display_fps_btn = $TabContainer/Accesbility/Container/Grid/DisplayFPSButton
onready var timer_btn = $TabContainer/Accesbility/Container/Grid/Timer

# Debug
onready var consoleButton = $TabContainer/Debug/Container/Grid/ConsoleButton
onready var experimentButton = $TabContainer/Debug/Container/Grid/ExperimentalButton

onready var checkBox_off_normal = preload("res://assets/themes/textures/CheckButton_Off.png")
onready var checkBox_off_focus = preload("res://assets/themes/textures/CheckButton_Off_focus.png")
onready var checkBox_on_normal = preload("res://assets/themes/textures/CheckButton_On.png")
onready var checkBox_on_focus = preload("res://assets/themes/textures/CheckButton_On_focus.png")

func _ready():
	display_options.select(Save.game_data.window_mode if Save.game_data.window_mode else 0)
	GlobalSettings.toggle_screen_mode(Save.game_data.window_mode,Save.game_data.window_size,display_size.get_item_text(Save.game_data.window_size))
	
	display_size.select(Save.game_data.window_size)
	GlobalSettings.set_window_size(display_size.get_item_text(Save.game_data.window_size),Save.game_data.window_size)
	
	antialising.select(Save.game_data.antialising)
	GlobalSettings.set_antialising(Save.game_data.antialising)
	
	blur.select(Save.game_data.blur)
	GlobalSettings.set_blur(Save.game_data.blur)
	
	bloom.pressed = Save.game_data.bloom
	GlobalSettings.toggle_bloom(Save.game_data.bloom)
	
	vsync.pressed = Save.game_data.vsync
	GlobalSettings.toggle_vsync(Save.game_data.vsync)
	
	display_fps_btn.pressed = Save.game_data.display_fps
	GlobalSettings.toggle_fps_display(Save.game_data.display_fps)
	
	fps_slider.value = Save.game_data.limit_fps if Save.game_data.limit_fps != 0 else fps_slider.max_value
	fps_slider_txt.text = str(Save.game_data.limit_fps) if Save.game_data.limit_fps != 0 else "Unlimited"
	GlobalSettings.set_max_fps(Save.game_data.limit_fps)
	
	glitch_effect_btn.pressed = Save.game_data.glitch_effect
	GlobalSettings.toggle_glitch_effect(Save.game_data.glitch_effect)
	
	master_vol_slider.value = Save.game_data.master_vol
	master_vol_txt.text = str(100 + Save.game_data.master_vol) + "%"
	GlobalSettings.update_bus_vol(0, Save.game_data.master_vol * 0.8)
	music_vol_slider.value = Save.game_data.music_vol
	music_vol_txt.text = str(100 + Save.game_data.music_vol) + "%"
	GlobalSettings.update_bus_vol(1, Save.game_data.music_vol * 0.8)
	sfx_vol_slider.value = Save.game_data.sfx_vol
	sfx_vol_txt.text = str(100 + Save.game_data.sfx_vol) + "%"
	GlobalSettings.update_bus_vol(2, Save.game_data.sfx_vol * 0.8)
	
	colorblind_options.select(Save.game_data.colorblind_mode)
	GlobalSettings.set_colorblind_mode(Save.game_data.colorblind_mode)
	
	stamina_bar.select(Save.game_data.stamina_bar)
	GlobalSettings.set_stamina_bar_style(Save.game_data.stamina_bar)
	
	timer_btn.select(Save.game_data.timer)
	GlobalSettings.set_timer_style(Save.game_data.timer)
	
	consoleButton.pressed = Save.game_data.debug_console
	GlobalSettings.toggle_debug_console(Save.game_data.debug_console)
	
	experimentButton.pressed = Save.game_data.experimental
	GlobalSettings.toggle_experimental(Save.game_data.experimental)
	
	_count_tabs()

var focused_node
var saved_node

func _count_tabs():
	if tab_count[1].size() != 0: 
		for n in tab_count[1].size():
			tab_count[1].remove(0)
	tab_count[0] = $TabContainer.get_tab_count()
	for t in tab_count[0]:
		if $TabContainer.get_tab_disabled(t) == true: tab_count[1] += [t]

func _check_if_disabled(tab, go_by):
	var go = tab + go_by
	var _max = tab_count[0] - 1
	var scan = true
	while scan:
		if go > _max: go = 0
		if go < 0: go = _max
		if tab_count[1].size() > 0: for t in tab_count[1].size():
			if go == tab_count[1][t]: 
				go += go_by
				break
			scan = false
		else:
			scan = false
	return go

func _process(_delta):
	focused_node = get_focus_owner()
	if saved_node != null and focused_node != saved_node:
		saved_node.add_icon_override("on", checkBox_on_normal)
		saved_node.add_icon_override("off", checkBox_off_normal)
		saved_node = null
	if focused_node is CheckButton:
		saved_node = focused_node
		focused_node.add_icon_override("on", checkBox_on_focus)
		focused_node.add_icon_override("off", checkBox_off_focus)

func _input(event):
	if event.is_action_pressed("cancel") and self.is_visible() and $Tween.tell() == 0:
		emit_signal("closing")
		_animated_hide()
		yield($Tween, "tween_all_completed")
		self.hide()
	
	if Input.is_action_just_pressed("change_tab") and self.visible:
		$TabContainer.current_tab = _check_if_disabled($TabContainer.current_tab,1)
		tab_changed = true
	if Input.is_action_just_pressed("change_btab") and self.visible:
		$TabContainer.current_tab = _check_if_disabled($TabContainer.current_tab,-1)
		tab_changed = true
	
	if self.visible and tab_changed: 
		tab_changed = false
		var focus_to = $TabContainer.get_child($TabContainer.current_tab).get_child(0).get_child(0).get_child(1)
		if is_instance_valid(focus_to): 
			if focus_to.get_class() == "HBoxContainer":
				focus_to = focus_to.get_child(1)
			focus_to.grab_focus()

func _animated_show():
	$Tween.interpolate_property(self, "modulate", self.modulate, Color(1,1,1,1), .5)
	$Tween.start()

func _animated_hide():
	$Tween.interpolate_property(self, "modulate", self.modulate, Color(1,1,1,0), .5)
	$Tween.start()

func _on_DisplayModelButton_item_selected(index):
	var size_index = display_size.get_selected_id()
	var size_text = display_size.get_item_text(size_index)
	GlobalSettings.toggle_screen_mode(index, size_index, size_text)

func _on_DisplaySizeButton_item_selected(index):
	var text = display_size.get_item_text(index)
	GlobalSettings.set_window_size(text, index)

func _on_AntiAlisingButton_item_selected(index):
	GlobalSettings.set_antialising(index)

func _on_BlurEffectButton_item_selected(index):
	GlobalSettings.set_blur(index)

func _on_BloomSwitch_toggled(button_pressed):
	GlobalSettings.toggle_bloom(button_pressed)

func _on_VsyncSwitch_toggled(button_pressed):
	GlobalSettings.toggle_vsync(button_pressed)

func _on_DisplayFPSButton_toggled(button_pressed):
	GlobalSettings.toggle_fps_display(button_pressed)

func _on_MaxFPSSlider_value_changed(value):
	GlobalSettings.set_max_fps(value)
	fps_slider_txt.text = str(value) if value < fps_slider.max_value else "Unlimited"

func _on_GlitchEffect_toggled(value):
	GlobalSettings.toggle_glitch_effect(value)

func _on_MasterVolumeSlider_value_changed(value):
	GlobalSettings.update_bus_vol(0, value * 0.8)
	master_vol_txt.text = str(100 + value) + "%"

func _on_MusicVolumeSlider2_value_changed(value):
	GlobalSettings.update_bus_vol(1, value * 0.8)
	music_vol_txt.text = str(100 + value) + "%"

func _on_SFXVolumeSlider3_value_changed(value):
	GlobalSettings.update_bus_vol(2, value * 0.8)
	sfx_vol_txt.text = str(100 + value) + "%"

func _on_ColorblindMode_item_selected(index):
	GlobalSettings.set_colorblind_mode(index)

func _on_StaminaBar_item_selected(index):
	GlobalSettings.set_stamina_bar_style(index)

func _on_Timer_item_selected(index: int) -> void:
	GlobalSettings.set_timer_style(index)

func _on_ConsoleButton_toggled(value):
	GlobalSettings.toggle_debug_console(value)

func _on_ExperimentalButton_toggled(value):
	GlobalSettings.toggle_experimental(value)
