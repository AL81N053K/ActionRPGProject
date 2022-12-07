extends Node

signal game_saved

signal no_health
signal no_stamina
signal stamina_refilled
signal level_up
signal sp_signal(sp)
signal health_changed(type, amount)

signal fps_display(value)
signal glitch_effect(value)
signal fps_cap(value)
signal set_stamina_bar_style(value)
signal blur_effect(value)

func debug() -> void:
	emit_signal("game_saved")
	emit_signal("no_health")
	emit_signal("no_stamina")
	emit_signal("stamina_refilled")
	emit_signal("level_up")
	emit_signal("sp_signal")
	emit_signal("health_changed")
	emit_signal("fps_display")
	emit_signal("glitch_effect")
	emit_signal("fps_cap")
	emit_signal("set_stamina_bar_style")
	emit_signal("blur_effect")
