extends Node

signal fps_displayed(value)
signal brightness_updated(value)
signal fov_updated(value)
signal mouse_sens_updated(value)

#VIDEO
func change_displayMode(toggle):
	if toggle:
		get_window().mode = Window.MODE_FULLSCREEN
		print("🔳 Activado modo pantalla completa")
	else:
		get_window().mode = Window.MODE_WINDOWED
		print("🔲 Activado modo ventana")
	
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

#AUDIO - 🔥 CORRECCIÓN: Función específica para música
func update_music_volume(volume_db: float):
	# 🔥 OBTENER el índice del bus de música correctamente
	var music_bus_index = AudioServer.get_bus_index("Music")
	
	# Si el bus de música no existe, crearlo
	if music_bus_index == -1:
		print("⚠️ Bus de música no encontrado, creando uno...")
		AudioServer.add_bus(1)  # Añadir en la posición 1
		AudioServer.set_bus_name(1, "Music")
		music_bus_index = 1
	
	print("🎵 Ajustando volumen de música: ", volume_db, " dB")
	
	# Configurar volumen y mute
	if volume_db > -40:  # 🔥 Ajusté el umbral de mute
		AudioServer.set_bus_volume_db(music_bus_index, volume_db)
		AudioServer.set_bus_mute(music_bus_index, false)
		print("🔊 Música activada - Volumen: ", volume_db, " dB")
	else:
		AudioServer.set_bus_mute(music_bus_index, true)
		print("🔇 Música silenciada")
	
	# Guardar la configuración
	Save.game_data.music_vol = volume_db
	Save.save_data()

# 🔥 MANTENER la función original para otros buses pero usar nombres
func update_master_vol(bus_idx, vol):
	var bus_name = ""
	match bus_idx:
		0: bus_name = "Master"
		1: bus_name = "Music"  # 🔥 Esto ahora usa la función específica
		2: bus_name = "SFX"
	
	print("🎚️ Ajustando bus: ", bus_name, " - Volumen: ", vol, " dB")
	
	# Si es música, usar la función específica
	if bus_name == "Music":
		update_music_volume(vol)
		return
	
	# Para otros buses
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		if vol > -40:
			AudioServer.set_bus_volume_db(bus_index, vol)
			AudioServer.set_bus_mute(bus_index, false)
		else:
			AudioServer.set_bus_mute(bus_index, true)
	
	# Guardar según el bus
	match bus_idx:
		0:
			Save.game_data.master_vol = vol
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
