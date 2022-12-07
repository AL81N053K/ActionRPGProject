extends Control

onready var settings_menu = $Options
onready var tween = $Tween
onready var buttons = $Buttons

func _ready():
	if EventBus.connect("game_saved",self,"game_saved") == OK: pass
	if EventBus.connect("blur_effect",self,"set_blur") == OK: pass
	settings_menu.connect("closing",self,"_options_closing")

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
	Transition.transition()
	yield(Transition,"animation_finished")
	SceneChanger.goto_scene("res://src/maps/MainMenu.tscn", MainScene.main)
	Music.SetGameState("Loading")
	WorldTime.reset()

func _on_Save_pressed():
	SaveGame._save()

func game_saved():
	$Buttons/Save.text = "Saved"
	$Buttons/Save.disabled = true
	yield(get_tree().create_timer(1.5), "timeout")
	$Buttons/Save.text = "Save"
	$Buttons/Save.disabled = false

func make_tween(object, property: String, start, end, time, trans = Tween.TRANS_QUAD, _ease = Tween.EASE_IN, delay = 0):
	tween.interpolate_property(object, property, start, end, time, trans, _ease, delay)
