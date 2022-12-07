extends Node

func toggle_screen_mode(value, index, text):
	if value == 0:
		OS.window_fullscreen = false
		OS.window_borderless = false
		OS.window_maximized = false
		set_window_size(text, index)
	if value == 1:
		OS.window_fullscreen = false
		OS.window_borderless = true
		OS.window_maximized = true
	if value == 2:
		OS.window_fullscreen = true
		OS.window_borderless = false
		OS.window_maximized = false
	
	Save.game_data.window_mode = value
	Save.save_data()

func set_window_size(text, index):
	var values = text.split_floats("x")
	OS.window_size = Vector2(values[0], values[1])
	OS.set_window_position(OS.get_screen_position(OS.get_current_screen()) + OS.get_screen_size()*0.5 - OS.get_window_size()*0.5)
	Save.game_data.window_size = index
	Save.save_data()

func set_antialising(index):
	match index:
		0:
			get_viewport().msaa = Viewport.MSAA_DISABLED
			get_viewport().fxaa = false
		1:
			get_viewport().msaa = Viewport.MSAA_DISABLED
			get_viewport().fxaa = true
		2:
			get_viewport().msaa = Viewport.MSAA_2X
			get_viewport().fxaa = false
		3:
			get_viewport().msaa = Viewport.MSAA_4X
			get_viewport().fxaa = false
		4:
			get_viewport().msaa = Viewport.MSAA_8X
			get_viewport().fxaa = false
		5:
			get_viewport().msaa = Viewport.MSAA_16X
			get_viewport().fxaa = false
	Save.game_data.antialising = index
	Save.save_data()

func set_blur(value):
	ScreenEffects.set_blur(value)
	Save.game_data.blur = value
	Save.save_data()
	EventBus.emit_signal("blur_effect", value)

func toggle_vsync(value):
	OS.vsync_enabled = value
	Save.game_data.vsync = value
	Save.save_data()

func toggle_bloom(value):
	GlobalWorldEnvironment.environment.glow_enabled = value
	Save.game_data.bloom = value
	Save.save_data()

func toggle_fps_display(value):
	EventBus.emit_signal("fps_display", value)
	Save.game_data.display_fps = value
	Save.save_data()

func set_max_fps(value):
	Engine.target_fps = value if value < 300 else 0
	Save.game_data.limit_fps = Engine.target_fps if value < 300 else 0
	EventBus.emit_signal("fps_cap", value)
	Save.save_data()

func toggle_glitch_effect(value):
	EventBus.emit_signal("glitch_effect", value)
	Save.game_data.glitch_effect = value
	Save.save_data()

func update_bus_vol(index, vol):
	if vol > -80:
		AudioServer.set_bus_mute(index, false)
		AudioServer.set_bus_volume_db(index, vol)
	else:
		AudioServer.set_bus_mute(index, true)
	match index:
		0:
			Save.game_data.master_vol = vol * 1.25
		1:
			Save.game_data.music_vol = vol * 1.25
		2:
			Save.game_data.sfx_vol = vol * 1.25
	Save.save_data()

func set_colorblind_mode(value):
	ScreenEffects.set_type(value)
	Save.game_data.colorblind_mode = value
	Save.save_data()

func set_stamina_bar_style(value):
	EventBus.emit_signal("set_stamina_bar_style", value)
	Save.game_data.stamina_bar = value
	Save.save_data()

func set_timer_style(value):
	Save.game_data.timer = value
	Save.save_data()

func toggle_debug_console(value):
	Save.game_data.debug_console = value
	Save.save_data()

func toggle_experimental(value):
	Save.game_data.experimental = value
	Save.save_data()
