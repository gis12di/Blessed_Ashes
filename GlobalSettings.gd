extends Node

signal fps_displayed(value)
signal brightness_updated(value)
signal fov_updated(value)
signal mouse_sens_updated(value)

#VIDEO
func change_displayMode(toggle):
	if toggle:
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED
	
	Save.game_data.full_screen_on = toggle
	Save.save_data()

func change_vsync(toggle):
	if toggle:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	
	Save.game_data.vsync_on = toggle
	Save.save_data()

func toggle_fps_display(toggle):
	fps_displayed.emit(toggle)
	Save.game_data.display_fps = toggle
	Save.save_data()

func set_max_fps(value):
	print(value)
	if value < 500:
		Engine.max_fps = value
	else:
		Engine.max_fps = 0  # 0 = sin límite
	
	Save.game_data.max_fps = Engine.max_fps if value < 500 else 500
	Save.save_data()

func update_brightness(value):
	brightness_updated.emit(value)
	Save.game_data.brightness = value
	Save.save_data()

#AUDIO
func update_master_vol(bus_idx, vol):
	# Configurar volumen y mute
	if vol > -50:
		AudioServer.set_bus_volume_db(bus_idx, vol)
		AudioServer.set_bus_mute(bus_idx, false)
	else:
		AudioServer.set_bus_mute(bus_idx, true)
	
	# Guardar según el bus
	match bus_idx:
		0:
			Save.game_data.master_vol = vol
		1:
			Save.game_data.music_vol = vol
		2:
			Save.game_data.sfx_vol = vol
	
	Save.save_data()

func update_fov(value):
	fov_updated.emit(value)
	Save.game_data.fov = value
	Save.save_data()

func update_mouse_sens(value):
	mouse_sens_updated.emit(value)
	Save.game_data.mouse_sens = value
	Save.save_data()
