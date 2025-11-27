extends Popup

# Video Settings
@onready var display_options = $SettingsTabs/Video/MarginContainer/VideoSettings/BtnDisplay
@onready var vsync_btn = $SettingsTabs/Video/MarginContainer/VideoSettings/BtnVsync
@onready var display_fps_btn = $SettingsTabs/Video/MarginContainer/VideoSettings/BtnFps
@onready var max_fps_slider = $SettingsTabs/Video/MarginContainer/VideoSettings/MaxFpsContainer/SliderMaxFps
@onready var max_fps_val = $SettingsTabs/Video/MarginContainer/VideoSettings/MaxFpsContainer/LabelCurrentFps
@onready var brightness = $SettingsTabs/Video/MarginContainer/VideoSettings/SliderBrightness

# Audio Settings
@onready var master_slider = $SettingsTabs/Audio/MarginContainer/GridContainer/SliderMasterVol
@onready var music_slider = $SettingsTabs/Audio/MarginContainer/GridContainer/SliderMusicVol
@onready var sfx_slider = $SettingsTabs/Audio/MarginContainer/GridContainer/SliderSFXVol

# Gameplay Settings
@onready var fov_amount = $SettingsTabs/Gameplay/MarginContainer/GridContainer/HBoxContainer/FovAmount
@onready var fov_slider = $SettingsTabs/Gameplay/MarginContainer/GridContainer/HBoxContainer/SliderFov
@onready var mouse_sens_amount = $SettingsTabs/Gameplay/MarginContainer/GridContainer/HBoxContainer2/FovAmount
@onready var mouse_slider = $SettingsTabs/Gameplay/MarginContainer/GridContainer/HBoxContainer2/SliderMouseSens

func _ready() -> void:
	# Asegurarse de que el OptionButton tiene ítems antes de seleccionar
	_setup_display_options()
	
	# Configurar valores iniciales desde los datos guardados
	display_options.select(1 if Save.game_data.full_screen_on else 0)
	GlobalSettings.change_displayMode(Save.game_data.full_screen_on)
	vsync_btn.button_pressed = Save.game_data.vsync_on
	display_fps_btn.button_pressed = Save.game_data.display_fps
	max_fps_slider.value = Save.game_data.max_fps
	brightness.value = Save.game_data.brightness
	master_slider.value = Save.game_data.master_vol
	music_slider.value = Save.game_data.music_vol
	sfx_slider.value = Save.game_data.sfx_vol
	fov_slider.value = Save.game_data.fov
	mouse_slider.value = Save.game_data.mouse_sens
	
	# Actualizar las etiquetas de valores
	_update_fov_display(Save.game_data.fov)
	_update_mouse_sens_display(Save.game_data.mouse_sens)
	_update_max_fps_display(Save.game_data.max_fps)

func _setup_display_options():
	# Limpiar cualquier ítem existente (por si acaso)
	display_options.clear()
	
	# Agregar las opciones de pantalla
	display_options.add_item("Ventana", 0)
	display_options.add_item("Pantalla Completa", 1)
	
	# Conectar la señal si no está conectada en el editor
	if not display_options.item_selected.is_connected(_on_BtnDisplay_item_selected):
		display_options.item_selected.connect(_on_BtnDisplay_item_selected)

# 🔥 NUEVA FUNCIÓN: Cambiar entre pantalla completa y ventana
func _on_BtnDisplay_item_selected(index: int) -> void:
	var fullscreen = (index == 1)
	GlobalSettings.change_displayMode(fullscreen)
	
	# Guardar la preferencia
	Save.game_data.full_screen_on = fullscreen
	Save.save_data()

# Las demás funciones permanecen igual...
func _on_BtnVsync_toggled(button_pressed: bool) -> void:
	GlobalSettings.change_vsync(button_pressed)

func _on_BtnFps_toggled(button_pressed: bool) -> void:
	GlobalSettings.toggle_fps_display(button_pressed)

func _on_SliderMaxFps_value_changed(value: float) -> void:
	GlobalSettings.set_max_fps(value)
	_update_max_fps_display(value)

func _update_max_fps_display(value: float):
	if value < max_fps_slider.max_value:
		max_fps_val.text = str(value)
	else:
		max_fps_val.text = "max"

func _on_SliderBrightness_value_changed(value: float) -> void:
	GlobalSettings.update_brightness(value)

func _on_SliderMasterVol_value_changed(value: float) -> void:
	GlobalSettings.update_master_vol(0, value)

func _on_SliderMusicVol_value_changed(value: float) -> void:
	GlobalSettings.update_master_vol(1, value)

func _on_SliderSFXVol_value_changed(value: float) -> void:
	GlobalSettings.update_master_vol(2, value)

func _on_SliderMouseSens_value_changed(value: float) -> void:
	GlobalSettings.update_mouse_sens(value)
	_update_mouse_sens_display(value)

func _update_mouse_sens_display(value: float):
	mouse_sens_amount.text = str(value)

func _on_SliderFov_value_changed(value: float) -> void:
	GlobalSettings.update_fov(value)
	_update_fov_display(value)

func _update_fov_display(value: float):
	fov_amount.text = str(value)

func _on_SettingsMenu_popup_hide() -> void:
	get_tree().paused = false
	# Para el menú principal, mantener el mouse visible
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
